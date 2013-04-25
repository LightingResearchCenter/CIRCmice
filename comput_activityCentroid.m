% Finds the centroid of activity during darkness
function [AcentroidMean,Acentroids] = comput_activityCentroid(Activity,Light,Srate)

    % Acentroid is in units of hours measured from onset of darkness

    count = 0;
    index2 = 0;
    Acentroids = [];
    while (~isempty(index2))
        count = count+1;
        diffLight = [diff(Light);0];
        index1 = find(diffLight==-1,1,'first'); % first light to dark transition
        diffLightSubset = diffLight(index1+1:end);
        index2 = find(diffLightSubset==1,1,'first')+index1+1; % the next dark to light transition
        x = 1/Srate*24*(0:(index2-index1))';
        Acentroids(count) = sum(x.*Activity(index1:index2))/sum(Activity(index1:index2));
        Light = Light(index2+1:end);
        Activity = Activity(index2+1:end);
    end
    Acentroids = Acentroids(1:end-1);
    AcentroidMean = mean(Acentroids);
