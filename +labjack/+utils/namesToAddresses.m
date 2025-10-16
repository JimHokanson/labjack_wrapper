function addresses = namesToAddresses(names,convert)
%
%   addresses = labjack.utils.namesToAddresses(names)
%
%
%   https://support.labjack.com/docs/namestoaddresses-ljm-user-s-guide
%
%   Example
%   -------
%   addresses = labjack.utils.namesToAddresses({'AIN0','AIN1'})

%{
LJM_ERROR_RETURN LJM_NamesToAddresses(
int NumFrames,
const char ** aNames,
int * aAddresses,
int * aTypes)
%}

if nargin == 1
    convert = false;
end

n_addresses = length(names);

scan_list_names = labjack.conv.mlStringsToDotNet(names);
scan_list_addresses = NET.createArray('System.Int32', n_addresses);
dummy_types = NET.createArray('System.Int32', n_addresses);

ljm_error = LabJack.LJM.NamesToAddresses(n_addresses, scan_list_names, ...
    scan_list_addresses, dummy_types);

if convert
    addresses = double(scan_list_addresses);
else
    addresses = scan_list_addresses;
end

end

%{
    aScanListNames = NET.createArray('System.String', numAddresses); %Scan list names to stream.
    aScanListNames(1) = 'AIN0';    %torque low
    aScanListNames(2) = 'AIN1';     %torque high
    aScanListNames(3) = 'CORE_TIMER';   %clock
    aScanListNames(4) = 'STREAM_DATA_CAPTURE_16';   %clock overflow
    aScanListNames(5) = 'DIO1_EF_READ_A_AND_RESET';           %Engine Rpm
    aScanListNames(6) = 'STREAM_DATA_CAPTURE_16';   %Engine RPM overflow
    aScanListNames(7) = 'DIO0_EF_READ_A_AND_RESET';           %secondary RPM
    aScanListNames(8) = 'STREAM_DATA_CAPTURE_16';   %secondary RPM overflow
    aScanListNames(9) = 'AIN2';  
    aScanListNames(10) = 'AIN3'; 
    
  
    
    logvalue=handles.log;
    aScanList = NET.createArray('System.Int32', numAddresses); %Scan list addresses to stream.
    aTypes = NET.createArray('System.Int32', numAddresses); %Dummy array for aTypes parameter
    LabJack.LJM.NamesToAddresses(numAddresses, aScanListNames, aScanList, aTypes);

%}