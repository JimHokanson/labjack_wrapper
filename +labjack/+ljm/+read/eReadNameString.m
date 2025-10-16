function value = eReadNameString(handle, name)
%
%   value = labjack.ljm.read.eReadNameString(handle, name)
%
%   https://support.labjack.com/docs/ereadnamestring

[ljmError, value] = LabJack.LJM.eReadNameString(handle, name, '');


end