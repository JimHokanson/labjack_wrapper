function handle_out = resolveHandle(handle_in)
%X This function makes sure the correct handle is passed to the LJM functions
%
%   handle_out = labjack.utils.resolveHandle(handle_in)
%
%   See Also
%   --------
%   labjack.ljm_handle

%?? Check for isobject instead?
if ~isnumeric(handle_in)
    handle_out = handle_in.value;
else
    handle_out = handle_in;
end

end