function s = eStreamRead(handle,buffer)
%
%   s = labjack.ljm.stream.eStreamRead(handle,buffer)
%
%   Inputs
%   ------
%   handle
%   buffer
%
%   See Also
%   --------
%   labjack.ljm.stream.createStreamBuffer
%   labjack.ljm.startStream

%Work in progress

%   https://support.labjack.com/docs/estreamread-ljm-user-s-guide

handle = labjack.utils.resolveHandle(handle);

[~, device_scan_backlog, ljm_scan_backlog] = LabJack.LJM.eStreamRead( ...
                handle, buffer, 0, 0);

s = struct;
s.device_scan_backlog = device_scan_backlog;
s.ljm_scan_backlog = ljm_scan_backlog;

%TODO: I think we want to reshape to be [samples x channels]
s.data = double(buffer);



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