classdef device_specs
    %
    %   Class:
    %   labjack.device.device_specs
    %
    %   https://support.labjack.com/docs/4-0-hardware-overview-t-series-datasheet

    properties (Abstract)
        name
        comm_types
        fixed_analog_in
        fixed_analog_out
    end

    methods
        function obj = device_specs()

        end
    end
end