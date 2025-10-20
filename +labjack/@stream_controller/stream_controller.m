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
    %   labjack.streaming.acquired_data
    %

    %   Writing data to disk, using parallel writing: (NOT IMPLEMENTED HERE)
    %   https://github.com/JimHokanson/daq2_matlab/blob/master/%2Bdaq2/%2Binput/%40data_writer/data_writer.m
    %   https://github.com/JimHokanson/daq2_matlab/blob/master/%2Bdaq2/%2Binput/parallel_data_writer_worker.m
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
        %
        %   cellstr
        chan_aliases

        %These two are not currently used. Placed on disk and in streaming
        %data instead.
        m
        b
        n_calibrations

        n_channels

        data labjack.streaming.acquired_data

        %Whether currently streaming or not
        streaming = false

        %This gets passed to the LJM call for returning data
        temp_buffer

        stream_read_logger
    end

    properties
        save_root
        save_prefix
        current_save_path
        h_mat %matlab.io.MatFile (not allowed to be uncommented)
        
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

                %You can specify scans_per_read to override the
                %read_frequency. Or you can update the read_frequency
                options.read_frequency = 10
                options.scans_per_read = []

                options.save_root = ''
                options.save_prefix = ''
            end

            if isa(h,'labjack.connection')
                h = h.h;
            end

            obj.h = h;
            obj.scan_rate = scan_rate;
            obj.chan_list = cellstr(chan_list);
            
            if isempty(options.chan_aliases)
                obj.chan_aliases = obj.chan_list;
            else
                obj.chan_aliases = cellstr(options.chan_aliases);
            end

            obj.n_channels = length(chan_list);

            obj.m = ones(obj.n_channels,1);
            obj.b = zeros(obj.n_channels,1);
            obj.n_calibrations = zeros(obj.n_channels,1);

            obj.save_root = options.save_root;
            obj.save_prefix = options.save_prefix;

            if ~isempty(obj.save_root)
                if ~exist(options.save_root,'dir')
                    error('Specified save directory does not exist')
                end
                d = datetime("now");
                d.Format = "yyyy_MM_dd__hh_mm_ss";
                file_name = sprintf('%s__data_%s.mat',obj.save_prefix,string(d));
                obj.current_save_path = fullfile(obj.save_root,file_name);
                
            end
            
            if ~isempty(options.scans_per_read)
                obj.scans_per_read = options.scans_per_read;         
            else
                scan_period = 1/options.read_frequency;
                obj.scans_per_read = ceil(scan_period*scan_rate);
            end

            obj.read_frequency = obj.scan_rate/obj.scans_per_read;

            obj.stream_read_logger = labjack.ljm.stream.stream_read_logger;
            
        end
        function s = startStream(obj)

            %TODO: Setup the save file

            %Create the save path and file (if requested)
            if ~isempty(obj.current_save_path)
                obj.h_mat = matlab.io.MatFile(obj.current_save_path);
                obj.h_mat.calibration = struct;
                obj.h_mat.data = struct;
            end

            obj.data = labjack.streaming.acquired_data(obj.chan_aliases,obj.scan_rate); 

            obj.temp_buffer = NET.createArray('System.Double', ...
                obj.n_channels*obj.scans_per_read);

            chan_out = obj.data.daq_entries_array;

            s = labjack.ljm.stream.startStream(obj.h,obj.scan_rate,...
                obj.scans_per_read,obj.chan_list);

            s.channels = chan_out;

            obj.streaming = true;
        end
        function updateCalibration(obj,chan_index,m,b)
            %
            %   ASSUMES that the stream has started and that the mat file
            %   has been created.
            %   

            obj.n_calibrations(chan_index) = obj.n_calibrations(chan_index) + 1;

            I = obj.n_calibrations(chan_index);

            n1 = obj.data.n_samples_added;

            %This is the next sample to which the calibration technically 
            %applies. Note, streaming will update for all.
            cal_index = n1(chan_index)+1;

            current_name = obj.chan_aliases{chan_index};
            current_name = ['calibration__' current_name];

            %Is this really needed with two forms?
            if I == 1
                obj.h_mat.([current_name '_m']) = m;
                obj.h_mat.([current_name '_b']) = b;
                obj.h_mat.([current_name '_index']) = cal_index;
            else
                obj.h_mat.([current_name '_m'])(I,1) = m;
                obj.h_mat.([current_name '_b'])(I,1) = b;
                obj.h_mat.([current_name '_index'])(I,1) = cal_index;
            end

            %Update streaming data
            obj.data.updateCalibration(chan_index,m,b);

        end
        function readData(obj)
            %
            %   Set to buffer?
            %   Show new data?
            %   What about calibration?
            %
            %   Observed Errors
            %   ---------------
            %   %This can occur if you haven't started streaming
            %   Message: LJME_NULL_POINTER
            %   Source: LabJack.LJM
            %   HelpLink: None
            %
            %

            if ~obj.streaming
                error('Must call startStream first')
            end

            %Retrieve data from LabJack
            %--------------------------------------------------------------
            s = labjack.ljm.stream.eStreamRead(...
                obj.h,obj.temp_buffer,obj.n_channels,...
                'logger',obj.stream_read_logger);

            n1 = obj.data.n_samples_added;

            %Add data to streaming/plotting object
            %--------------------------------------------------------------
            %labjack.streaming.acquired_data
            %
            %   Two effects:
            %   1) Adds data to streaming objects. 
            %   2) Plots if visible (handled inside streaming object)
            obj.data.addDAQData(s.data);

            n2 = obj.data.n_samples_added;

            %Saving of data to disk
            %--------------------------------------------------------------
            if ~isempty(obj.current_save_path)
                for i = 1:obj.n_channels
                    current_name = obj.chan_aliases{i};

                    current_name = ['data__' current_name]; %#ok<AGROW>
                    if n1(i) == 0
                        %h_mat: matlab.io.MatFile
                        % if i == 1
                        %     obj.h_mat.data = struct;
                        % end
                        obj.h_mat.(current_name) = s.data{i};
                    else
                        obj.h_mat.(current_name)(n1(i)+1:n2(i),1) = s.data{i};
                    end
                end
            end            
        end
        function chan = getChannel(obj,name_or_index)
           chan = obj.data.getChannel(name_or_index);
        end
        function stopStream(obj)
            labjack.ljm.stream.stopStream(obj.h)
        end
    end
end