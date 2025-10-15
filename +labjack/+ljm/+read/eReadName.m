function value = eReadName(h,name)
%
%   labjack.ljm.read.eReadName
%
%   https://support.labjack.com/docs/ereadname-ljm-user-s-guide

    [ljmError, value] = LabJack.LJM.eReadName(h,name,0);

end