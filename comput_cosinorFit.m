% Fits a cosine waveform of frequency Freq to the (Time,Value) data
function [M,A,phi] = comput_cosinorFit(Time,Value,Freq)

    % Returns the Mesor (M), Amplitude (A) and phase (phi)
    omega = 2*pi*Freq;
    xj = cos(omega*Time);
    zj = sin(omega*Time);
    n = length(Time);
    A = [n sum(xj) sum(zj);...
        sum(xj) sum(xj.^2) sum(xj.*zj);...
        sum(zj) sum(xj.*zj) sum(zj.^2)];
    B = [sum(Value);...
         sum(xj.*Value);...
         sum(zj.*Value)];

     x = A\B;
     %x = solveGaussElim3(A,B);
     M = x(1);
     A = sqrt(x(2)^2 + x(3)^2);
     phi = -atan2(x(3),x(2));
     %z = complex(x(2),x(3));
     %phi = -angle(z);
