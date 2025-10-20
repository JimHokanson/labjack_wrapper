classdef fio_chan < handle
    %
    %   Class:
    %   labjack.chans.fio_chan
    %
    %   See Also
    %   --------
    %   labjack.chans.fio_chans

    properties
        h
        chan_number
        chan_name
    end

    methods
        function obj = fio_chan(h,chan_number)
            obj.h = h;
            obj.chan_number = chan_number;
            obj.chan_name = sprintf('FIO%d',chan_number);
        end
        function setChanAsOutput(obj,default_value)

            obj.setChanValue(default_value);

        end
        function setChanAsInput(obj,chan)
            %This function has a side effect of setting direction
            obj.getChanValue(chan);
        end
        function value = getChanValue(obj)
            value = labjack.ljm.read.eReadName(obj.h,obj.chan_name);
        end
        function setChanValue(obj,is_high)
            %
            %   FIO#(0:7)

            %For now we'll use safe method. Eventually we may expose
            %non-safe method
            labjack.ljm.write.eWriteName(obj.h,obj.chan_name,is_high)
        end
        function setChanValueDelayed(obj,is_high,delay)
            h_timer = timer("ExecutionMode","singleShot","StartDelay",delay);
            h_timer.TimerFcn = @(~,~)h__executeDelayedSet(obj,is_high,h_timer);
            start(h_timer);
        end
    end
end

function h__executeDelayedSet(obj,value,h_timer)
    obj.setChanValue(value)
    stop(h_timer)
    delete(h_timer)
end