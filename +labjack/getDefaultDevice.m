function c = getDefaultDevice()
%
%   c = labjack.getDefaultDevice()
%
%   


%TODO: Do we want to support non-streaming
%
%   - maybe pass in a flag if we don't want streaming

c = labjack.connection.getStreamingInstance('any','any','any');

end