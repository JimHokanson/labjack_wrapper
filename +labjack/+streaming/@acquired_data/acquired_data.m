classdef acquired_data < handle
    %
    %   Class:
    %   labjack.streaming.acquired_data
    %
    %   Requirements
    %   ------------
    %   This class relies on the following library:
    %   https://github.com/JimHokanson/plotBig_Matlab
    %
    %   The current design holds all acquired data in memory (although it 
    %   is also saved to disk as it is collected - elsewhere).
    %
    %   This class holds classes which have the data. It does not contain
    %   the raw data itself.
    %
    %   See Also
    %   --------
    %   big_plot.streaming_data
    %   labjack.stream_controller

    
    properties
        
        short_names
        
        %objects are field in the struct
        %Accessed via 'short_names' for the field
        daq_entries %struct
        
        %This is an array of objects. The order matches that of short_names
        %
        %   short_names{1} => daq_entries_array(1)
        daq_entries_array big_plot.streaming_data
        
        n_chans

        n_samples_added

    end
    
    properties (Dependent)
        daq_tmax
    end
    
    methods
        function value = get.daq_tmax(obj)
            value = obj.daq_entries_array(1).t_max;
        end
    end
    
    methods
        function obj = acquired_data(chan_names,scan_rate)
            %
            %   obj = labjack.streaming.acquired_data(fs,names,dec_rates,ip,n_seconds_init)
            %
            %   Inputs
            %   ------
            %   chan_names
            %   scan_rate
            %

            %This is for an initial allocation guess
            %
            %   This goes into the streaming objects. If it is exceeded
            %   the array will expand to accomodate.
            TRIAL_DURATION_S = 3600; %seconds
            
            obj.daq_entries = struct;
                        
            n_chans = length(chan_names);
            obj.short_names = chan_names;
            disp_names = chan_names;
            fs = scan_rate*ones(1,n_chans);
                        
            temp = cell(1,n_chans);
            
            obj.n_chans = n_chans;
            obj.n_samples_added = zeros(1,n_chans);
            for i = 1:n_chans
                %TODO: Eventually I want to use a local streaming_data class
                dt = 1/fs(i);
                n_samples_init = fs(i)*TRIAL_DURATION_S;
                new_entry = big_plot.streaming_data(dt,n_samples_init,'name',disp_names{i});
                obj.daq_entries.(obj.short_names{i}) = new_entry;
                temp{i} = new_entry;
            end
            obj.daq_entries_array = [temp{:}];
        end
    end
    methods
        function updateCalibration(obj,chan_index,m,b)
            obj.daq_entries_array(chan_index).setCalibration(m,b);
        end
        function addDAQData(obj,new_data)
            %
            %   addData(obj,new_data)
            %
            %   Inputs
            %   ------
            %   new_data : cell array
            %       New data should be decimated already.
            
            for i = 1:obj.n_chans
                %entry is object: big_plot.streaming_data
                obj.daq_entries_array(i).addData(new_data{i});
                obj.n_samples_added(i) = obj.n_samples_added(i) + length(new_data{i});
            end
        end
        function out = getChannel(obj,name)
            if isnumeric(name)
                index = name;
                name = obj.short_names{index};
            end
            out = obj.daq_entries.(name);
        end
    end
end
