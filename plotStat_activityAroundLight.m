function plotStat_activityAroundLight(dataVecStructure, activityAngle, fieldTag, timing, periodograms, j, k, path, handles)

    scrsz = handles.scrsz;
    
        
        % init figure
        fig = figure('Name', ['Activity', ' '],...
                    'Position', [0.52*scrsz(3) 0.05*scrsz(4) 0.45*scrsz(3) 0.80*scrsz(4)], ...
                    'Color', 'w');

        % create the x from timing data
        % timing
        for i = 1 : length(timing(:,5))
            if isnan(timing(i,5))
                x(i) = 13.5; % hours for the baseline condition
            else
                x(i) = timing(i,5);
            end
        end

        % display the original data points as a way to debug
        for i = 1 : length(dataVecStructure.origData)
            % a = dataVecStructure.origData{i}
            origDataMatrix(:,i) = dataVecStructure.origData{i};
        end

        disp(' '); disp('Columns correspond to different dates, rows to individual mice')
        disp('Values less than 24h are from previous day, means calculated for datenum -values')
        %whos
        % remove Zeroes
            origDataMatrix(origDataMatrix == 0) = NaN;
            
            % correct the angle
            activityAngle.mean = 24 - (activityAngle.mean - 12);
            
            % recalculate mean (check the bug at some point)
            dataVecStructure.mean(dataVecStructure.mean == 0) = NaN;
            dataVecStructure.SD(dataVecStructure.SD == 0) = NaN;
                
           
            origDataMatrix
            disp(' '); disp('Time ActMean ActSD angleMean angleSD')
            dispMatrix1 = [x' dataVecStructure.mean' dataVecStructure.SD' activityAngle.mean', activityAngle.SD']
           
    %% PLOT
        
        subplot(2,1,1)
        e(1) = errorbar(x,dataVecStructure.mean,dataVecStructure.SD,'o');
            set(e, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
            
            % annotate the data points with time of probing pulse
            for i = 1 : length(x)
                text(x(i)+0.5, dataVecStructure.mean(i)+2, num2str(x(i)))
            end

        
            % annotate the second baseline
            text(x(end)+1, dataVecStructure.mean(end)+1, '2nd')

            xLab(1) = xlabel('Clock time at beginning of 1-hour probing pulse (hours)');
            yLab(1) = ylabel('Mean activity (wheel revolutions per minute)');
            
            tit = title('Mean activity (wheel revolutions per minute) 60 min before and after the probing pulse ');
            
        subplot(2,1,2)        
        e(2) = errorbar(dataVecStructure.mean, activityAngle.mean, activityAngle.SD,'o');
            set(e, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
            
            % annotate the data points with time of probing pulse
            for i = 1 : length(x)
                text(dataVecStructure.mean(i)+0.5, activityAngle.mean(i)+1, num2str(x(i)))
            end
        
            % annotate the second baseline
            % text(dataVecStructure.mean(end)+1, activityAngle.mean(end), '2nd')
            
            xLab(2) = xlabel('Mean activity (wheel revolutions per minute)');
            yLab(2) = ylabel('Activity angle');
            
            tit = title('Activity angle for each probing pulse compared to mean activity 60 min before and after the pulse');
            
        %% style
        markerSize = 8;
        set(e, 'Color', [.5 .5 .5], 'MarkerFaceColor', [0 0.20 0.898], 'MarkerEdgeColor', [0 0 0], 'MarkerSize', markerSize)

        set([xLab yLab], 'FontWeight', 'bold')
        set(tit, 'FontWeight', 'bold')
            
        %% Export to disk    
        try
            if handles.figureOut_ON == 1      
                drawnow
                dateStr = getDateString(); % get current date as string
                cd(path.outputFigures)            
                fileNameOut = sprintf('%s%s%s%s', 'circPRC_activityAroundLight_v', dateStr, ...
                                       '_', fieldTag, ...
                                       '_', strrep(handles.dataOutDescription{j}, ' ', ''), ...
                                       '_', periodograms{k}, ...
                                       '.', handles.figureOut_format);
                export_fig(fileNameOut, handles.figureOut_resolution, handles.figureOut_antialiasLevel, fig)
                cd(path.code)
            end
        catch
            str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                          'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "ADD TO PATH"');
            error(str)

        end