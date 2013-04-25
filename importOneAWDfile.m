% Imports one .AWD file (data of one mouse)
function [dataAWDtrim, dataSupplem, SRate, light, time, activityTS] = importOneAWDfile(path, fileName, i, dateIn, dataConstant, timing, handles)

    %% correct timings, based on original .m code
    
        startDate = dateIn;    
        Ndays = timing(1);
        DST_ON = timing(2);
        lightOnTime = timing(3) / 24;
        lightOffTime = timing(4) / 24;
        lightPulseOnTime = timing(5) / 24; % only use if light pulse is given
        lightPulseOffTime = timing(6) / 24; % only use if light pulse is given
        endDate = startDate + Ndays; % e.g. 8 days later to cage cleaning, 12 days later to Dec 11 
    
        % correct for daylight savings time if needed
        if DST_ON == 0 %% from txt file
            lightOnTime = lightOnTime + (1 / 24);
            lightOffTime = lightOffTime + (1 / 24);
            lightPulseOnTime = lightPulseOnTime + (1 / 24);
            lightPulseOffTime = lightPulseOffTime + (1 / 24);            
        end
    
    %% Import the activity data

        % activity
        
            filePathName = fullfile(path.data, fileName);
            fid = fopen(filePathName);
                % the next line takes more than half the overall processing time!
                % Petteri: 23-Jan-2013, optimize if possible
                dataAWDRaw = textscan(fid, '%n%s', 'Delimiter', ' ', 'HeaderLines', 7);
                dataAWD = dataAWDRaw{1};
            fclose(fid);

        % time vector
        
            fid = fopen(filePathName,'r');
                S = fscanf(fid,'%s',4); % three first rows merged (?)
            fclose(fid);       
            T = [S(end-18:end-8) ' ' S(end-7:end)]; % start time of the .AWD
            startTimeFile = datenum(T);
            %A(find(dataAWD>90)) = 0;        

            % correct the time vector with the sample rate            
            SRate = 60*24; % samples per day (one sample every 1 minutes)

            % create a new time vector with the given sample rate
            timeVector = (1/SRate) * ( linspace(0,length(dataAWD),length(dataAWD) ) )';

            % add the startTimeFile to it for the time vector to have
            % more meaningful values (based on real date)
            time = timeVector + startTimeFile; % as long as dataAWD

        %% trim the data of interest to be that defined in circdates.txt
        
            noOfDataPointsInAWD = length(dataAWD);
            index1trim = find(time >= startDate,1,'first');
            index2trim = find(time < endDate,1,'last');
            dataAWDtrim = dataAWD(index1trim:index2trim); 
            time = time(index1trim:index2trim);        
            %timSize = size(time)
            %whos
        
        %% make NaN if there is missing data (like a dead animal or otherwise bizarre)

            % if for this cage (i), there is missing data as specified in
            % the MissingData.txt
            ind = find(i == dataConstant.missingData.cages);
            
                if ~isempty(ind) % if found
                    
                    if length(ind) > 1 % more than one epochs of missing data for the same cage
                        lengthOfData = length(ind);
                        indexIn = ind;
                    else
                        lengthOfData = 1;
                        indexIn(1) = ind;
                    end
                        
                    % now as many as epochs found    
                    for ijj = 1 : lengthOfData

                        index = indexIn(ijj);

                        disp(['      For cage "', num2str(i), '" missing data found, row (.TXT) = ', num2str(index)])

                            outlierStart = dataConstant.missingData.datesStart(index);
                            outlierEnd   = dataConstant.missingData.datesEnd(index);
                            
                            disp(['       input time interval: ', datestr(min(time)), ' - ',  datestr(max(time))])
                            disp(['        outliers from text file: ', datestr(outlierStart), ' - ',  datestr(outlierEnd), ' (MissingData.txt)'])
                        
                            outlierIndices1 = time >= outlierStart;
                            outlierIndices2 = time <= outlierEnd;
                            outlierIndices = outlierIndices1 .* outlierIndices2; % one if both are one (logical AND)
                            
                            % plot(time, outlierIndices1, 'r', time, outlierIndices2, 'g', time, outlierIndices, 'b')
                                                    
                            index1 = find(outlierIndices == 1, 1, 'first');
                            index2 = find(outlierIndices == 1, 1, 'last');
                            

                            
                            % Convert to NaNs depending on what indices
                            % have been found
                            if ~isempty(index1) && ~isempty(index2) % both found
                                
                                try
                                    dataAWDtrim(index1:index2) = NaN;   
                                    disp(['          Time range: "', datestr(time(index1)), ' : ', datestr(time(index2)), '", indices: ', num2str([1 index2]), '/', num2str(length(dataAWDtrim)), ' to NaNs, [both start+end found]'])
                                catch err
                                    err
                                    index1
                                    index2
                                    errordlg('Indices still incorrect?')
                                end
                            else
                                disp(['          however for this cage, the missing dates did not coincide with input times'])
                                disp(['            no activity values were converted to NaNs'])
                                % no indices found
                            end
                    end
                end
        
                
        
        %% Additionally you could reject some data hare based on some threshold
        
        
       
        %% Define light pulse
        
            % ideally would be checked only once per date though and not once
            % per file, but there should not be too much of an overhead from
            % this

                % write out the comparison for easier human readability
                diff1 = (time-floor(time));

                comp1 = diff1 >= lightOnTime;
                comp2 = diff1 < lightOffTime;
                comp3 = diff1 >= lightPulseOnTime;
                comp4 = diff1 < lightPulseOffTime;           

            if isnan(lightPulseOnTime) && isnan(lightPulseOffTime)            
                % control 
                light = comp1 & comp2;    
                lightControl = (comp1 & comp2);
                lightProbe = zeros(length(time),1);
            else           
                % probing pulse
                light = (comp1 & comp2) | (comp3 & comp4);   
                lightControl = (comp1 & comp2);
                lightProbe = (comp3 & comp4);
            end
        
        %% Take supplemental data round the light pulses to evaluate the behavior
        % of the mice around the light pulses        
        lightIndices = find(lightProbe == 1);
        
        dataSupplem = cell(length(handles.binsAroundLightPulse),1);
        
        for i = 1 : length(handles.binsAroundLightPulse)
            
            % save the bin length also
            dataSupplem{i}.binlength = handles.binsAroundLightPulse(i); % minutes
            
            % Preallocate
            
                % zero vector
                zeroVector = zeros(length(dataAWDtrim),1);

                % before the light pulse
                dataSupplem{i}.before = zeroVector;
                dataSupplem{i}.before(:) = NaN;            

                % after the light pulse
                dataSupplem{i}.after = zeroVector;
                dataSupplem{i}.after(:) = NaN;      
                
                % before and after the light pulse
                dataSupplem{i}.both = zeroVector;
                dataSupplem{i}.both(:) = NaN;  

                % during light exposure
                dataSupplem{i}.light = zeroVector;
                dataSupplem{i}.light(:) = NaN;                
                
            nrOfNonNanValues = length(dataAWDtrim(~isnan(dataAWDtrim)));
            
            if nrOfNonNanValues > 1    
                
                % define the indices
                
                [iBefore, iAfter, iBoth, linIndices, iCell] = import_defineBinIndices(dataSupplem{i}.binlength, SRate, lightProbe);
                
                % pick those values from the data
                dataSupplem{i}.light(lightIndices) = dataAWDtrim(lightIndices);
                
                dataSupplem{i}.after(linIndices.iAfterIndices) = dataAWDtrim(linIndices.iAfterIndices);
                dataSupplem{i}.before(linIndices.iBeforeIndices) = dataAWDtrim(linIndices.iBeforeIndices);
                
                dataSupplem{i}.both(linIndices.iAfterIndices) = dataAWDtrim(linIndices.iAfterIndices);
                dataSupplem{i}.both(linIndices.iBeforeIndices) = dataAWDtrim(linIndices.iBeforeIndices);
                
            else
                % no need to do anything, all values already NaN
            end               
            
            if handles.settings.plotIndividualData == 1
                
                % find(~isnan(dataSupplem{i}.both) == 1)'
                % find(~isnan(dataSupplem{i}.before) == 1)'
                
                hold on
                                
                area(5*lightProbe, 'FaceColor', 'y', 'EdgeColor', 'none')
                area(5*lightControl, 'FaceColor', [1 0.5 0], 'EdgeColor', 'none')
                plot(dataAWDtrim, 'g')
                plot(dataSupplem{i}.before, 'r')
                plot(dataSupplem{i}.after, 'b')
                
                title(['Bin Length: ', num2str(dataSupplem{i}.binlength), ' min, file: ', fileName, ' ', datestr(startDate), ', mean activity = ', num2str(nanmean(dataSupplem{i}.both))])                
                legend('lightProbe', 'light', 'activity', 'before', 'after', 'Location', 'NorthEastOutside')
                
                drawnow
                pause(0.05)
                
                %% Export to disk    
                    try
                        if handles.figureOut_ON == 1      
                            drawnow
                            dateStr = getDateString(); % get current date as string
                            cd(path.outputFigures)            
                            fileNameOut = sprintf('%s%s%s%s', (strrep(fileName, '.awd', '')), '_bins_v', dateStr, '.png');
                            %export_fig(fileNameOut, handles.figureOut_resolution, handles.figureOut_antialiasLevel, fig)
                            cd(path.code)
                        end
                    catch
                        str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                                      'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "ADD TO PATH"');
                        error(str)

                    end
            end
                
        end
            
        %% Finally convert the imported data into a TIMESERIES object
        
            % which should make the calculation of parameters easier and avoid
            % problems with going from 23h to 00:30h for example
            activityTS = timeseries(dataAWDtrim,time,'Name','WheelActivity');
            
            
    