var fuzzyDelay=function(seconds,range)
{
    var fuzzyMilliseconds=(seconds+(Math.random()-0.5)*(range||1))*1000;
    return Math.max(fuzzyMilliseconds,1);
}
var uncachedAjax=function(config)
{
    var configCopy=$.extend({},config);
    configCopy.url+="?"+new Date().getTime();
    $.ajax(configCopy);
}
var insistentAjax=function(config)
{
    var configCopy=$.extend({},config);
    configCopy.error=function(xhr)
    {
        if (xhr.status==503)
        {
            var delay=parseInt(xhr.getResponseHeader("Retry-After"));
            setTimeout(
                function()
                {
                    $.ajax(configCopy);
                },
                fuzzyDelay(delay)
            )
        }
    }
    $.ajax(configCopy);
}

var insistentSafeAjax=function(config)
{
    var configCopy=$.extend({},config);
    var success=config.success;
    var request;
    var requestSucceeded;
    var restartInterval;
    restartInterval=setInterval(
        function()
        {
            if (!requestSucceeded)
            {
                if (request)
                {
                    request.abort();
                }
                request=uncachedAjax(configCopy);
            }
        },
        fuzzyDelay(3)
    )
    configCopy.success=function(data,status,xhr)
    {
        requestSucceeded=true;
        clearTimeout(restartInterval);
        return success(data,status,xhr);
    }
    request=uncachedAjax(configCopy);
}
var edit_element;
var edit_box=$("<input/>");
var edit_url;
var edit_form=$('<form action="#"/>').addClass("edit-form").append(edit_box).submit(
    function(evt){
        evt.preventDefault();
        var data=edit_box.val();
        edit_element.text(data);
        edit_element.show();
        edit_form.remove();
        insistentAjax({url:edit_url,data:JSON.stringify(data),type:"PUT",contentType:"application/json"});
        edit_element=undefined;
        edit_url=undefined;
    }
);
var cssMask={"display":"both","width":"box","height":"box","background":"box","font":"box"};

