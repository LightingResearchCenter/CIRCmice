% Plots the CIRC-model "PRC"
function plotStat_circPRC_orig(dataVecStructure, fieldTag, timing, periodograms, j, k, path, handles)

    scrsz = handles.scrsz;

   
    
    
        % create the title
        style.titleString{1} = sprintf('%s\n %s%s\n %s%s\n %s%s',...
                                  'CIRC Model PRC', ...
                                  'Variable: ', fieldTag, ...
                                  'Condition: ', handles.dataOutDescription{j},...
                                  'Periodogram: ', periodograms{k});
        style.titleString{2} = '';

        % labels
        style.yString{1} = sprintf('%s\n %s', 'Absolute', 'Mean Activity Angle (hours)');
        style.yString{2} = sprintf('%s\n %s', 'Relative', 'Mean Activity Angle (hours)');
        style.xString{1} = sprintf('%s\n %s\n %s\n %s', 'Clock time at beginning of 1-hour probing pulse (hours)', ...
                                    ' ', ...
                                    '^§ The distribution of samples is Gaussian (Shapiro-Wilk)', ...
                                    '^£ The assumption of homoscedasticity was met (Bartlett K-test)');
        style.xString{2} = sprintf('%s', 'Clock time at beginning of 1-hour probing pulse (hours)');

        % axis limits
        style.xLim{1} = [0 24];
        style.xLim{2} = style.xLim{1};
        style.yLim{1} = [0 24];
        style.yLim{2} = style.yLim{1};

    % init figure
    fig = figure('Name', ['CIRC PRC', ' '],...
                'Position', [0.05*scrsz(3) 0.05*scrsz(4) 0.45*scrsz(3) 0.80*scrsz(4)], ...
                'Color', 'w');

    % create the x from timing data
    for i = 1 : length(timing(:,5))
        if isnan(timing(i,5))
            x(i) = 13.5; % hours for the baseline condition
        else
            x(i) = timing(i,5);
        end
    end

    % display the original data points as a way to debug
    for i = 1 : length(dataVecStructure.origData)
        origDataMatrix(:,i) = dataVecStructure.origData{i};
    end

    disp(' '); disp('Columns correspond to different dates, rows to individual mice')
    origDataMatrix

    %% Subplot 1: Absolute activity angle
    j = 1;
    s(j) = subplot(2,1,j);

        plotStat_PRC(x,dataVecStructure.mean,dataVecStructure.SD,j,style,handles)

        % display the data on command window
        dispMatrix1 = [x' dataVecStructure.mean' dataVecStructure.SD'];

    %% Annotate the Gaussian distrib. and homogeneity

        xOffset = 0.65;
        yOffset = 2;

        % add § if the data mean is from Gaussian Distribution
        % add £ if the data is homogeneous
        for i = 1 : length(x)

            % Check if Gaussian
            if dataVecStructure.shapWilk_H == 1
                str1 = '§';
            else
                str1 = '';
            end

            % Check for homogeneity
            if dataVecStructure.btestOut_H == 1
                str2 = '£';
            else
                str2 = '';
            end

            t(i,1) = text(x(i) + xOffset, dataVecStructure.mean(i), str1);
            t(i,2) = text(x(i) + xOffset, dataVecStructure.mean(i) - yOffset, str2);

        end

    %% Subplot 2: Relative activity angle
    j = 2;
    s(j) = subplot(2,1,j);

        % the first baseline is now the first data point
        baseline = dataVecStructure.mean(1);
            style.yLim{2} = style.yLim{2} - baseline;

        plotStat_PRC(x,dataVecStructure.mean-baseline,dataVecStructure.SD,j,style,handles)

        % display the data on command window
        dispMatrix1 = [x' dataVecStructure.mean' dataVecStructure.SD'];

    
        

    %% Export to disk    
    try
        if handles.figureOut_ON == 1      
            drawnow
            dateStr = getDateString(); % get current date as string
            cd(path.outputFigures)            
            fileNameOut = sprintf('%s%s%s%s', 'circPRC_ORIG_v', dateStr, ...
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
        

function plotStat_PRC(x,y,e,j,style,handles)

    %% plot the data
    p = errorbar(x, y, e, 'o');

        % put labels
        xLab = xlabel(style.xString{j});
        yLab = ylabel(style.yString{j});
        tit = title(style.titleString{j});

        % set axis limits
        xlim([style.xLim{j}])
        ylim([style.yLim{j}])

        % display the data on command window
        dispMatrix = [x' y' e']

        %% style
        markerSize = 8;
        set(p, 'Color', [.5 .5 .5], 'MarkerFaceColor', [0 0.20 0.898], 'MarkerEdgeColor', [0 0 0], 'MarkerSize', markerSize)

        set([xLab yLab], 'FontWeight', 'bold')
        set(tit, 'FontWeight', 'bold')

    