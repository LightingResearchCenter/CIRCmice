% function computes various parameters from activity counts
function [dataOut, dataIn] = computeTheParameters(activityTS, dataIn, dataOut, dateIn, time, light, dataAWD, dataSupplem, fileNames, cleaningDates, SRate, timing, i, j, handles)    

    % dataIn    cell
    % dataOut   cell
    % dataAWD   matrix (row vector)
    % dataSupplem

    %% with cage cleaning days
    if j == 1
        
        % to be sure, if needed at some point, store all the data points
        % for example if you still want to compute statistics from these
        dataIn{j}.fileName{i} = fileNames{i};
        dataIn{j}.date = dateIn;
        dataIn{j}.dataAWD{i} = dataAWD;
        dataIn{j}.light{i} = light;
        dataIn{j}.time{i} = time;

        dataOut{j} = comput_MainAllCalculations(dataOut{j}, activityTS, time, light, dataAWD, dataSupplem, SRate, timing, i, handles);

    %% without cage cleaning days
    elseif j == 2

        % remove the cage cleaning days
        dataAWD2 = dataAWD;
        time2 = time;
        light2 = light;
        
        %cleaningDates
        for k = 1:length(cleaningDates)
            indices = find(time2 <= cleaningDates(k) | time2 > (cleaningDates(k)+ 1.0));
            
            % trim the indices off that are
            try            
                dataAWD2 = dataAWD2(indices);
            catch
                errordlg('Indices should not outside the data range!')
                % happened once, but could not replicate this, monitor this
            end
            time2 = time2(indices);
            light2 = light2(indices);
        end
        
        % to be sure, if needed at some point, store all the data points
        % for example if you still want to compute statistics from these
        dataIn{j}.fileName{i} = fileNames{i};
        dataIn{j}.date = dateIn;
        dataIn{j}.dataAWD{i} = dataAWD2;
        dataIn{j}.light{i} = light2;
        dataIn{j}.time{i} = time2;

        % call the subfunction
        dataOut{j} = comput_MainAllCalculations(dataOut{j}, activityTS, time, light, dataAWD, dataSupplem, SRate, timing, i, handles);
        
    %% filter out the sleepers?
    elseif j == 3
        
    end
   

