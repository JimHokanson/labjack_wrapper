%streaming notes
%
%   https://support.labjack.com/docs/ljm-stream-functions-ljm-user-s-guide
%
%
%   STREAM_START_TIME_STAMP - T7 or T8 only
%
%
%   STREAM_BUFFER_SIZE_BYTES
%
%   T8:
%   Max size is 262144. Default size is 4096.
%   T7:
%   Max size is 32768. Default size is 4096.
%   T4:
%   Max size is 32768. Default size is 8192.
%
%
%
%   LJM_eStreamStart
%   https://support.labjack.com/docs/estreamstart-ljm-user-s-guide
%
%   int Handle,
%   int ScansPerRead,
%   int NumAddresses,
%   const int * aScanList,
%   double * ScanRate)
%
%
%   %  This states that how often you get data can be calculated by the
%   %  following
%   eStreamRead frequency = ScanRate / ScansPerRead



%   ScansPerRead : # of samples that should be returned when a read
%                  call is made. My guess is that things are blocking
%                  until the number of reads is available.
%   ScanRate : Sampling frequency (I believe)
%
%   

%{
%Stream reads will be stored in aData. Needs to be at least
    %NumAddresses*ScansPerRead in size.
    aData = NET.createArray('System.Double', numAddresses*scansPerRead);
    
    %Configure the negative channels for single ended readings.
    aNames = NET.createArray('System.String', 16);
    aValues = NET.createArray('System.Double', 16);

    aNames(1) = [char(aScanListNames(1)) '_NEGATIVE_CH'];
    aValues(1) = 1;
    aNames(2) = [char(aScanListNames(2)) '_NEGATIVE_CH'];
    aValues(2) = handles.LJM_CONSTANTS.GND;
    aNames(3) = 'DIO_EF_CLOCK0_ENABLE';
    aValues(3) =0;
    aNames(4) = 'DIO0_EF_ENABLE';
    aValues(4) = 0;
    aNames(5) = 'DIO1_EF_ENABLE';
    aValues(5) = 0;
    
    aNames(6) = 'DIO_EF_CLOCK0_ENABLE';
    aValues(6) =0;
    
    aNames(7) ='DIO_EF_CLOCK0_DIVISOR';
    aValues(7)= clock_divisor;
    aNames(8) = 'DIO0_EF_INDEX';
    aValues(8) = 3;
    aNames(9) = 'DIO0_EF_ENABLE';
    aValues(9) = 1;

    aNames(10) = 'DIO1_EF_INDEX';
    aValues(10) = 3;
    aNames(11) = 'DIO1_EF_ENABLE';
    aValues(11) = 1;

    
    aNames(12) = 'DIO_EF_CLOCK0_ENABLE';
    aValues(12) =1;
    aNames(13) = [char(aScanListNames(9)) '_NEGATIVE_CH'];
    aValues(13) =handles.LJM_CONSTANTS.GND;
    aNames(14) = [char(aScanListNames(10)) '_NEGATIVE_CH'];
    aValues(14) =handles.LJM_CONSTANTS.GND;
     aNames(15) = [char(aScanListNames(1)) '_RESOLUTION_INDEX'];
    aValues(15) = 0;
    
     aNames(16) = [char(aScanListNames(1)) '_RANGE'];
    aValues(16) = 1.0;

    
    LabJack.LJM.eWriteNames(handles.handle, 16, aNames, aValues, 0);

%}


