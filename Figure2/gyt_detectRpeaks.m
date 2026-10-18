function rpeaks = gyt_detectRpeaks(x,fs)

lenM = 0.15;
lenL = 2.5;
npass = 4;

searchwin = round(0.05*fs);

[b,a] = butter(4,[8,16]/(fs/2),'bandpass');
x(isnan(x)) = nanmean(x);
fx = filtfilt(b,a,x);

dx = diff(fx);
dx = dx/nanmax(dx);

s = -(dx.^2).*log(dx.^2);
s(isnan(s)) = 0;
for iPass=1:npass
    s = conv(s,ones(1,round(lenM*fs))/round(lenM*fs),'same');
end
cs = conv(s,ones(1,round(lenL*fs))/round(lenL*fs),'same');
filts = s-cs;

peaks = find(diff(imag(hilbert(filts))>0)>0);
rpeaks = nan(1,numel(peaks));
for iPeak=1:numel(peaks)
    if peaks(iPeak)<searchwin
        st=-peaks(iPeak)+1;
    else
        st=-searchwin;
    end
    if (numel(filts)-peaks(iPeak))<searchwin
        en = numel(filts)-peaks(iPeak)-1;
    else
        en=searchwin;
    end
    [~,I] = nanmax(abs(fx([st:en]+peaks(iPeak))));
    rpeaks(iPeak) = peaks(iPeak)+I+st-1;
end
rpeaks = unique(rpeaks);
