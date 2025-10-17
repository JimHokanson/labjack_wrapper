function buffer = createStreamBuffer(n_chans,n_scans_per_read)
%
%
%   buffer = labjack.ljm.stream.createStreamBuffer(n_chans,n_scans_per_read);
%
%   This is an input that is needed when reading streaming data.
%
%   See Also
%   --------
%   labjack.ljm.startStream

buffer = NET.createArray('System.Double', n_chans * n_scans_per_read);


end