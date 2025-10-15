%labjack.ljm.ljm_methods


%Modbus Map
%-----------------------------
%
%   https://support.labjack.com/docs/3-1-modbus-map-t-series-datasheet

AddressToType    %Retrieves the data type for a given Modbus register address.
            
AddressesToMBFB  %Creates a Modbus Feedback (MBFB) packet. This packet can be sent to the device using LJM_MBFBComm.

AddressesToTypes  %Retrieves multiple data types for given Modbus register addresses.
               
ByteArrayToFLOAT32               

ByteArrayToINT32                 

ByteArrayToUINT16                

ByteArrayToUINT32                

CleanInfo                        

CleanInterval                    

Close                            

CloseAll                         

ErrorToString                    

FLOAT32ToByteArray               

GetDeepSearchInfo    
    %For finding LabJack devices in IP range

GetHandleInfo                    
    %Provides information on a device


GetHostTick      
    %Timing

GetHostTick32Bit                 

GetSpecificIPsInfo               

GetStreamTCPReceiveBufferStatus  

INT32ToByteArray 

IPToNumber 

InitializeAperiodicStreamOut

ListAll   

ListAllExtended  

ListAllS    

LoadConfigurationFile  

LoadConstants     

LoadConstantsFromFile

LoadConstantsFromString   

Log   

LookupConstantName  

LookupConstantValue 

MACToNumber 

MBFBComm   

NameToAddress   

NamesToAddresses   

NumberToIP     

NumberToMAC 

Open     

OpenS    

PeriodicStreamOut  

ReadLibraryConfigS               
ReadLibraryConfigStringS         
ReadRaw                          
ReferenceEquals                  
ResetLog                         
StartInterval                    
StreamBurst                      
TCVoltsToTemp                    
UINT16ToByteArray                
UINT32ToByteArray                
UpdateValues                     
WaitForNextInterval              
WriteAperiodicStreamOut          
WriteLibraryConfigS              
WriteLibraryConfigStringS        
WriteRaw 


%--------------------------------------------------------------------------

eAddresses  %Write/Read multiple d, specified by address. This function 
% is designed to condense communication into arrays. Moreover, consecutive
% values can be accessed by specifying a starting address, and a number of
% values.
%
%   This is a crazy function that tries to do a bunch of things at once.
%
%   Apparently it can help with overhead on the bus. Their example is:
%   Read analog inputs 0 through 7, set DAC0 to 4.6V, read FIO4
%
%   https://support.labjack.com/docs/eaddresses-ljm-user-s-guide
%
%   **** Same as eNames, but uses non-friendly numeric addresseses
%           - maybe this is faster to convert to non-friendly once
%           and then use this instead of eNames?


eNames    %Write/Read multiple device registers in one command, each 
% register specified by name. This function is designed to condense
% communication into arrays. Moreover, consecutive values can be accessed
% by specifying a starting register name, and a number of values.
%
%   https://support.labjack.com/docs/enames-ljm-user-s-guide
%
%   Read analog inputs 0 through 2, set DAC0 to 4.6V, and read FIO4
%
%   **** Same as eAddresses, but uses friendly names


eReadAddress      



eReadAddressArray    



eReadAddressByteArray            


eReadAddressString               

eReadAddresses  

eReadName     
%- can read single analog input
%- can read properties - e.g., serial number of a device
%   
%   https://support.labjack.com/docs/ereadname-ljm-user-s-guide


eReadNameArray                   

eReadNameByteArray               

eReadNameString                  

eReadNames   %Reads multiple registers in one command
%- can be used for:
%  - settings
%  - analog inputs
%  - digital inputs?

eStreamRead                      

eStreamStart                     

eStreamStop                      

eWriteAddress                    
eWriteAddressArray               
eWriteAddressByteArray           
eWriteAddressString              
eWriteAddresses      


eWriteName   %Write one value, specified by name.
%- write analog output to DAC
%- 
     


eWriteNameArray                  
eWriteNameByteArray              
eWriteNameString                 
eWriteNames        