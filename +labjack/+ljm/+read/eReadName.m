function value = eReadName(h,name)
%
%   value = labjack.ljm.read.eReadName(h,name)
%
%   See Also
%   --------
%   labjack.ljm.write.eWriteName
%   
%
%   Documentation
%   -------------
%   https://support.labjack.com/docs/ereadname-ljm-user-s-guide

    h = labjack.utils.resolveHandle(h);

    [ljm_error, value] = LabJack.LJM.eReadName(h,name,0);

end