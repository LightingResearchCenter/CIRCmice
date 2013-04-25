% Calculates the stats for the TIMESERIES objects
function statOut_TS = statisticalAnalysisMain_TS(data_timeSeries, dataConstant, path, handles)
    
    if nargin == 0
        load('TS-stats.mat')
    else
        save('TS-stats.mat')
    end
        
    %% Go through the data sets 
    
        % preallocate memory
        statOut = cell(length(dataConstant.protocol.dates),1);
    
    % Goes through all the different start dates from Circdates.txt
    for i = 1 : length(dataConstant.protocol.dates)
        
        disp(['   TS Stats of date: ', datestr(dataConstant.protocol.dates(i))])
        
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
                statOut_TS{i}{j,k} = stat_statsOfTimeSeries(data_timeSeries{i,k}{j}, path, handles);
                
            end
            
        end
        
    end