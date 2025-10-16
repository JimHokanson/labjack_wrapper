%streaming notes
%
%   https://support.labjack.com/docs/ljm-stream-functions-ljm-user-s-guide
%
%
%   STREAM_START_TIME_STAMP - T7 or T8 only
%
%
%   STREAM_BUFFER_SIZE_BYTES
%
%   T8:
%   Max size is 262144. Default size is 4096.
%   T7:
%   Max size is 32768. Default size is 4096.
%   T4:
%   Max size is 32768. Default size is 8192.
%
%
%
%   LJM_eStreamStart
%   https://support.labjack.com/docs/estreamstart-ljm-user-s-guide
%
%   int Handle,
%   int ScansPerRead,
%   int NumAddresses,
%   const int * aScanList,
%   double * ScanRate)
%
%   eStreamRead frequency = ScanRate / ScansPerRead


