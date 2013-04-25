% Calculates mean, SD, etc. here 
function statOut = stat_basicStatTimeSeries(dataTimeSeries, statFuncPath, shapWilk_pThr, bartlett_pThr)

    % modify the code if you start feeding matrices here instead of vectors
    statOut.mean = mean(dataTimeSeries);
    statOut.SD   = std(dataTimeSeries);   
    
        % calculate the mean of the time vector
        timeVector = dataTimeSeries.Time;
        statOut.time = stat_basicStatFuncs(timeVector, statFuncPath, shapWilk_pThr, bartlett_pThr);        
   
    %% For further Advanced Statistical Analysis
    
        dataVectorIn = zeros(length(dataTimeSeries.Data),1);
        dataVectorIn(:) = dataTimeSeries.Data(1,1,:);
        n = length(dataVectorIn);
    
        % We use 3rd party implementations of the statistical tests
        cd(statFuncPath)
    
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
                    [statOut.shapWilk_H, statOut.shapWilk_p, statOut.shapWilk_W] = swtest(dataVectorIn, alpha, tail);
                catch 
                    % fails if all the values are the same
                    warning(['"n check" faulty?'])
                    statOut.shapWilk_H = NaN;
                    statOut.shapWilk_pValue = NaN;
                    statOut.shapWilk_W = NaN;
                end
                    
            else
                statOut.shapWilk_H = NaN;
                statOut.shapWilk_pValue = NaN;
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
                sample = ones(length(dataVectorIn),1);
                X      = [dataVectorIn sample];
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
