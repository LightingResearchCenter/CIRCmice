% Main function for the various statistical analysis that you want to do
function statOut = statisticalAnalysisMain(dataOut, dataIn, dataConstant, path, handles)

    
    %% Go through the data sets 
    
        % preallocate memory
        statOut = cell(length(dataConstant.protocol.dates),1);
        
            disp(' ')
            disp(['statOut preallocated with ', num2str(length(statOut)), ' rows'])
            disp(' ')
    
    % Goes through all the different start dates from Circdates.txt
    for i = 1 : length(dataConstant.protocol.dates)
        
        disp(['   Stats of date: ', datestr(dataConstant.protocol.dates(i))])
        
        % for different kind of conditions, like "with cage cleaning,
        % without cage cleaning, "sleep/orNot analysis", etc.
        for j = 1 : length(handles.dataOutDescription)
        
             % number of different kind of periodogram calculations
            for k = 1 : length(dataConstant.periodograms)
                
                % switch a bit the cell composition, now as the i is the
                % number of dates, while j and k can be modified just for
                % "curiosity", then maybe this seems more logical
                
                %% Calculate the stats of the matrices, mean/SD/Gaussian/Homogeneity/etc.
                % of each parameter (field name, e.g. angle, amplitude, etc.)
%                 if strcmp(names{i}, 'activityAroundLight')
%                     fieldOfAround = 'both';
%                     statOut{i}{j,k} = stat_statsOfMatrices(dataOut{i,k}{j}, path, fieldOfAround, handles);
%                 else
                    fieldOfAround = [];
                    statOut{i}{j,k} = stat_statsOfMatrices(dataOut{i,k}{j}, path, fieldOfAround, handles);
%                 end
                
            end
            
        end
        
    end