classdef stream_controller < handle
    %
    %
    %   I'd like this to handle data reading and saving and potentially
    %   plotting.
    %
    %
    %   TODO: We need to be able to handle calibration here

    properties
        h
        scan_rate
        read_frequency
        scans_per_per_read
        chan_list
        streaming = false
    end

    methods
        function obj = stream_controller(h,scan_rate,chan_list,options)

            arguments
                h
                scan_rate
                chan_list
                options.read_frequency = 0.1
                options.scans_per_read = []
                options.save_root = ''
                options.save_prefix = ''
            end

            obj.h = h;
            obj.scan_rate = scan_rate;
            obj.chan_list = chan_list;
            
            if ~isempty(options.scans_per_read)
                obj.scans_per_per_read = options.scans_per_read;         
            else
                obj.scans_per_per_read = ceil(options.read_frequency*scan_rate);
            end

            obj.read_frequency = obj.scan_rate/obj.scans_per_per_read;
            
        end
        function startStream(obj)

            %TODO: Setup the save file

            s = labjack.ljm.startStream(obj.h,obj.scan_rate,scans_per_read,chan_list);

            obj.streaming = true;
        end
        function stopStream(obj)

        end
    end
end