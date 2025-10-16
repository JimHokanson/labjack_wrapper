function dn_strings = mlStringsToDotNet(ml_strings)
%
%   dn_strings = labjack.conv.mlStringsToDotNet(ml_strings)

if iscell(ml_strings)
    n_strings = length(ml_strings);
    dn_strings = NET.createArray('System.String', n_strings);
    for i = 1:n_strings
        dn_strings(i) = ml_strings{i};
    end
elseif isstring(ml_strings)
    n_strings = length(ml_strings);
    dn_strings = NET.createArray('System.String', n_strings);
    for i = 1:n_strings
        dn_strings(i) = ml_strings(i);
    end
else
    error('Unrecognized datatype: %s',class(ml_strings))

end

end