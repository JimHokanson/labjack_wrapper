classdef stream_controller < handle
    %
    %   Class:
    %   labjack.stream_controller
    %
    %
    %   I'd like this to handle data reading and saving and potentially
    %   plotting.
    %
    %
    %   TODO: We need to be able to handle calibration here
    %
    %
    %   See Also
    %   --------
    %   
    %

    %   Writing data to disk, using parallel writing:
    %   https://github.com/JimHokanson/daq2_matlab/blob/master/%2Bdaq2/%2Binput/%40data_writer/data_writer.m
    %
    %   https://github.com/JimHokanson/daq2_matlab/blob/master/%2Bdaq2/%40input_data_handler/input_data_handler.m
    %
    %   

    properties
        h
        scan_rate
        read_frequency
        scans_per_read

        %This is a list of strings indicating which DAQ channel to stream
        %from
        chan_list
        
        %This is a list of names that indicates what is being recorded. It
        %should not 
        chan_aliases
        m
        b

        n_channels

        data

        %Whether currently streaming or not
        streaming = false
    end

    properties
        save_root
        save_prefix
        current_save_path
        temp_buffer
    end

    methods
        function obj = stream_controller(h,scan_rate,chan_list,options)
            %
            %   s = labjack.stream_controller(h,scan_rate,chan_list,options)
            %
            %
            %   Inputs
            %   ------
            %   scan_rate
            %   chan_list
            %   options

            arguments
                h
                scan_rate
                chan_list
                options.chan_aliases = {}
                options.read_frequency = 0.1
                options.scans_per_read = []
                options.save_root = ''
                options.save_prefix = ''
            end

            obj.h = h;
            obj.scan_rate = scan_rate;
            obj.chan_list = chan_list;
            
            if isempty(options.chan_aliases)
                obj.chan_aliases = chan_list;
            else
                obj.chan_aliases = options.chan_names;
            end

            obj.n_channels = length(chan_list);

            obj.m = ones(obj.n_channels,1);
            obj.b = zeros(obj.n_channels,1);
            obj.save_root = options.save_root;
            obj.save_prefix = options.save_prefix;
            
            if ~isempty(options.scans_per_read)
                obj.scans_per_read = options.scans_per_read;         
            else
                obj.scans_per_read = ceil(options.read_frequency*scan_rate);
            end

            obj.read_frequency = obj.scan_rate/obj.scans_per_read;
            
        end
        function startStream(obj)

            %TODO: Setup the save file

            %Create the save path and file (if requested)
            if ~isempty(obj.save_root)

            end

            obj.data = labjack.streaming.acquired_data(obj.chan_aliases,obj.scan_rate); 

            obj.temp_buffer = NET.createArray('System.Double', ...
                obj.n_channels*obj.scans_per_read);

            s = labjack.ljm.stream.startStream(obj.h,obj.scan_rate,...
                obj.scans_per_read,obj.chan_list);

            obj.streaming = true;
        end
        function readData(obj)
            %
            %   Set to buffer?
            %   Show new data?
            %   What about calibration?

            s = labjack.ljm.stream.eStreamRead(obj.h,obj.temp_buffer);

            temp_data = reshape(s.data,obj.n_channels,obj.scans_per_read)';

            temp_cell = cell(1,obj.n_channels);

            for i = 1:obj.n_channels
                temp_cell{i} = temp_data(:,i);
            end

            obj.data.addDAQData(temp_cell);

        end
        function stopStream(obj)
            labjack.ljm.stream.stopStream(obj.h)
        end
    end
end