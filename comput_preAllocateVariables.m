function dataOut = comput_preAllocateVariables(fileNames)

    % preallocate the variables    
    % these are the values stored to dataOut then after calculations
    dataOut.phasorMag   = zeros(1,length(fileNames));
    dataOut.phasorAngle = zeros(1,length(fileNames));  
    dataOut.ActivityMag = zeros(1,length(fileNames));
    dataOut.ActivityAng = zeros(1,length(fileNames));
    dataOut.phaseAngle  = zeros(1,length(fileNames));
    dataOut.lightAng    = zeros(1,length(fileNames));
    dataOut.Acentroid   = zeros(1,length(fileNames));
    dataOut.IS          = zeros(1,length(fileNames));
    dataOut.IV          = zeros(1,length(fileNames));
    dataOut.Activity2CenterTime = zeros(1,length(fileNames));
    dataOut.adjustedActivityAngle = zeros(1,length(fileNames));
    