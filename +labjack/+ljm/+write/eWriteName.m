function eWriteName(h,name,value)
%
%   labjack.ljm.write.eWriteName(h,name,value)
%
%   https://support.labjack.com/docs/ewritename-ljm-user-s-guide

    h = labjack.utils.resolveHandle(h);

    ljm_error = LabJack.LJM.eWriteName(h,name,double(value));

end