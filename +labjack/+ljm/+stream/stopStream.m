function stopStream(handle)
%
%   ljm.stream.stopStream();

handle = labjack.utils.resolveHandle(handle);

ljm_error = LabJack.LJM.eStreamStop(handle);
    
end