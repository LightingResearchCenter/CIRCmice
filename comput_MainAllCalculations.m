 function dataOut = comput_MainAllCalculations(dataOut, activityTS, time, light, dataAWD, dataSupplem, SRate, timing, i, handles)

    % NOTE, now in the old implementation the TIMESERIES object was not
    % really used so the calculations work okay for having the light and
    % dataAWD as vectors instead of TIMESERIES objects
    
    % However we want to define the output variables as TIMESERIES to make
    % the computation of mean of times easier
    
    % how many NaN-values are there    
    ind = ~isnan(dataAWD);
    isNotNanVector = dataAWD(ind); %    
     %    l = length(isNotNanVector)

    % arbitrary date basis
    dateBasis = [2013  2  5  0  0  0];       
    
    if length(isNotNanVector) >= 1
        
        % Returns the 24 hour phasor using x and y
        [dataOut.phasorMag(i), dataOut.phasorAngle(i)] = comput_cos24(light,dataAWD,1/60); % 1/60 is the sample rate in Hz, angle is in hours
            %phasorAngle(i) = phasorAngle(i)*12/pi; % convert from radians to hours
            dataOut.phasorAngle(i) = getTime(dataOut.phasorAngle(i), dateBasis); % as datenum

        % Fits a cosinor to the activity data
        [M_A,ampA,angleA] = comput_cosinorFit(time, dataAWD, 1);
            dataOut.ActivityMag(i) = (1/sqrt(2))*ampA/std(dataAWD);
            dataOut.ActivityAng(i) = angleA*12/pi; % in hours   
 
            actAngle = dataOut.ActivityAng(i); % see below
            dataOut.ActivityAng(i) = getTime(dataOut.ActivityAng(i), dateBasis); % as datenum

        % Fits a cosinor to the light pulse
        [M_L,ampL,angleL] = comput_cosinorFit(time, light, 1);
            dataOut.phaseAngle(i) = (angleA-angleL)*12/pi; % in hours
            dataOut.phaseAngle(i) = getTime(dataOut.phaseAngle(i), dateBasis); % as datenum
            dataOut.LightAng(i) = angleL*12/pi; % in hours
            dataOut.LightAng(i) = getTime(dataOut.LightAng(i), dateBasis); % as datenum

        % Return the centroid of activity
        dataOut.Acentroid(i) = comput_activityCentroid(dataAWD,light,SRate);
        dataOut.Acentroid(i) = getTime(dataOut.Acentroid(i), dateBasis); % as datenum

        % Returns interdaily and intradaily variation, this can be repeated
        % using different ways to calculate the periodogram
        dt = 60; % scalar dt in units of seconds
        [dataOut.IS(i), dataOut.IV(i)] = comput_IS_IVcalcFunction(dataAWD,dt,handles);
    
        % Correct for the angle 
        if actAngle < 0
            dataOut.AcrophaseTime(i) = - actAngle;
        else
            dataOut.AcrophaseTime(i) = 24 - actAngle;
        end
        dataOut.AcrophaseTime(i) = getTime(dataOut.AcrophaseTime(i), dateBasis); % as datenum

        % Adjusted Activity Angle
        if actAngle < 0
            dataOut.adjustedActivityAngle(i) = actAngle + 24;
            % =IF(P86<12,P86+12,P86-12)            
        else
            dataOut.adjustedActivityAngle(i) = actAngle;
            % dataOut.adjustedActivityAngle(i) = getTime(dataOut.adjustedActivityAngle(i), dateBasis); % as datenum
        end
        
        if dataOut.adjustedActivityAngle(i) < 12
            dataOut.adjustedActivityAngle(i) = dataOut.adjustedActivityAngle(i) + 12;
        else
            dataOut.adjustedActivityAngle(i) = dataOut.adjustedActivityAngle(i) - 12;
        end            
           
        %% get the activity around the pulses
        for jj = 1 : length(handles.binsAroundLightPulse)
            
            dataOut.activityAroundLight.both.mean(i,jj) = nansum(dataSupplem{jj}.both) / (2 * handles.binsAroundLightPulse(jj));
                if dataOut.activityAroundLight.both.mean(i,jj) == 0
                    dataOut.activityAroundLight.both.mean(i,jj) = NaN;                    
                    % isZero = 1
                end
            dataOut.activityAroundLight.both.SD(i,jj) = nanstd(dataSupplem{jj}.both);
            dataOut.activityAroundLight.both.n(i,jj) = length(dataSupplem{jj}.both(~isnan(dataSupplem{jj}.both)));
            dataOut.activityAroundLight.both.binlength(jj) = handles.binsAroundLightPulse(jj); % minutes
            
            dataOut.activityAroundLight.before.mean(i,jj) = nansum(dataSupplem{jj}.before) / (1 * handles.binsAroundLightPulse(jj));
                if dataOut.activityAroundLight.before.mean(i,jj) == 0
                    dataOut.activityAroundLight.before.mean(i,jj) = NaN;
                    % isZero = 1
                end
            dataOut.activityAroundLight.before.SD(i,jj) = nanstd(dataSupplem{jj}.before);
            dataOut.activityAroundLight.before.n(i,jj) = length(dataSupplem{jj}.before(~isnan(dataSupplem{jj}.before)));
            dataOut.activityAroundLight.before.binlength(jj) = handles.binsAroundLightPulse(jj); % minutes
            
            dataOut.activityAroundLight.after.mean(i,jj) = nansum(dataSupplem{jj}.after) / (1 * handles.binsAroundLightPulse(jj));
                if dataOut.activityAroundLight.after.mean(i,jj) == 0
                    dataOut.activityAroundLight.after.mean(i,jj) = NaN;
                    % isZero = 1
                end
            dataOut.activityAroundLight.after.SD(i,jj) = nanstd(dataSupplem{jj}.after);
            dataOut.activityAroundLight.after.n(i,jj) = length(dataSupplem{jj}.after(~isnan(dataSupplem{jj}.after)));
            dataOut.activityAroundLight.after.binlength(jj) = handles.binsAroundLightPulse(jj); % minutes
            
            minutesInAnHour = 60;
            dataOut.activityAroundLight.light.mean(i,jj) = nansum(dataSupplem{jj}.light) / minutesInAnHour;
                if dataOut.activityAroundLight.light.mean(i,jj) == 0
                    dataOut.activityAroundLight.light.mean(i,jj) = NaN;
                    % isZero = 1
                end
            dataOut.activityAroundLight.light.SD(i,jj) = nanstd(dataSupplem{jj}.light);
            dataOut.activityAroundLight.light.n(i,jj) = length(dataSupplem{jj}.light(~isnan(dataSupplem{jj}.light)));
            dataOut.activityAroundLight.light.binlength(jj) = handles.binsAroundLightPulse(jj); % minutes            
            
            % other options
            % see importOneAWDfile.m for details
                % dataSupplem{i}.before        
                % dataSupplem{i}.after            
                % dataSupplem{i}.light
        end

    else % if all the values are NaN
        
        disp('             FROM: comput_MainAllCalculations.m')
        disp(['               all values are NaN for activity data, thus all the derived parameters are also NaN, i = ', num2str(i)])
            % l = length(isNotNanVector)
            % isNotNanVector
            % dataAWD'
                
        dataOut.phasorMag(i)                = NaN;
        dataOut.phasorAngle(i)              = NaN;
        dataOut.ActivityMag(i)              = NaN;
        dataOut.ActivityAng(i)              = NaN;
        dataOut.phaseAngle(i)               = NaN; 
        dataOut.LightAng(i)                 = NaN;
        dataOut.Acentroid(i)                = NaN;
        dataOut.IS(i)                       = NaN;
        dataOut.IV(i)                       = NaN;
        dataOut.AcrophaseTime(i)            = NaN;
        dataOut.adjustedActivityAngle(i)    = NaN;
        
        for jj = 1 : length(handles.binsAroundLightPulse)
            dataOut.activityAroundLight.mean(i,jj) = NaN;
            dataOut.activityAroundLight.SD(i,jj) = NaN;
            dataOut.activityAroundLight.n(i,jj) = NaN;
            dataOut.activityAroundLight.binlength(jj) = handles.binsAroundLightPulse(jj);
        end

    end
    
    if i == 1
        % Add the timing info to be used in plotting later
        dataOut.settings.timing = timing;
    end
    

    function num = getTime(decimal, dateBasis)
    
        if decimal > 40
            warning('You are probably pushing a datenum to this instead of an hour')
            decimal                  
        end

        % get the hours and minutes
        minutes = mod(decimal,1) * 60;
        hours   = floor(decimal);        
        
        % add to basis  vectors
        vec = dateBasis;
        vec(:,4) = hours;
        vec(:,5) = minutes;
        num = datenum(vec);
