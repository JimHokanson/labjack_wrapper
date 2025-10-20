function s = eStreamRead(handle,buffer,n_chans,options)
%
%   s = labjack.ljm.stream.eStreamRead(handle,buffer)
%
%   Inputs
%   ------
%   handle
%   buffer
%   n_chans
%
%   Optional Inputs
%   ---------------
%   clear_backlog : default true
%       If true, this will do a more extended read to try and clear the
%       buffer. Note, it will not do this recursively, the amount of
%       extended reading is checked only once after the first read. For
%       example, let's say each read is 1/10th of a second of data, and
%       you wait two seconds before making this call. You'll have a backup
%       of roughly two seconds worth of data. If this setting is true,
%       rather than reading only 1/10th of a second of data, it will
%       try and read all of the two seconds. However, at the end of that
%       process it may be time to read even more data. This function will
%       not do more reads. This is meant to prevent too much blocking of
%       other processes.
%   data_format : default 'cell'
%       - 'cell' - each channel is a cell of size [n_samples x 1]
%       - 'matrix' - returns matrix of size [n_samples x n_chans]
%       - 'array' - returns data in shape [1 x n_samples_total] where the
%       channels are interleaved. For 3 channels, for example, the 1st
%       channel consists of the 1st, 4th, 7th, etc. samples. Channel 2
%       consists of the 2nd, 5th, 8th, etc. samples.
%   logger : labjack.ljm.stream.stream_read_logger
%       Pass this in and performance characteristics will be logged.
%
%   Outputs
%   -------
%   device_scan_backlog :
%       # of scans left in the device buffer
%   ljm_scan_backlog
%       # of scans left in the LJM buffer (on the computer)
%   data : 
%       Format depends on 'data_format' option. In general the data are
%       returned as type 'double'
%
%   See Also
%   --------
%   labjack.ljm.stream.createStreamBuffer
%   labjack.ljm.startStream
%
%   Documentation
%   -------------
%   https://support.labjack.com/docs/estreamread-ljm-user-s-guide
%
%   If slow:
%   https://support.labjack.com/docs/streaming-ljm_estreamread-gives-error-1301-ljme_lj

arguments
    handle
    buffer
    n_chans

    %At some point I thought about trying to do more reads in
    %one go. Note this is a different interface than NI (I think), where
    %you ask how many samples are available, and then you read that amount.
    options.clear_backlog = true

    %- matrix
    %- cell
    %- raw? eventually, would be tricky with backlog clearing
    %- array - no change
    options.data_format = 'cell'; 
    options.logger = []
end

start_time = datetime('now');

h1 = tic;

handle = labjack.utils.resolveHandle(handle);

%We always do at least one read
%-----------------------------------------------------
h2 = tic;
[~, device_scan_backlog, ljm_scan_backlog] = LabJack.LJM.eStreamRead( ...
                handle, buffer, 0, 0);
t_elapsed_read = toc(h2);

n_samples_per_read = buffer.Length;

%We do more reads if asked to further clear the buffer.
%-----------------------------------------------------------
%- Note we don't check this recursively
if ljm_scan_backlog > n_samples_per_read
    n_reads = floor(ljm_scan_backlog/n_samples_per_read);
    n_reads2 = n_reads + 1;

    output_data = zeros(1,n_samples_per_read*n_reads2);
    output_data(1:n_samples_per_read) = double(buffer);

    I2 = n_samples_per_read;
    for i = 1:n_reads
        h = tic;
        [~, device_scan_backlog, ljm_scan_backlog] = LabJack.LJM.eStreamRead( ...
                handle, buffer, 0, 0);
        t_elapsed_read = toc(h) + t_elapsed_read;

        I1 = I2 + 1;
        I2 = I2 + n_samples_per_read;
        output_data(I1:I2) = double(buffer);
    end
else
    output_data = double(buffer);
    n_reads2 = 2;
end

%Output handling
%------------------------------------------------------------
s = struct;
s.device_scan_backlog = device_scan_backlog;
s.ljm_scan_backlog = ljm_scan_backlog;

switch options.data_format
    case 'array'
        %done
    case 'matrix'
        chan_samples_per_read = n_samples_per_read/n_chans;
        output_data = reshape(output_data,n_chans,chan_samples_per_read)';
    case 'cell'
        temp = cell(1,n_chans);
        for i = 1:n_chans
            temp{i} = output_data(i:n_chans:end)';
        end
        output_data = temp;
end

s.data = output_data;

t_elapsed_total = toc(h1);

if ~isempty(options.logger)
    options.logger.addEntry(start_time,n_reads2,t_elapsed_read,t_elapsed_total);
end

% totalScans = totalScans + scansPerRead;
% 
% % Count the skipped samples which are indicated by -9999
% % values. Skipped samples occur after a device's stream buffer
% % overflows and are reported after auto-recover mode ends.
% % When streaming at faster scan rates in MATLAB, try counting
% % the skipped packets outside your eStreamRead loop if you are
% % getting skipped samples/scan.
% curSkippedSamples = sum(double(aData) == -9999.0);
% totalSkippedSamples = totalSkippedSamples + curSkippedSamples;
% 
% disp(['eStreamRead ' num2str(i)])
% fprintf('  1st scan out of %d : ', scansPerRead)
% for j = 1:numAddresses
%     fprintf('%s = %.4f ', char(aScanListNames(j)), aData(j))
% end
% fprintf('\n')
% disp(['  Scans Skipped = ' ...
%       num2str(curSkippedSamples/numAddresses) ...
%       ', Scan Backlogs: Device = ' num2str(device_scan_backlog) ...
%       ', LJM = ' num2str(ljmScanBL)])


end