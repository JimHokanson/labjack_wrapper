function c = getDefaultDevice()
%
%   c = labjack.getDefaultDevice()
%
%   Outputs
%   -------
%   labjack.connection


%TODO: Do we want to support non-streaming
%
%   - maybe pass in a flag if we don't want streaming

c = labjack.connection.getStreamingInstance('any','any','any');

end