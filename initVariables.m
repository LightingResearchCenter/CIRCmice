% Inits the variables from paths and constant text files
function [path, dataConstant, handles] = initVariables()

    %% user-defined settings    
    dataConstant.periodograms = {'Enright'};
    
        handles.scrsz = get(0,'ScreenSize'); % get screen size for plotting;
            % handles structure used typically with GUI
            
        handles.binsAroundLightPulse = [60]; % in minutes
            
        % statistical values
        globalAlpha_threshold       = 0.05;
        handles.shapWilk_pThreshold = globalAlpha_threshold;
        handles.bartlett_pThreshold = globalAlpha_threshold;
        
        handles.anova_pThreshold    = globalAlpha_threshold;
        handles.wilcox_doPaired     = 0;
        handles.wilcox_pThreshold   = globalAlpha_threshold;
        handles.wilcox_method       = 'approximate'; % will be set automatically by the result from mwwtest.m
        handles.student_pThreshold  = globalAlpha_threshold;

    %% set paths    
    path.code = mfilename('fullpath'); % Setting the path for the code
        path.code = strrep(path.code,'initVariables',''); % Removing the filename from the path
        
    cd ..; % go back one dir
    path.idFolder = 'mice-onr-04192013';
    path.data = fullfile(cd, 'ONR mice data', path.idFolder, 'cages'); % for the .awd files
    cd(path.code) % return back to main dir
    
    path.inputTxt = fullfile(path.code, 'inputTXT'); % for the text files defining protocol
        path.protocolFile = fullfile(path.inputTxt, 'Circdates.txt');
        path.cleaningDates = fullfile(path.inputTxt, 'CleaningDates.txt'); 
        path.missingData = fullfile(path.inputTxt, 'MissingData.txt'); 
        
    path.outputTxt = fullfile(path.code, 'outputTXT');
    path.statFunc = fullfile(path.code, '3rdPartyStat'); 
    path.outputFigures = fullfile(path.code, 'outputFigures');
        
    % get the file listing of the data path        
    stringToBeFound = '*.awd'; % The string to be searched within the folder       
    dirOutput = dir(fullfile(path.data,stringToBeFound));  % Specifies the type of files to be listed        
    dataConstant.fileNames = {dirOutput.name}'; % Prints the filenames from the input folder

    %% import the data from the text files
    delim = '\t'; % tab-delimited

        % the protocol file
        fid = fopen(path.protocolFile);
            dataConstant.protocol.headers = textscan(fgetl(fid), '%s %s%s %s%s %s%s', 'Delimiter', delim);
            dataConstant.protocol.circDataRaw = textscan(fid, '%s %n%n %n%n %n%n', 'Delimiter', delim);
        fclose(fid);
            
            % transform the date vector to Matlab format
            dataConstant.protocol.dates = datenum(dataConstant.protocol.circDataRaw{:,1}, 'dd-mmm-yy');
            
            % remove the string date, and convert the numerical data into a
            % matrix
            rows = length(dataConstant.protocol.circDataRaw{1});
            cols = length(dataConstant.protocol.circDataRaw) - 1;
            for i = 1 : cols
                for j = 1 : rows
                    dataConstant.protocol.circData(j,i) = dataConstant.protocol.circDataRaw{i+1}(j);
                end
            end
            % c = dataConstant.protocol.circData           
        
        % the cleaning dates
        fid = fopen(path.cleaningDates);
            dataConstant.cleaningDates.headers = textscan(fgetl(fid), '%s%s', 'Delimiter', delim);
            dataConstant.cleaningDates.data = textscan(fid, '%s%s', 'Delimiter', delim);
        fclose(fid);
        
            % transform the date vector to Matlab format
            dataConstant.cleaningDates.dates = datenum(dataConstant.cleaningDates.data{:,1}, 'dd-mmm-yy');            
            
        % the missing data
        fid = fopen(path.missingData);
            dataConstant.missingData.headers = textscan(fgetl(fid), '%s %s %s %s', 'Delimiter', delim);
            dataConstant.missingData.data = textscan(fid, '%n %s %s %s', 'Delimiter', delim);
        fclose(fid);
        
            % transform the date vector to Matlab format
            dataConstant.missingData.cages = dataConstant.missingData.data{:,1};
            dataConstant.missingData.datesStart = datenum(dataConstant.missingData.data{:,2}, 'dd-mmm-yy');
            dataConstant.missingData.datesEnd = datenum(dataConstant.missingData.data{:,3}, 'dd-mmm-yy');
            dataConstant.missingData.comment = dataConstant.missingData.data{:,4};
            
                % a = dataConstant.missingData.cages
                % b = dataConstant.missingData.datesStart
                % c = dataConstant.missingData.datesEnd
                % d = dataConstant.missingData.comment
