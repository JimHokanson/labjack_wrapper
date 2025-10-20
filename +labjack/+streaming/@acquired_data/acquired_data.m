classdef acquired_data < handle
    %
    %   Class:
    %   labjack.streaming.acquired_data
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
        % raw_session
        % perf_mon
        % cmd_window
        
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


        non_daq_entries %fields of type ... NYI
        non_daq_xy_entries %fields of type
        %daq2.data.non_daq_streaming_xy
        ip
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
            %   fs :
            %       Sampling Rate of highest rate channel
            %   names :
            %       Names of the channels being recorded
            %   dec_rates :
            %       Decimation rates for each channel
            %   ip : interactive_plot
            %   n_seconds_init :
            %       How many seconds to allocate for each channel
            %

            TRIAL_DURATION_S = 3600; %seconds
            
            % obj.raw_session = raw_session;
            % obj.perf_mon = perf_mon;
            % obj.cmd_window = cmd_window;
            
            %obj.ip = ip;
            
            %ai_chans = raw_session.getAnalogInputChans();
            
            obj.daq_entries = struct;
            obj.non_daq_entries= struct;
            obj.non_daq_xy_entries = struct;
            
            %TODO: Add on daq__ to avoid any name conflicts ...
            
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
        % function iplot = plotDAQData(obj,varargin)
        %     %
        %     %   TODO: This is a work in progress ...
        %     %
        %     %   Optional Inputs
        %     %   ---------------
        %     %   h_fig :
        %     %   position : 
        %     %
        %     %   See Also
        %     %   --------
        % 
        %     in.h_fig = [];
        %     in.position = [];
        %     in = sl.in.processVarargin(in,varargin);
        % 
        %     if isempty(in.h_fig) || ~isvalid(in.h_fig)
        %         f = figure;
        %         %Only position if it didn't exist
        % 
        %         if ~isempty(in.position)
        %             set(f,'Position',in.position);
        %         end
        %     else
        %         f = in.h_fig;
        %         clf
        %         figure(in.h_fig);
        %     end
        % 
        % 
        %     ax = cell(obj.n_chans,1);
        %     for i = 1:obj.n_chans
        %         ax{i} = subplot(obj.n_chans,1,i);
        %         plotBig(obj.daq_entries_array(i));
        %     end
        % 
        %     names = fieldnames(obj.daq_entries);
        %     %names = regexprep(names,'_','\n');
        %     iplot = interactive_plot(f,ax,...
        %         'streaming',true,...
        %         'axes_names',names,...
        %         'comments',true);
        % 
        % end
        % function xy_obj = getXYData(obj,name)
        %     %
        %     %   xy_obj = getXYData(obj,name)
        %     %
        %     %   Output
        %     %   ------
        %     %   xy_obj : daq2.data.non_daq_streaming_xy
        % 
        %     if isfield(obj.non_daq_xy_entries,name)
        %        xy_obj = obj.non_daq_xy_entries.(name);
        %     else
        %        xy_obj = [];
        %     end
        % end
        % function addNonDaqData(obj,name,data)
        % 
        % end
        % function addNonDaqXYData(obj,name,y_data,x_data)
        %     %non_daq_xy_map
        % 
        %     if isfield(obj.non_daq_xy_entries,name)
        %        xy_obj = obj.non_daq_xy_entries.(name);
        %     else
        %        xy_obj = daq2.data.non_daq_streaming_xy(name);
        %        obj.non_daq_xy_entries.(name) = xy_obj;
        %     end
        % 
        %     xy_obj.addSamples(y_data,x_data);
        % 
        % end
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
