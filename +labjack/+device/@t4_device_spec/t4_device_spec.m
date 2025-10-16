classdef t4_device_spec < labjack.device.device_specs
    %
    %   Class:
    %   labjack.device.t4_device_spec
    %
    %   https://support.labjack.com/docs/14-3-1-analog-inputs-t4-t-series-datasheet

    properties
        name = "T4"
        comm_types = ["USB" "Ethernet"]
        
        %These are high voltage +/- 10V
        %Where are AIN4-AI11 (low voltage) at?

        fixed_analog_in = ["AIN0" "AIN1" "AIN2" "AIN3"]


        fixed_analog_out = ["DAC0" "DAC1"]
    end

    methods
        function obj = t4_device_spec()
        end
    end
end