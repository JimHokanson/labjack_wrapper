function t = getHostTick()
%
%   t = labjack.ljm.timing.getHostTick
%
%   Outputs
%   -------
%   t : int64
%       Clock time in microseconds. Meant to be used to measure
%       elapsed time.

labjack.utils.initAssembly

t = LabJack.LJM.GetHostTick();

end