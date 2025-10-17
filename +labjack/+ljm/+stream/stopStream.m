function stopStream(handle)
%
%   labkjack.ljm.stream.stopStream(handle)

handle = labjack.utils.resolveHandle(handle);

ljm_error = LabJack.LJM.eStreamStop(handle);
    
end