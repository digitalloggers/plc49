if node.bootreason()==1 then tmr.alarm(0,1000,0,function() require("main") end) else require("main") end
