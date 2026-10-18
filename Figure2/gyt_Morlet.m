function [PSI,t] = gyt_Morlet(fs,f0,h)
%     [PSI,t] = gyt_Morlet(fs,f0,h)
% 
% Generate Morlet Wavelet based on the sampling frequence "fs", the central
% frequency of the wavelet "f0" and the Full-Width at Half-Maximum "h".
% "PSI" is the wavelet signal and "t" the time dimension.


% Time limits
lims = h*[-3,3];
lims = h*[-5,5];

% Time vector
t = linspace(lims(1),lims(2),fs*diff(lims)+1);

% Computed Morlet wavelet
PSI = exp((-4*log(2)*t.^2)/h.^2).*exp(2*1i*pi*f0*t);
PSI = PSI/sum(abs(PSI));