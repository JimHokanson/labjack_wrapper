classdef stream_read_logger < handle
    %
    %   Class:
    %   labjack.ljm.stream.stream_read_logger
    %
    %   Stores performance characteristics from labjack.ljm.stream.eStreamRead
    %
    %   TODO: Show an example with this being used.
    %
    %   

    properties
        %This wraps
        I = 0
        %This doesn't
        count = 0

        start_time
        dt_starts
        read_index
        n_reads

        %Note, this can be dependent on the rate of having data available.
        %If data are not available, this will block for a while.
        read_time

        elapsed_time

        last_start
    end

    methods
        function obj = stream_read_logger(options)

            arguments
                options.array_size = 1000;
            end

            n = options.array_size;
            obj.read_index = zeros(n,1);
            obj.n_reads = zeros(n,1);
            obj.read_time = zeros(n,1);
            obj.elapsed_time = zeros(n,1);
            obj.start_time = NaT(n,1);
            obj.dt_starts = zeros(n,1);

        end
        function addEntry(obj,start_time,n_reads,read_time,elapsed_time)
            I2 = obj.I + 1;
            if I2 > length(obj.read_index)
                I2 = 1;
            end
            obj.I = I2;
            obj.count = obj.count + 1;
            obj.start_time(I2) = start_time;

            if obj.count == 1
                obj.last_start = start_time;
            else
                obj.dt_starts(I2) = milliseconds(start_time - obj.last_start);
                obj.last_start = start_time;
            end

            obj.read_index(I2) = obj.count;
            obj.n_reads(I2) = n_reads;
            obj.read_time(I2) = read_time;
            obj.elapsed_time(I2) = elapsed_time;
        end
        function t = getTable(obj)
            %
            %   Improvements
            %   ------------
            %   1) truncate unused
            %   2) If wrapped, unwrap for display (using circular buffer for storage)
            %
            start_time = obj.start_time;
            dt_starts_ms = obj.dt_starts;
            read_index = obj.read_index;
            n_reads = obj.n_reads;
            read_time = obj.read_time;
            elapsed_time = obj.elapsed_time;

            t = table(start_time,dt_starts_ms,read_index,n_reads,read_time,elapsed_time);

        end
    end
end