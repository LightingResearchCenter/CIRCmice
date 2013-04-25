% Prints the matrix to screen and writes it to a text file
function printAndWriteTheData(ind, dataOut, dateIn, lengthOfDataOut, fileNames, path, handles)

    disp(' ')
    disp('FROM printAndWriteTheData.m:')

    disp(' '); disp(handles.dataOutDescription{ind}); disp(datestr(dateIn)); disp(' ')
    header = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s','PhasorMag','PhasorAngle','ActivityMag','ActivityAngle','LightAngle','Acrophase time','IS','IV','Adjusted Activity Angle');
    disp(header)
    dataMatrix = zeros(length(fileNames),9);
    for i = 1:length(fileNames)
        
        % numerical data
        dataMatrix(i,1:9) = [dataOut{ind}.phasorMag(i), dataOut{ind}.phasorAngle(i), ...
                            dataOut{ind}.ActivityMag(i), dataOut{ind}.ActivityAng(i),...
                            dataOut{ind}.LightAng(i), dataOut{ind}.AcrophaseTime(i),...
                            dataOut{ind}.IS(i),dataOut{ind}.IV(i),...
                            dataOut{ind}.adjustedActivityAngle(i)];

        % as string to be displayed on screen, old way
        dataStr{i} = sprintf('%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f',...
            dataOut{ind}.phasorMag(i), dataOut{ind}.phasorAngle(i), ...
            dataOut{ind}.ActivityMag(i), dataOut{ind}.ActivityAng(i),...
            dataOut{ind}.LightAng(i), dataOut{ind}.AcrophaseTime(i),...
            dataOut{ind}.IS(i),dataOut{ind}.IV(i),...
            dataOut{ind}.adjustedActivityAngle(i));

        disp(dataStr{i})
    end

%% Write the data to disk as well
for j = 1 : lengthOfDataOut
    % define the filename out
    fileNameOut = ['dataOut_', path.idFolder, '_start', datestr(dateIn), '_',  strrep(handles.dataOutDescription{j}, ' ', ''), '.txt'];
    cd(path.outputTxt)
    dlmwrite(fileNameOut,header,'Delimiter', '') % header
    dlmwrite(fileNameOut,dataMatrix,'-append', 'Delimiter', '\t'); % data        
    cd(path.code)
end