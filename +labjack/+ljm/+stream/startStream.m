function startStream()

        numAddresses = aScanList.Length;
        [~, scanRate] = LabJack.LJM.eStreamStart(handle, scansPerRead, ...
            numAddresses, aScanList, scanRate);

end