function [iBefore, iAfter, iBoth, linIndices, iCell] = import_defineBinIndices(binLength, SRate, light)
                
        %         if nargin == 0
        %             load values.mat
        %         else
        %             save values.mat
        %         end
        
        nrOfNonNanValues = length(light(~isnan(light)));
        nrOfNonZeros     = length(light(light == 1));

        % binLength - bin length in minutes 
        % SRate     - samples per day
        % light     - boolean vector of light stimulus
        
        % convert sampling rate to "samples / minutes"
        f_s = SRate / 24 / 60; % should be 1 sample per minute
        
        onsets  = zeros(length(light),1);
        offsets = zeros(length(light),1);
        
        iBefore = zeros(length(light),1);
        iAfter  = zeros(length(light),1);        
        
        onsetsFound     = 0;
        offsetsFound    = 0;
        
        if nrOfNonZeros > 0
        
            % Find light onsets and offsets
            for ij = 2 : (length(light) - 1)

                % find the "rising edges", i.e. light onsets
                if light(ij) == 1 && light(ij-1) == 0 && light(ij+1) == 1          

                    onsets(ij) = 1;
                    onsetsFound = onsetsFound + 1;

                    % set the preceding values to one, number of values
                    % specified by the binLength * f_s
                    numberOfValues = binLength * f_s;

                    ind1 = ij - numberOfValues - 1;
                    ind2 = ij - 1;

                    % check that the start index won't be negative          
                    if ind1 < 1
                        ind1 = 1;
                        warning('  start index would have been negative, corrected to 1')
                    end
                    iBefore(ind1:ind2) = 1;

                    % if you later are interested if there are differences
                    % between the activity after 1st, 5th, 11th, etc. light
                    % pulse these values are also saved to                 
                    iCell.before{onsetsFound} = [(ij - numberOfValues - 1) (ij - 1)];

                % find the "falling edges", i.e. light offsets
                elseif light(ij) == 1 && light(ij-1) == 1 && light(ij+1) == 0       

                    offsets(ij) = 1;
                    offsetsFound = offsetsFound + 1;

                    % set the following values to one, number of values
                    % specified by the binLength * f_s
                    numberOfValues = binLength * f_s;

                    ind1 = ij + 1;
                    ind2 = ij + numberOfValues + 1;

                    % check that the end index won't be bigger than the length
                    % of the vector
                    if ind2 > length(light)
                        ind2 = length(light);
                        warning('end index would have over length of light vector, truncated to END')
                    end                
                    iAfter(ind1:ind2) = 1;

                    % if you later are interested if there are differences
                    % between the activity after 1st, 5th, 11th, etc. light
                    % pulse these values are also saved to 
                    iCell.after{onsetsFound} = [(ij + 1) (ij + numberOfValues + 1)];

                end

            end
        else
            % goesHere = 1
            iCell.after  = NaN;
            iCell.before = NaN;
        end
        
        % Indices of both can be just summed together now
        try
            iBoth = iBefore + iAfter;
        catch err            
            % truncate
            if length(iBefore) < length(iAfter)
                iAfter = iAfter(1:length(light));
            elseif length(iBefore) > length(iAfter)
                iBefore = iBefore(1:length(light));
            end
            iBoth = iBefore + iAfter;
        end
        
        % find the indices corresponding to the ones
        linIndices.onsetIndices  = find(onsets == 1);
        linIndices.offsetIndices = find(offsets == 1);
        
        linIndices.iBeforeIndices  = find(iBefore == 1);
        linIndices.iAfterIndices   = find(iAfter == 1);
        linIndices.iBothIndices    = find(iBoth == 1);
        
        % so these contain only the indices that have the values of an
        % interest wheres iBoth, iBefore, iAfter are boolean vector
        % indicating where the values of interest are
