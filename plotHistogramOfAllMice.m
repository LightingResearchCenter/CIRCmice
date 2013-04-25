% Plots the histogram of all the mice, for whatever variable you like
function plotHistogramOfAllMice(x,y,xLabel,j,dateIn,Ndays,path,handles)
    
    scrsz = handles.scrsz;
    close all
    
    titleString = sprintf('%s%s%s%s%s\n %s%s\n %s%s',...
                          'Start date: ', datestr(dateIn), ' -> ', num2str(Ndays), ' days', ...
                          'Condition: ', handles.dataOutDescription{j});

    fig = figure('Name', 'Histogram',...
                    'Position', [0.25*scrsz(3) 0.25*scrsz(4) 0.65*scrsz(3) 0.40*scrsz(4)], ...
                    'Color', 'w');

    if isempty(x)
        hist(y);
    else
        hist(x, y);
    end
    
    xlab = xlabel(xLabel, 'FontWeight', 'bold');
    tit = title(titleString, 'FontWeight', 'bold');

    %% EXPORT TO DISK
    try
        if handles.figureOut_ON == 1      
            drawnow
            dateStr = getDateString(); % get current date as string
            cd(path.outputFigures)            
            fileNameOut = sprintf('%s%s%s%s%s%s%s%s', 'histogOfDate_v', dateStr, ...
                                   '_', datestr(dateIn), '_for', num2str(Ndays), 'days_',...
                                   '_', strrep(handles.dataOutDescription{j}, ' ', ''), ...
                                   '.', handles.figureOut_format);
            export_fig(fileNameOut, handles.figureOut_resolution, handles.figureOut_antialiasLevel, fig)
            cd(path.code)
        end
    catch
        str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                      'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "ADD TO PATH"');
        errordlg(str)

    end

    