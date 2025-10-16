classdef analog_input_settings < handle
    %
    %   Class:
    %   labjack.chans.analog_input_settings

    properties (Hidden)
        h
    end

    methods
        function obj = analog_input_settings()
        end
        function getCurrentSettings(obj,chan)
            s = struct;
        end
        function getRange(obj,chan)

        end
        function getRangeOptions(obj,chan)
            h2 = obj.h.value;
            type = labjack.utils.getDeviceType(h2);
            switch lower(char(type))
                case 't4'
                case 't7'
                case 't8'
            end
        end
        function setRange(obj,chan)

            %{
            The range/span of a single analog input. Select the desired range by writing a value from the device specific list.
            Default: 0
            T8-specific:
            Valid values/ranges: 
            0.0=Default → ±11V. 
            11.0 → ±11.0, 
            9.6 → ±9.6, 
            4.8 → ±4.8, 
            2.4 → ±2.4, 
            1.2 → ±1.2, 
            0.6 → ±0.6, 
            0.3 → ±0.3, 
            0.15 → ±0.15, 
            0.075 → ±0.075, 
            0.036 → ±0.036, and 
            0.018 → ±0.018
            
            T7-specific:
            Valid values/ranges: 
            0.0=Default → ±10V. 
            10.0 → ±10V, 
            1.0 → ±1V, 
            0.1 → ±0.1V
            0.01 → ±0.01V.
            
            T4-specific:
            Valid values/ranges: 
            0.0=Default  
                0-2.5 V on LV lines 
                ±10 V on HV lines.
            %}

        end
    end
end

%{
AIN#(0:249)	0	FLOAT32	R	AIN, CORE	
% - reads analog value

AIN#(0:149)_EF_READ_A	7000	FLOAT32	R	AIN_EF, AIN, CORE	
AIN#(0:149)_EF_READ_B	7300	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_READ_C	7600	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_READ_D	7900	FLOAT32	R	AIN_EF, AIN	
AIN#(0:149)_EF_INDEX	9000	UINT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_A	9300	UINT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_B	9600	UINT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_C	9900	UINT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_D	10200	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_E	10500	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_F	10800	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_G	11100	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_H	11400	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_I	11700	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:149)_EF_CONFIG_J	12000	FLOAT32	R / W	AIN_EF, AIN	
AIN#(0:249)_RANGE	40000	FLOAT32	R / W	AIN	
AIN#(0:249)_NEGATIVE_CH	41000	UINT16	R / W	AIN	
AIN#(0:249)_RESOLUTION_INDEX	41500	UINT16	R / W	AIN	
AIN#(0:249)_SETTLING_US	42000	FLOAT32	R / W	AIN	
AIN_ALL_RANGE	43900	FLOAT32	R / W	AIN	
AIN_ALL_NEGATIVE_CH	43902	UINT16	R / W	AIN	
AIN_ALL_RESOLUTION_INDEX	43903	UINT16	R / W	AIN	
AIN_ALL_SETTLING_US	43904	FLOAT32	R / W	AIN	
AIN_ALL_EF_INDEX (also known as: AIN_ALL_EF_TYPE)	43906	UINT32	R / W	AIN	
AIN#(0:249)_BINARY (also known as: AIN#(0:249)_BIN)	50000	UINT32	R	AIN	
TEMPERATURE_AIR_K	60050	FLOAT32	R	AIN, CORE	
TEMPERATURE_DEVICE_K	
%}