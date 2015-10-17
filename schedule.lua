local tasks={}

local SCHEDULE_TIMER=0
local timer_start_timestamp_us
local TMR_NOW_WRAPAROUND=2147483648

local run_tasks, reset_timer

run_tasks=function()
    local timer_elapsed_time_us=tmr.now()-timer_start_timestamp_us
    if timer_elapsed_time_us<0 then
        timer_elapsed_time_us=timer_elapsed_time_us+TMR_NOW_WRAPAROUND
    end
    while tasks[1] do
        if timer_elapsed_time_us>=tasks[1][1]*1000 then
            timer_elapsed_time_us=timer_elapsed_time_us-tasks[1][1]*1000
            if tasks[1][2] then
                pcall(unpack(tasks[1],2,tasks[1].n+1))
            end
            table.remove(tasks,1)
        else
            tasks[1][1]=tasks[1][1]-timer_elapsed_time_us/1000
            break
        end
    end
    reset_timer()
end

reset_timer=function()
    if #tasks==0 then
        tmr.stop(SCHEDULE_TIMER)
    else
        local interval=tasks[1][1]
        if interval<1 then
            interval=1
        end
        timer_start_timestamp_us=tmr.now()
        tmr.alarm(SCHEDULE_TIMER,interval,0,run_tasks)
    end
end

local function schedule_task(task)
    local delay=task[1]
    local i=1
    while tasks[i] and tasks[i][1]<=delay do
        delay=delay-tasks[i][1]
        i=i+1
    end
    task[1]=delay
    if tasks[i] then
        tasks[i][1]=tasks[i][1]-delay
    end
    table.insert(tasks,i,task)
    if i==1 then
        reset_timer()
    end
end

local function unschedule_task(task)
    local at=task[1]
    local i=1
    while tasks[i] and tasks[i]~=task do
        i=i+1
    end
    if tasks[i] then
        if i==1 then
            tasks[i][2]=nil
        else
            local delay=tasks[i][1]
            table.remove(tasks,i)
            if tasks[i] then
                tasks[i][1]=tasks[i][1]+delay
            end
        end
    end
end

return function(...)
    local delay
    local arg1=...
    local argc=select("#",...)
    local function_position=1
    if type(arg1)=="number" then
        delay=arg1
        function_position=2
    else
        delay=1
    end
    local tag={}
    -- XXX: Working around https://github.com/elua/elua/issues/69
    local task={delay,n=argc-function_position+1}
    for i=function_position,argc do
        task[i-function_position+2]=select(i,...)
    end
    schedule_task(task)
    return function()
        unschedule_task(task)
    end
end
