% Picks the data from the cell and structure based on what you want to plot
function [dataVecStructure, timing] = stat_createVectorFromCellStructure(statOut, i, j, k, lengthOfData, fieldName)

    % i = 2; % for different kind of conditions, like "with cage cleaning,
    %       % without cage cleaning, "sleep/orNot analysis", etc.
    % j = 2; % without cage cleaning days
    % k = 1; % standard periodogram (Enright)
    
    % statOut{i}

    %% check the input of what to vary when extracting data
    % the one that is empty is the variable to be varied while the others
    % are kept const
    if isempty(i)
        iMin = 1; 
        iMax = lengthOfData;
        jMin = j; jMax = j;
        kMin = k; kMax = k;       

        %         % remove the origData field
        %         namesId = strfind(names, 'origData');
        %         j = 0; % accumulator
        %         for i = 1 : length(names)            
        %             if isempty(namesId{i})
        %                 names2{j+1,1} = names{i};
        %                 j = j + 1;
        %             end
        %         end
        %         names = names2;
        
        % Goes through all the different start dates from Circdates.txt
        for i = iMin : iMax
        
            % for different kind of conditions, like "with cage cleaning,
            % without cage cleaning, "sleep/orNot analysis", etc.
            for j = jMin : jMax

                 % number of different kind of periodogram calculations
                for k = kMin : kMax    

                    % get all the fields out from the particular fieldName
                    % e.g. .mean, .SD, etc.SS
                    % disp([i j k])
                    names = fieldnames(statOut{i}{j,k}.(fieldName))
                    
                    for ij = 1 : length(names)
                        
                        if strfind(names{ij}, 'origData') % this is a vector
                            dataVecStructure.(names{ij}){i} = statOut{i}{j,k}.(fieldName).(names{ij});
                            
                        else % these are scalars
                            
                            % disp('scalar values')
                            %{
                            i
                            j
                            k
                            fieldName
                            names
                            ij
                            names{ij}                            
                            %}
                            dataVecStructure.(names{ij})(i) = statOut{i}{j,k}.(fieldName).(names{ij});
                        end
                    end

                    timing(i,:) = statOut{i}{j,k}.settings.timing;
                    %timing(i,:) = NaN;

                end
            end
        end


    % variation of the condition (cage cleaning, etc.)
    elseif isempty(j)
        jMin = 1; 
        jMax = lengthOfData;
        iMin = i; iMax = i;
        kMin = k; kMax = k;        
        
        errordlg('Not yet implemented')

    % variation of periodogram
    elseif isempty(k)
        kMin = 1; 
        kMax = lengthOfData;
        jMin = j; jMax = j;
        iMin = i; iMax = i;        

        errordlg('Not yet implemented')
        
    else
        warndlg('Not a single loop variable is empty? What do you want to do?')
    end