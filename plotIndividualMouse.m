% Plots the activity of individual mouse (.awd file)
function [fig, handles] = plotIndividualMouse(time, light, dataAWDtrim, fileNames, dateIn, i, j, handles)
        
    scrsz = handles.scrsz;
    
    lightScaling = max(dataAWDtrim)/2;
    titleString = sprintf('%s%s%s%s%s%s\n %s%s\n %s%s',...
                          'File ', num2str(i,'%d'), '/', num2str(length(fileNames)), ': ', fileNames{i}, ...
                          'Start date: ', datestr(dateIn), ...
                          'Condition: ', handles.dataOutDescription{j});

        if i == 1 && j == 1
            fig = figure('Name', 'Activity Counts',...
                        'Position', [0.05*scrsz(3) 0.45*scrsz(4) 0.85*scrsz(3) 0.40*scrsz(4)], ...
                        'Color', 'w');

                % initialize the plot
                hold on
                handles.plotHandles.areaH = area(time,lightScaling*light, 'EdgeColor', 'none'); % scale the boolean with the mean()
                handles.plotHandles.plotH = plot(time,dataAWDtrim,'k');       
                %plotH = bar(time, dataAWDtrim,'hist'); %computationally more intense
                handles.plotHandles.tit = title(titleString);
                handles.plotHandles.yLab = ylabel('Activity counts');
                handles.plotHandles.xLab = xlabel('Time');
                datetick2('x',2);
                hold off
                handles.plotHandles.figMouseIndividual = fig;

        else % for remaining i's of the loop, just update the plot values, 
            % -> less computational overhead
            fig = handles.plotHandles.figMouseIndividual;
            set(handles.plotHandles.plotH, 'XData', time, 'YData', dataAWDtrim) 
            set(handles.plotHandles.areaH, 'XData', time, 'YData', lightScaling*light)
            set(handles.plotHandles.tit, 'String', titleString)
        end

        % global styling
        set(gca, 'XLim', [min(time) max(time)]) % scale x-axis
        set(gca, 'YLim', [0 80]) % scale y-axis

        set([handles.plotHandles.tit handles.plotHandles.yLab handles.plotHandles.xLab], 'FontWeight', 'bold')
        drawnow