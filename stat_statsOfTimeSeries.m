function statOut = stat_statsOfTimeSeries(data_timeSeries, path, handles)

    % returns the different field names stored to the structure dataOut
    names = fieldnames(data_timeSeries);
    
        % remove the settings field
        namesId = strfind(names, 'settings');
        j = 0; % accumulator
        for i = 1 : length(names)            
            if isempty(namesId{i})
                names2{j+1,1} = names{i};
                j = j + 1;
            end
        end
        names = names2;
    
    for i = 1 : length(names)        
        
        %% Calculate the basic statistical values 
        % like MEAN, SD, Gaussian/Homogeneity of the distribution
        % of the vectors for each field name (angle, amplitude, etc.)    
        
        % define alpha thresholds for Shapiro-Wilk and Bartlett K
        shapWilk_pThr = handles.shapWilk_pThreshold;
        bartlett_pThr = handles.bartlett_pThreshold;
                
        % Now check if is timeseries or not
        istimeseries = isa(data_timeSeries.(names{i}), 'timeseries');
       
        if istimeseries == 1                
            statOut.(names{i}) = stat_basicStatTimeSeries(data_timeSeries.(names{i}), path.statFunc, shapWilk_pThr, bartlett_pThr);
        else
            rowVectorIn = (data_timeSeries.(names{i}))'; % transpose manually     
            statOut.(names{i}) = stat_basicStatFuncs(rowVectorIn, path.statFunc, shapWilk_pThr, bartlett_pThr);
            statOut.(names{i}).origData = rowVectorIn; % save the vector also 
        end
        cd(path.code)
        
    end

    % Assign the settings
    statOut.settings = data_timeSeries.settings;