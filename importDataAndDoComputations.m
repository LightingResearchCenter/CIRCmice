% imports the data from raw files
function [dataOut, dataIn, data_timeSeries] = importDataAndDoComputations(dateIn, fileNames, path, dataConstant, handles)
    

    %% find the timing based on the date, use the subfunction
    timing = findTimingsBasedOnDate(dateIn, ...
                                    dataConstant.protocol.dates, ...
                                    dataConstant.protocol.circData);    
                                
    % manually defined now, so if one wants to start excluding data based
    % on some other rules in addition to cleaning days, for example like
    % when the rodents were sleeping or not (during light), you could
    % implement that here then    
    lengthOfDataOut = length(handles.dataOutDescription);
    dataOut = cell(lengthOfDataOut,1);
    dataIn = cell(lengthOfDataOut,1);
        
            % add here the analysis on whether asleep or not?
            close all
   
    %% Go through the files
    
        for j = 1 : lengthOfDataOut
            
            disp(['  ', handles.dataOutDescription{j}])

            for i = 1 : length(fileNames)

                % Print screen the status message
                disp(['    processing "', fileNames{i}, '", #', num2str(i), '/', num2str(length(fileNames))])

                % Import the data
                [dataAWDtrim, dataSupplem, SRate, light, time, activityTS] = importOneAWDfile(path, fileNames{i}, i, dateIn, dataConstant, timing, handles); 

                    if handles.settings.plotIndividualData == 1
                        % Plot the imported data     
                        [fig(1), handles] = plotIndividualMouse(time, light, dataAWDtrim, fileNames, dateIn, i, j, handles);
                    end

                % Compute parameters of one mouse           
                [dataOut, dataIn] = computeTheParameters(activityTS, dataIn, dataOut, dateIn, time, light, dataAWDtrim, dataSupplem, fileNames, dataConstant.cleaningDates.dates, SRate, timing, i, j, handles);        
               
            end
            
            % Create TIMESERIES OBJECTs
            % [data_timeSeries{j}, dataOut{j}] = compute_createTimeSeries(dataOut{j}, timing, handles);

        end
    
    %% Plot the histograms of activity angles
    % the index (1 = with cage cleaning, 2 = wo cage cleaning, etc.)
        ind = 2; % 2 for wo cage cleaning
        Ndays = timing(1);
        plotHistogramOfAllMice([], dataOut{ind}. ActivityAng, 'Activity Angle [h]', ind, dateIn, Ndays, path, handles)  

            % Petteri: Are these useful? (22 Jan 2013)
                %M = [phaseAngle',Acentroid',IS',IV',phasorMag',phasorAngle'];
                %M2 = [phaseAngle2',Acentroid2',IS2',IV2',phasorMag2',phasorAngle2']; % Removing cage cleaning
                %M3 = [ActivityMag2' ActivityAng2']; % Removing cage cleaning

    %% Print & Write the matrix of data  
    
        % the index (1 = with cage cleaning, 2 = wo cage cleaning, etc.)
        ind = 2;    
        printAndWriteTheData(ind, dataOut, dateIn, lengthOfDataOut, fileNames, path, handles)
        
          
%% find the row when the dates are the same (in the loop and in the text file)
function timing = findTimingsBasedOnDate(dateCurrent, dateProtocol, circData)
    ind = dateCurrent == dateProtocol;
    timing = circData(ind,:);