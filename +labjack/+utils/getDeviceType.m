function type = getDeviceType(handle)
%
%   type = labjack.utils.getDeviceType(handle)
%
%   Outputs
%   -------
%   type :
%       - T4
%       - T7
%       - T8
%

handle = labjack.utils.resolveHandle(handle);

%This is complex: e.g., My_T4_12896
%type = labjack.ljm.read.eReadNameString(handle, 'DEVICE_NAME_DEFAULT');

%deviceType = ljm.eReadNameString(handle, 'DEVICE_NAME_DEFAULT', 0);

[~, type_number, ~, ~, ~, ~, ~] = ...
    LabJack.LJM.GetHandleInfo(handle, 0, 0, 0, 0, 0, 0);

c = LabJack.('LJM+CONSTANTS');

%-------------------------------------------
switch type_number
    case c.dtT4
        type = 'T4';
    case c.dtT7
        type = 'T7';
    case c.dtT8
        type = 'T8';
    case c.dtDIGIT
        type = 'Digit';
    otherwise
        error('Unrecognized device type')
end

end