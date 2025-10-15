classdef device_info < handle
    %
    %   Class:
    %   labjack.ljm.info.device_info
    %
    %
    %   https://support.labjack.com/docs/gethandleinfo-ljm-user-s-guide

    properties
        device_type
        device_type_int
        connection_type
        connection_type_int
        serial_number
        ip_address
        port
        max_bytes_MB
    end

    methods
        function obj = device_info(handle)
            %
            %   d = labjack.ljm.info.device_info(handle)

            labjack.utils.initAssembly();

            [~, devType, connType, serNum, ipAddr, port, maxBytesMB] = ...
                LabJack.LJM.GetHandleInfo(handle, 0, 0, 0, 0, 0, 0);
            
            %TODO: Handle the error

            obj.serial_number = serNum;
            obj.ip_address = ipAddr;
            obj.port = port;
            obj.max_bytes_MB = maxBytesMB;

            c = LabJack.('LJM+CONSTANTS');

            %-------------------------------------------
            obj.device_type_int = devType;
            switch devType
                case c.dtT4
                    obj.device_type = 'T4';
                case c.dtT7
                    obj.device_type = 'T7';
                case c.dtT8
                    obj.device_type = 'T8';
                case c.dtDIGIT
                    obj.device_type = 'Digit';
                otherwise
                    error('Unrecognized device type')
            end

            %--------------------------------------------
            obj.connection_type_int = connType;
            switch connType
                case c.ctUSB
                    obj.connection_type = 'USB';
                case c.ctETHERNET
                    obj.connection_type = 'ethernet';
                case c.ctWIFI
                    obj.connection_type = 'WiFi';
            end

            %--------------------------------------------
        end
    end
end