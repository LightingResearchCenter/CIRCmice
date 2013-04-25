% Calculates mean, SD, etc. here 
function [statOut, dataVectorIn] = stat_basicStatFuncs(dataVectorIn, statFuncPath, shapWilk_pThr, bartlett_pThr)

    % modify the code if you start feeding matrices here instead of vectors
    
    % get the size of the input
    dataVectorIn = dataVectorIn';
    dataVectorIn_nonNan = dataVectorIn(~isnan(dataVectorIn));
    n = length(dataVectorIn_nonNan); % length of non-NaN value vector
    siz = size(dataVectorIn);
    % dataVectorIn    
    
    %% BASIC ONES
    
        % just add lines here and store it to the structure if you want to
        % calculate something more
        statOut.mean = nanmean(dataVectorIn);
        statOut.SD   = nanstd(dataVectorIn);
        
            % if mean is 0 then make it NaN
            % a = statOut.mean
            %{
            if statOut.mean == 0
                statOut.mean = NaN;
                statOut.SD = NaN;
            end
            %}

        % Dummy check, if the value now is bigger than 70'000, then the
        % average data is a datenum, and we can convert it to time
        if statOut.mean > 70000
            dataVec = datevec(dataVectorIn);
            dataVectorIn = vecTimeToDecimalHours(dataVec);
            statOut.mean = dateNumAverageToHourAverage(statOut.mean);
            statOut.SD = dateNumAverageToHourAverage(statOut.SD);
        end
        
    %% For further Advanced Statistical Analysis
    
        % We use 3rd party implementations of the statistical tests
        cd(statFuncPath)
        dataVectorIn_nonNan = dataVectorIn(~isnan(dataVectorIn));
    
        %% Shapiro-Wilk normality test
        % ---> ok if p > 0.05

            % IMPLEMENTATION by: Ahmed Ben Saïda
            % http://www.mathworks.com/matlabcentral/fileexchange/13964
            % Shapiro-Wilk parametric hypothesis test of composite normality, for sample size 3<= n <= 5000. 
            % Based on Royston R94 algorithm. 
            % This test also performs the Shapiro-Francia normality test for platykurtic samples.
           
            alpha = shapWilk_pThr;
            tail = 1; % default value, check swtest.m for explations
            
            % call the subfunction
            if n >= 3 
                try
                    % dataVectorIn
                    [statOut.shapWilk_H, statOut.shapWilk_p, statOut.shapWilk_W] = swtest(dataVectorIn_nonNan, alpha, tail);
                    % a = statOut.shapWilk_p
                    % b = statOut.shapWilk_H
                catch
                    % fails if all the values are the same
                    warning(['"n check" faulty?'])
                    statOut.shapWilk_H = NaN;
                    statOut.shapWilk_p = NaN;
                    statOut.shapWilk_W = NaN;                
                end
            else
                statOut.shapWilk_H = NaN;
                statOut.shapWilk_p = NaN;
                statOut.shapWilk_W = NaN;
            end

            % NULL hypothesis is that the distribution is NOT Gaussian so
            % if the p-value is higher than your alpha, then the
            % distribution is Gaussian, i.e. if W < 1
            
        %% Bartlett's K-squared test for "homogeneity of distribution of the deviation"
        % --> ok if p > 0.05

            % if the distribution is indeed GAUSSIAN
            if statOut.shapWilk_W < 1 
                
                % Use the subfunction provided by Antonio
                % Trujillo-Ortiz to reduce dependency on additional
                % toolboxes such as Statistics Toolbox that has the
                % function "barttest" (?)
                % http://www.mathworks.com/matlabcentral/fileexchange/3314-btest
                sample = ones(length(dataVectorIn_nonNan),1);
                % whos
                try 
                    X = [dataVectorIn_nonNan sample];                    
                catch
                    X = [dataVectorIn_nonNan' sample]; % transpose
                end
                alpha  = bartlett_pThr;

                % first with Trujillo-Ortiz's subfunction
                btestOut = Btest(X,alpha);
                
                    % take out from the structure
                    statOut.btestOut_var = btestOut.var;
                    statOut.btestOut_v   = btestOut.v;
                    statOut.btestOut_P   = btestOut.P;
                    statOut.btestOut_X2  = btestOut.X2;
                    statOut.btestOut_F   = btestOut.F;
                    statOut.btestOut_H   = btestOut.H;                    
            
            % If not GAUSSIAN distribution, just return NaN
            else                
                statOut.btestOut_var = NaN;
                statOut.btestOut_v   = NaN;
                statOut.btestOut_P   = NaN;
                statOut.btestOut_X2  = NaN;
                statOut.btestOut_F   = NaN;  
                statOut.btestOut_H   = 0;
            end


    function hours = dateNumAverageToHourAverage(dateNUM)

        vec = datevec(dateNUM);

        hour = vec(4);
        minute = vec(5);
        sec = vec(6);

        hours = hour + minute/60 + sec/60/60;

    function hours = vecTimeToDecimalHours(dataVec)

        % dataVec

        minDay = min(dataVec(:,3));
        dayVector = dataVec(:,3) - minDay;

        dayHours = (dayVector * 24);
        hour = dataVec(:,4) + dayHours;
        minute = dataVec(:,5);
        sec = dataVec(:,6);

        hours = hour + minute/60 + sec/60/60;

        