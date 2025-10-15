classdef ljm_handle < handle
    %
    %   Class:
    %   labjack.ljm_handle
    %
    %   See Also
    %   --------
    %   labjack.connection

    properties
        value
    end

    methods
        function obj = ljm_handle(value)
            obj.value  = value;
        end
        function delete(obj)
            LabJack.LJM.Close(obj.value);
        end
    end
end