function s = startStream(handle,scan_rate,scans_per_read,scan_list)
%
%
%   s = labjack.ljm.startStream(handle,scan_rate,scans_per_read,scan_list)
%
%   
%
%   Inputs
%   ------
%   handle
%   scan_rate : 
%       # of samples per second
%   scans_per_read :
%       # of samples per read
%   scan_list : addresses or names    
%   
%   Example
%   -------
%   
%
%   https://support.labjack.com/docs/estreamstart-ljm-user-s-guide

handle = labjack.utils.resolveHandle(handle);

if isstring(scan_list) || iscell(scan_list)
    convert_flag = false;
    scan_list = labjack.utils.namesToAddresses(scan_list,convert_flag);
end

n_addresses = aScanList.Length;
[~, scan_rate] = LabJack.LJM.eStreamStart(handle, scans_per_read, ...
            n_addresses, scan_list, scan_rate);

s = struct;
s.scan_rate = scan_rate;

end