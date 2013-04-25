function [timeSeries, dataOut] = compute_createTimeSeries(dataOut, timing, handles)

    if nargin == 1
       save('tsTemp.mat') 
    else
       load('tsTemp.mat')
    end
    
    % arbitrary date basis
    dateBasis = [2013  2  5  0  0  0];
    
    % find NaNs (should be the same)
    areNotNan = ~isnan(dataOut.phasorMag);
    
    %% Transform inputs
    
        % PHASOR
        phasorMag = dataOut.phasorMag(areNotNan); % data
        phasorAngle = dataOut.phasorAngle(areNotNan); % 'time'
            phasorTime = getTime(phasorAngle, dateBasis); % as datenum    

        % Activity
        ActivityMag = dataOut.ActivityMag(areNotNan); % data
        ActivityAng = dataOut.ActivityAng(areNotNan); % 'time'
            activityTime = getTime(ActivityAng, dateBasis); % as datenum

        % Phase and Light angles
        phaseTime = getTime(dataOut.phaseAngle(areNotNan), dateBasis); % as datenum
        lightTime = getTime(dataOut.LightAng(areNotNan), dateBasis); % as datenum

        % Activity Centroid times
        aCentrTime      = getTime(dataOut.Acentroid(areNotNan), dateBasis); % as datenum

        % ACROPHASE and ADJUSTED ANGLE
        
            % This is the first time for this correction so we output these
            % also to the output to maintain somekind of backward compatibility
            % with the all code
            
            %% Correct for the angle, ACROPHASE
            indices = dataOut.ActivityAng < 0;            
            
                % DATA OUT
                dataOut.AcrophaseTime(indices) = - dataOut.ActivityAng(indices);
                dataOut.AcrophaseTime(~indices) = 24 - dataOut.ActivityAng(~indices);
                
                    %% !! Check the calculation of Acrophase
                    % so if -2h -> 2h
                    % and 23h -> 1h
            
                acrophaseTime = getTime(dataOut.ActivityAng, dateBasis);
                    acrophaseTime(indices) = acrophaseTime(indices); % for negative times
                    acrophaseTime(~indices) = acrophaseTime(~indices);
                    acrophaseTime = acrophaseTime(areNotNan);
            
            %% Adjusted Activity Angle
            indices = dataOut.ActivityAng < 0;            
                
                    % DATA OUT
                    dataOut.adjustedActivityAngle(indices) = dataOut.ActivityAng(indices) + 24;
                    dataOut.adjustedActivityAngle(~indices) = dataOut.ActivityAng(~indices);                    

                adjActivityTime = getTime(dataOut.ActivityAng, dateBasis);
                    adjActivityTime(~indices) = adjActivityTime(~indices) -1; % subtract one day
                    adjActivityTime(indices) = adjActivityTime(indices);
                    adjActivityTime = adjActivityTime(areNotNan);

    
    %% TIME SERIES OBJECTS
    
        timeSeries.phasorTS = timeseries(phasorMag, phasorTime, 'Name', 'Phasor');
        timeSeries.activityTS = timeseries(ActivityMag, activityTime, 'Name', 'Activity'); 
        timeSeries.acrophaseTS = timeseries(ActivityMag, acrophaseTime, 'Name', 'Acrophase'); 
        timeSeries.adjActivityTS = timeseries(ActivityMag, adjActivityTime, 'Name', 'Adj. Activity'); 

        % vectors out
        timeSeries.phaseTime = phaseTime;
        timeSeries.lightTime = lightTime;
        timeSeries.aCentrTime = aCentrTime;

        timeSeries.IS = dataOut.IS(areNotNan);
        timeSeries.IV = dataOut.IV(areNotNan);
        timeSeries.areNotNanIndices = areNotNan;   

        timeSeries.settings.timing = timing;

        
    function num = getTime(decimal, dateBasis)
    
        % get the hours and minutes
        minutes = mod(decimal,1);
        hours   = floor(decimal);        
        
        % add to basis  vectors
        vec = repmat(dateBasis,length(minutes),1);
        vec(:,4) = hours;
        vec(:,5) = minutes;
        num = datenum(vec);
