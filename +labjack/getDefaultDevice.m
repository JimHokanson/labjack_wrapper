function c = getDefaultDevice()
%
%   c = labjack.getDefaultDevice()
%
%   

c = labjack.connection.getStreamingInstance('any','any','any');

end