classdef connection < handle
    %
    %   Class:
    %   labjack.connection
    %
    %   https://support.labjack.com/docs/opens-ljm-user-s-guide
    %
    %   See Also
    %   --------
    %   labjack.ljm.info.device_info
    %   labjack.ljm.ljm_methods

    properties
        h %labjack.ljm_handle
        is_streaming_type
        fio_chans
        analog_input_settings
    end

    properties (Dependent)
        device_info
    end

    properties (Hidden)
        h_device_info
    end

    methods 
        function value = get.device_info(obj)
            if isempty(obj.h_device_info)
                obj.h_device_info = labjack.ljm.info.device_info(obj.h);
            end
            value = obj.h_device_info;
        end
    end

    methods (Static)
        function obj = getStreamingInstance(device_type,connection_type,identifier)
            %
            %
            %   c = labjack.connection.getStreamingInstance('any','any','any');

            arguments
                device_type 
                connection_type 
                identifier 
            end 

            %{
device_type
            "ANY" - Open any supported LabJack device type
            "T4" - Open a T4 device
            "T7" - Open a T7 device
            "T8" - Open a T8 device
            "TSERIES" - Open any T-series device
            "DIGIT" - Open a Digit-series device
            %}


            %{
            connection_type: "ANY", "USB", "TCP", "ETHERNET", or "WIFI"
            %}

            %{
                use a serial number, IP address, or device name
            %}


            % %TODO: This needs to be changed to a weak reference
            % persistent h2

            labjack.utils.initAssembly();
            
            [ljm_error, handle] = LabJack.LJM.OpenS(device_type,connection_type,identifier,0);
            %TODO: Support error checking

            % if isempty(h2)
            %     h2 = containers.Map('KeyType','int32','ValueType','any');
            % end

            % if isKey(h2,handle)
            %     obj = h2(handle);
            % else
                streaming = true;
                obj = labjack.connection(handle,streaming);
            %     h2(handle) = obj;
            % end
        end
        
    end

    methods
        function obj = connection(handle,streaming)
            
            obj.h = labjack.ljm_handle(handle);
            obj.is_streaming_type = streaming;
            obj.fio_chans = labjack.chans.fio_chans(obj.h);
            obj.analog_input_settings = labjack.chans.analog_input_settings(obj.h);
            
        end
        function getDevice(obj)
            % 
            %   I eventually wanted to return a device specific object
            %   that would provide device specific info
            %
            %   e.g., a T4 object
        end
        % function s = startStream(obj,scan_rate,scans_per_read,chan_list)
        %     %
        %     %   Inputs
        %     %   ------
        %     %   scan_rate : 
        %     %       # of samples per second
        %     %   scans_per_read :
        %     %       # of samples per read
        %     %   scan_list : addresses or names  
        %     %
        %     %
        % 
        %     s = labjack.ljm.startStream(obj.h,scan_rate,scans_per_read,chan_list);
        % end
        % function stopStream(obj)
        %     ljm.stream.stopStream(obj.h);
        % end
    end
end