var makeEditable=function(element,config_url)
{
    element.click(
        function(evt)
        {
            var that=$(this);
            edit_box.val(that.text());
            for (var s in cssMask) if (cssMask.hasOwnProperty(s))
            {
                edit_box.css(s,that.css(s));
                if (cssMask[s]=="both")
                {
                    edit_form.css(s,that.css(s))
                }
            }
            edit_form.insertBefore(that);
            edit_url=config_url;
            if (edit_element)
            {
                edit_element.show();
            }
            edit_element=element;
            edit_element.hide();
        }
    )
}
$(function()
  {
      $("html").removeClass("not-loaded");
      var input_container=$("<table/>").appendTo($("div.inputs"));
      var outlet_container=$("<table/>").appendTo($("div.outlets"));
      var adc_container=$("div.adc");
      var mode_form=$("form.wifi-mode");
      var ap_form=$("form.wifi-ap");
      var sta_form=$("form.wifi-sta");
      var input_values=[];
      var outlet_values=[];
      var adc_updaters=[];

      var periodic_request;
      var next_request_time;
      var periodic_requests_ok=false;
      makeEditable($(".header .name"),"/config/name");
      var updateInput=function(index,state)
      {
          input_values[index].removeClass(!state?"active":"inert").addClass(state?"active":"inert").text(state?"ACTIVE":"INERT");
      };
      var updateOutlet=function(index,state)
      {
          outlet_values[index].removeClass(!state?"on":"off").addClass(state?"on":"off").text(state?"ON":"OFF");
      };
      var updateADC=function(index,fractional_value)
      {
          adc_updaters[index](fractional_value[0],fractional_value[1]);
      };
      periodic_request=setInterval(
          function()
          {
              var now=new Date().getTime();
              if (periodic_requests_ok&&(!next_request_time||(now>next_request_time)))
              {
                  uncachedAjax({
                      url:"/state/all/all/value",
                      dataType:"application/json",
                      success:function(data)
                      {
                          $.each(data.input,updateInput);
                          $.each(data.output,updateOutlet);
                          $.each(data.adc,updateADC);
                          next_request_time=undefined;
                      },
                      error:function(xhr)
                      {
                          var delay=(xhr.status==503)?parseInt(xhr.getResponseHeader("Retry-After")||"1"):1;
                          next_request_time=now+fuzzyDelay(delay);
                      }
                  });
              }
          },
          fuzzyDelay(1,0)
      )
      insistentSafeAjax({url:"/config",dataType:"application/json",success:function(data)
              {
                  $(".header .name").text(data.name);
                  $(".version").text(data.version?"Version "+data.version:"Unknown version");
                  mode_form.find("select[name=mode] option[value=\""+data.wifi_mode+"\"]").attr("selected","selected");
                  ap_form.find("input[name=ssid]").val(data.wifi_ap[0]||"");
                  ap_form.find("input[name=key]").val(data.wifi_ap[1]||"");
                  sta_form.find("input[name=ssid]").val(data.wifi_sta[0]||"");
                  sta_form.find("input[name=key]").val(data.wifi_sta[1]||"");
              }
             });
      insistentSafeAjax({url:"/state",dataType:"application/json",success:function(data)
              {
                  $.each(data.input,function(i,e)
                         {
                             var input_name=$("<span/>").addClass("name").text(e.name);
                             var input_value=$("<span/>").addClass("value");
                             input_values[i]=input_value;
                             makeEditable(input_name,"/config/input/"+i+"/name");
                             updateInput(i,e.value);
                             input_container.append($("<tr/>").addClass("input").append($("<td/>").append(input_name)).append($("<td/>").append(input_value)));
                         }
                        );
                  $.each(data.output,function(i,e)
                         {
                             var outlet_name=$("<span/>").addClass("name").text(e.name);
                             var outlet_value=$("<button/>").addClass("value");
                             outlet_values[i]=outlet_value;
                             makeEditable(outlet_name,"/config/output/"+i+"/name");
                             updateOutlet(i,e.value);
                             outlet_value.click(
                                 function()
                                 {
                                     var new_state=outlet_value.hasClass("on")?0:1;
                                     insistentAjax({url:"/state/output/"+i.toString()+"/value",data:new_state,type:"PUT",contentType:"application/json",success:function() {
                                         updateOutlet(i,new_state);
                                     }});
                                 })
                             outlet_container.append($("<tr/>").addClass("outlet").append($("<td/>").append(outlet_name)).append($("<td/>").append(outlet_value)));
                         }
                        );
                  $.each(data.adc,function(i,e)
                         {
                             var adc_block=$("<div/>").addClass("adc");
                             var name=$("<span/>").addClass("name").text(e.name);
                             var value=$("<span/>").addClass("value");
                             var gauge=$("<span/>").addClass("gauge");
                             var label=$("<span/>").addClass("label");
                             var update_this_adc=function(value,limit)
                             {
                                 gauge.css("width",value/limit*100+"%");
                                 label.text(value+"/"+limit);
                             }
                             adc_updaters[i]=update_this_adc;
                             makeEditable(name,"/config/adc/"+i+"/name");
                             updateADC(i,e.value);
                             adc_container.append(adc_block.append(name).append(value.append(gauge).append(label)));
                         }
                        );
                  periodic_requests_ok=true;
              }
      });
      mode_form.submit(function(evt){
          evt.preventDefault();
          insistentAjax({url:"/config/wifi_mode",data:JSON.stringify(mode_form.find("select[name=mode]").val()),type:"PUT",contentType:"application/json"});
      });
      ap_form.submit(function(evt){
          evt.preventDefault();
          insistentAjax({url:"/config/wifi_ap",data:JSON.stringify([ap_form.find("input[name=ssid]").val(),ap_form.find("input[name=key]").val()]),type:"PUT",contentType:"application/json"});
      });
      sta_form.submit(function(evt){
          evt.preventDefault();
          insistentAjax({url:"/config/wifi_sta",data:JSON.stringify([sta_form.find("input[name=ssid]").val(),sta_form.find("input[name=key]").val()]),type:"PUT",contentType:"application/json"});
      });
      var heap=$(".console .heap");
      var log=$(".console .log");
      var entry=$("<input/>").attr("type","text");
      var form=$("<form/>").attr("action","#").append(entry).submit(function(evt){
          evt.preventDefault();
          var data=entry.val();
          entry.val("");
          var request=$("<pre>").addClass("sent").text(data);
          log.append(request);
          insistentAjax({url:"/eval",data:JSON.stringify(data),type:"POST",dataType:"application/json",contentType:"application/json",success:function(data) {
              request.removeClass("sent").addClass("acked");
              $.each(
                  data,
                  function(i,e)
                  {
                      var kind=e[0];
                      var value=e[1];
                      if (kind=="heap")
                      {
                          heap.text("node.heap():"+value);
                      }
                      else
                      {
                          log.append($("<pre>").addClass("received").addClass(kind).text(value));
                          log.scrollTop(log[0].scrollHeight);
                      }
                  }
              );
          }});
      });
      $(".console .entry").append(form);
  }
 );
