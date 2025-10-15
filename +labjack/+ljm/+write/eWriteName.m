function eWriteName(h,name,value)
%
%   labjack.ljm.write.eWriteName(h,name,value)
%
%   https://support.labjack.com/docs/ewritename-ljm-user-s-guide

    [ljmError] = LabJack.LJM.eWriteName(h,name,double(value));

end