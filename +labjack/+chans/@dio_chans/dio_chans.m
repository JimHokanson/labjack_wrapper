classdef dio_chans < handle
    %
    %   labjack.chans.fio_chans
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
    %           DIO_ANALOG_ENABLE
    %   


    properties (Hidden)
        h labjack.ljm_handle
    end



    methods
        function obj = dio_chans(h)
            obj.h = h;
        end
        function value = getDirectionAll(obj)
            temp = labjack.ljm.read.eReadName(obj.h.value,'FIO_DIRECTION');
            temp = uint8(temp);
            value = double(bitget(temp,1:8));
        end
        function setChanDirection(obj,chan,make_output)
            %
            %
            %   No set single chan direction option
            %
            %   f.setChanDirection(7,true);

            bits = obj.getDirectionAll();
            %- chans are labeled 0 through 7
            %- but the array is 1:8
            bits(chan+1) = make_output;

            value = uint8(double(bits)*(2.^(0:7))'); 
            h2 = obj.h.value;
            labjack.ljm.write.eWriteName(h2,'FIO_DIRECTION',value)
        end
        function setChanValue(obj,chan,value)
            %
            %   FIO#(0:7)

            %For now we'll use safe method. Eventually we may expose
            %non-safe method
            labjack.ljm.write.eWriteName(h2,'FIO_DIRECTION',value)
        end
    end
end