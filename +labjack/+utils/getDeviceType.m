function type = getDeviceType(handle)
%
%   
%
%   Outputs
%   -------
%   type : 
%       - T4
%       - T7
%       - T8
%   

type = labjack.ljm.read.eReadNameString(handle, 'DEVICE_NAME_DEFAULT');

%deviceType = ljm.eReadNameString(handle, 'DEVICE_NAME_DEFAULT', 0);


end