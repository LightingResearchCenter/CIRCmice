% Main function for the analysis of CIRC v. Mice
function MAIN_analysisCIRC()

    %% Initialize
    clear all
    close all
    disp(' '); disp('CIRC MICE'); disp('====') 
    
    % calls the subfunction to initialize variables, paths, etc.
    [path, dataConstant, handles] = initVariables();
    
    %% User-defined settings
    handles.dataOutDescription = {'With Cage Cleaning'; 'Without Cage Cleaning'};
    handles.settings.plotIndividualData = 0; % if you wanna plot individual activity (intermediate plots)
    
    handles.loadImportedDataFromMAT = 1; % 1 if you wanna skip time-consuming computations
    handles.loadStatsFromMAT = 0; % if you wanna skip stat calculations (these are q

        % settings when auto-saving figures, see exportfig.m for more details
        handles.figureOut_ON                = 1;
        handles.figureOut_resolution        = '-r100';  
        handles.figureOut_format            = 'png';        
        handles.figureOut_antialiasLevel    = '-a2';
    
    %% Import data & and do the computations
    
        if handles.loadImportedDataFromMAT == 1
            
            % Goes through all the different start dates from Circdates.txt
            for i = 1 : length(dataConstant.protocol.dates)
                disp(' '); disp(datestr(dataConstant.protocol.dates(i))) % display the date

                % number of different kind of periodogram calculations
                for k = 1 : length(dataConstant.periodograms)
                    % implement later to "comput_IS_IVcalcFunction"
                    [dataOut{i,k},dataIn{i,k}] =  ...
                        importDataAndDoComputations(dataConstant.protocol.dates(i), dataConstant.fileNames, path, dataConstant, handles);
                end
            end
            save('importedData.mat','dataOut')
        else
            % this just skips the whole importing and reads the data from a
            % pre-saved .mat file. NOTE! if you add files or modify the
            % script above, you should re-run the processing and saving to
            % a new MAT-file. This is mainly used for faster debugging
            load('importedData.mat')
        end
        
    %% Analyze statistics of the processed datasets
    
        % For time series
        if handles.loadStatsFromMAT == 1
            statOut = statisticalAnalysisMain(dataOut, [], dataConstant, path, handles);
            % statOut_TS = statisticalAnalysisMain_TS(data_timeSeries, dataConstant, path, handles);
            save('statsData.mat', 'statOut')
        else
            load('statsData.mat')
        end
   
    %% PLOT
        plotStatsMain(statOut, dataConstant, path, handles);
    