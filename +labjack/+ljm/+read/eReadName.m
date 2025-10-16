function value = eReadName(h,name)
%
%   value = labjack.ljm.read.eReadName(h,name)
%
%   https://support.labjack.com/docs/ereadname-ljm-user-s-guide

    [ljmError, value] = LabJack.LJM.eReadName(h,name,0);

end