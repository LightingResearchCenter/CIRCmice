% Main function for various statistical plots
function plotStatsMain(statOut, dataConstant, path, handles)

    %% "CIRC PRC"
    
        % Go through the following fields
%         fieldTagStructure = {'phasorMag', ...
%                              'phasorAngle', ...
%                              'ActivityMag', ...
%                              'ActivityAng', ...
%                              'Acentroid', ...
%                              'IS', ...
%                              'IV', ...
%                              'AcrophaseTime', ...
%                              'adjustedActivityAngle'};
        
        j = 1; % 2 - without cage cleaning days, 1 - with cage cleaning days 
        k = 1; % standard periodogram (Enright)
        lengthOfData = length(dataConstant.protocol.dates);
        
        fieldTagStructure = {'adjustedActivityAngle'};
        
        for i = 1 : length(fieldTagStructure)        
        
            %% Pick the correct data                 
                fieldTag = fieldTagStructure{i};
                [dataVecStructure, timing] = stat_createVectorFromCellStructure(statOut, [], j, k, lengthOfData, fieldTag);

                    % the structure now contains all the fields that the picked
                    % fieldName has, these could include for example
                    % .mean
                    % .SD
                    % .shapWilk_H
                    % check "stat_basicStatFuncs" to see the details
                    % dataVecStructure

            %% Plot the data
            plotStat_circPRC(dataVecStructure, fieldTag, timing, dataConstant.periodograms, j, k, path, handles)
            
            % close all
            % save the activity angle
            activityAngle = dataVecStructure;
        
        end
        
        % Quick plot
        fieldTagStructure = {'activityAroundLight'};
        fieldTag = fieldTagStructure{i};
        [dataVecStructure, timing] = stat_createVectorFromCellStructure(statOut, [], j, k, lengthOfData, fieldTag);
        
        % plot
        plotStat_activityAroundLight(dataVecStructure, activityAngle, fieldTag, timing, dataConstant.periodograms, j, k, path, handles)
                
    