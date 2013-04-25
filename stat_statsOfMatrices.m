% Calculates the means of the different variables stored in the output
% matrix (each matrix for one "analysis date"
function statOut = stat_statsOfMatrices(dataOut, path, fieldOfAround, handles)

    statOut = [];    
    
    % returns the different field names stored to the structure dataOut
    names = fieldnames(dataOut);
    
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
        
        if strcmp(names{i}, 'activityAroundLight')
            
            % to save same time, onyl analyze the last bin (60 min)
            ind = 1;
            % here = 1
            % dataOut.(names{i})
            %% rowVectorIn = (dataOut.(names{i}).both.mean(:,ind))'; % transpose manually
            rowVectorIn = (dataOut.(names{i}).both.mean(:,ind))'; % transpose manually use before, after or both to look at activity around probing pulse
                % now actually the SD of the original data points for each
                % individual mouse is ignored, include it somewhere like
                % root(SD1^2 + SD2^2) or something
                    % e.g. (dataOut.(names{i}).both.SD(:,ind))
                
                % this is the vector containing the mean of the activity
                % around the light pulses, one value corresponding to
                % individual cage, additionally you could pull out the SD
                % or n of the samples here, see
                % comput_MainAllCalculations.m for details
                
                % the ind correspond to the vector stored in 
                % handles.binsAroundLightPulse
                % (see initVariables)
        else
            rowVectorIn = (dataOut.(names{i}))';
        end
              

        [statOut.(names{i}), rowVectorIn] = stat_basicStatFuncs(rowVectorIn, path.statFunc, shapWilk_pThr, bartlett_pThr);
        statOut.(names{i}).origData = rowVectorIn; % save the vector also
        cd(path.code)
        
    end

    % Assign the settings
    statOut.settings = dataOut.settings;