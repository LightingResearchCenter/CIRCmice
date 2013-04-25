%cos24 returns the 24 hour phasor using x and y
function [magnitude, angle] = comput_cos24(x, y, srate)

    % x is CS
    % y is activity
    % srate is the sampling rate in Hz
    % magnitude is the phasor magnitude
    % angle is the phasor angle in hours

    %per equals the number of seconds per sample
    per = 1/srate;

    %tot equals the total number of days of data
    tot = (per*length(x))/86400;

    time = (0:(per/86400):(tot - per/86400))';

    size(x);
    size(time);

    %fits the signals using a 24 hour cosine curve
    [Mx,Ax,phix] = comput_n_cosinorFit(time,x,1, 1);
    [My,Ay,phiy] = comput_n_cosinorFit(time,y,1, 1);

    %angle is just the difference in phases
    angle = (phix - phiy)/(2*pi);

    %pshift is the number of points to shift so that the signals line up
    pshift = angle/(time(2) - time(1));
    
    %shift one signal so that they overlap
    try
        y = circshift(y, round(pshift));
    catch
        warning('NaN vector')        
    end

    %magnitude is just the normalized cross covariance (from wikipedia)
    magnitude = (.5*Ax*Ay)/(std(x)*std(y));
    angle = angle*24;