function varargout = initAssembly()
%
%   
%   labjack.utils.initAssembly

persistent ljm

if isempty(ljm)
    ljm = NET.addAssembly('LabJack.LJM');
end

if nargout
    varargout{1} = ljm;
end


%{
ljmAsm = NET.addAssembly('LabJack.LJM');

t = ljmAsm.AssemblyHandle.GetType('LabJack.LJM+CONSTANTS');
LJM_CONSTANTS = System.Activator.CreateInstance(t);
%}

end