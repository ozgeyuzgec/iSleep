function SWs = gyt_SWdetection(x,fs)

if size(x,1)>1
    x = x';
end
    


% [b,a] = cheby2(1,25,[0.1,10]/(fs/2),'bandpass');

[b,a] = butter(1,[0.5,4]/(fs/2),'bandpass');
fx = filtfilt(b,a,x);

pz = find(diff([0,fx]>0)>0);
nz = find(diff([0,fx]>0)<0);

diffmat = repmat(pz,[numel(nz),1])-repmat(nz',[1,numel(pz)]);
diffmat(diffmat<=0) = Inf;
[~,I] = min(diffmat,[],2);
SWt = [nz;pz(I)];
SWt = SWt(:,(diff(SWt,1,1)>(fs*0.25))&(diff(SWt,1,1)<(fs*1)));
ffx = diff([0,conv(fx,ones(1,round(fs*0.050))/round(fs*0.050),'same')]);

nAmp = nan(1,size(SWt,2));
npeaks = nan(1,size(SWt,2));
maxSl = nan(1,size(SWt,2));
for iSW = 1:size(SWt,2)
    tmpmaxSl = min(ffx(SWt(1,iSW):SWt(2,iSW)));
    maxSl(iSW) = tmpmaxSl;
    
    tmpnAmp = min(fx(SWt(1,iSW):SWt(2,iSW)));
    nAmp(iSW) = tmpnAmp;
    
    npeaks(iSW) = sum(diff(ffx(SWt(1,iSW):SWt(2,iSW))>0)>0);
end

SWs = [SWt;nAmp;npeaks;maxSl;diff(SWt,1,1)/fs];






            