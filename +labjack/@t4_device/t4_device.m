classdef t4_device < handle
    %
    %   labjack.t4_device

    % 4x 12-bit high voltage (±10V) analog inputs.
    % 50k samples/s max input stream rate.
    % 2x 10-bit 0-5V analog outputs.
    % 8x flexible I/O lines (digital I/O, 0-2.5V analog input).
    % 8x additional digital I/O.
    % 10x Counter, timers, 2 PWMs, quadrature, SPI, I2C, and more.

%Looks like Kipling is hardcoding
%https://github.com/labjack/labjack_kipling/blob/0a857ad036bffeeb2ae1c8b34ad92eaab82fb8b6/ljswitchboard-module_manager/lib/switchboard_modules/dashboard_v2/deviceControlLocationDefinitions.js


%https://support.labjack.com/docs/3-1-modbus-map-t-series-datasheet
%https://github.com/labjack/ljm_constants/blob/master/LabJack/LJM/ljm_constants.json
%Tags 
%- AIN
%- AIN_EF
%- ASYNCH
%- CONFIG - 40
%   POWER_CORE
%   POWER_USB
%   ...
%   PRODUCT_ID
%   HARDWARE_VERSION
%   FIRMWARE_VERSION
%   BOOTLOADER_VERSION
%   HARDWARE_INSTALLED
%   DEVICE_RESET_DBG_REG
%   SERIAL_NUMBER
%   DEVICE_NAME_DEFAULT
%   ...
%- CORE
%- DAC
%- DIO
%- DIO_EF
%- ETHERNET
%- FILE_IO
%- I2C
%- INTFLASH
%- LUA
%- ONEWIRE
%- RTC
%- SBUS
%- SPI
%- STREAM
%- TDAC
%- UART
%- USER_RAM
%- WATCHDOG - 16
%- WIFI - none



%https://labjack.com/blogs/faq/what-are-digital-i-o-io-d-dio-fio-eio-cio-mio
%
%On this device
%CIO - type: DIO
%EIO - type: flex
%FIO - type: flex (digital input, digital output, analog input)
%
%   In addition:
%   - 2 can be configured as timers
%   - 2 can be configured as counters
%

%Left
%--------
%SGND
%SPC
%SGND
%VS
%
%: This bank can connect to a LJTick-DAC - https://labjack.com/products/ljtick-dac
%FIO7 - either analog or digital
%FIO6
%GND
%VS
%
%FIO5
%FIO4
%GND
%VS
%
%Right
%----------
%VS
%GND
%DAC0
%DAC1
%
%VS
%GND
%AIN2
%AIN3
%
%VS
%GND
%AIN0
%AIN1
%
%Serial Port
%------------
%Digital IO - 8 lines
%
%Vs
%CIO1
%CIO3
%EIO0
%EIO2
%EIO4
%EIO6
%GND
%
%CIO0
%CIO2
%GND
%EIO1
%EI03
%EIO5
%EIO7

    properties
        fio_chans
    end

    methods
        function obj = t4_device()
        end
    end
end