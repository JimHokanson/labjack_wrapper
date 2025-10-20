classdef fio_chans < handle
    %
    %   labjack.chans.fio_chans
    %
    %   FIO channels
    %   - can act as analog inputs?
    %   - can act as counters
    %   - can act as digital inputs or outputs
    %
    %
    %   state
    %   direction
    %
    %   Properties
    %   ----------------
    %   FIO#(0:7) - Read or set the state of 1 bit of digital I/O. Also
    %   configures the direction to input or output. Read 0=Low AND 1=High.
    %   Write 0=Low AND 1=High.
    %
    %   FIO_STATE - Read or write the state of the 8 bits of FIO in a
    %   single binary-encoded value. 0=Low AND 1=High. Does not configure
    %   direction. Reading lines set to output returns the current logic
    %   levels on the terminals, not necessarily the output states written.
    %   The upper 8-bits of this value are inhibits.
    %
    %   FIO_EIO_STATE - Read or write the state of the 16 bits of FIO-EIO
    %   in a single binary-encoded value. 0=Low AND 1=High. Does not
    %   configure direction. Reading lines set to output returns the
    %   current logic levels on the terminals, not necessarily the output
    %   states written.
    %
    %   FIO_DIRECTION - Read or write the direction of the 8 bits of FIO in
    %   a single binary-encoded value. 0=Input and 1=Output. The upper
    %   8-bits of this value are inhibits.
    %
    %
    %   Questions
    %   ---------
    %   1) How do you change this to an analog input?
    %   
    %       It appears that you just start reading from the channel and it
    %       becomes an analog input.
    %


    properties (Hidden)
        h labjack.ljm_handle
    end

    %{
        c = labjack.connection.getStreamingInstance('any','any','any');
        f = c.fio_chans

        %??? Why is this not working?
        f.setChanDirection(7,'high');

        
        f.setChanValue(7,1)   
    %}

    methods
        function obj = fio_chans(h)
            obj.h = h;
        end
        function value = getDirectionAll(obj)
            temp = labjack.ljm.read.eReadName(obj.h,'FIO_DIRECTION');
            temp = uint8(temp);
            value = double(bitget(temp,1:8));
        end
        function setChanAsOutput(obj,chan,default_value)
            
            obj.setChanValue(chan,default_value);
        end
        function setChanAsInput(obj,chan)
            %This function has a side effect of setting direction
            obj.getChanValue(chan);
        end

        %This didn't see to be working
        % % % function setChanDirection(obj,chan,direction,default_value)
        % % %     %
        % % %     %
        % % %     %   No set single chan direction option
        % % %     %
        % % %     %   f.setChanDirection(7,true);
        % % %     %
        % % %     %   TODO: Change to in/out as an input, not false/true
        % % % 
        % % %     direction = char(direction); %in case a string
        % % %     make_output = lower(direction(1)) == 'o';
        % % % 
        % % %     bits = obj.getDirectionAll();
        % % %     bits(chan) = make_output;
        % % % 
        % % %     value = uint8(double(bits)*(2.^(0:7))'); 
        % % %     h2 = obj.h.value;
        % % %     labjack.ljm.write.eWriteName(h2,'FIO_DIRECTION',value)
        % % % end
        function value = getChanValue(obj,chan)
            name = sprintf('FIO%d',chan);
            value = labjack.ljm.read.eReadName(obj.h,name);
        end
        function setChanValue(obj,chan,is_high)
            %
            %   FIO#(0:7)

            name = sprintf('FIO%d',chan);

            %For now we'll use safe method. Eventually we may expose
            %non-safe method
            labjack.ljm.write.eWriteName(obj.h,name,is_high)
        end
    end
end