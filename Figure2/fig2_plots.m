
%%% Define pathes
% Define mainpath of the experiement relative to the path of the script
[Mainpath,~,~] = fileparts(fileparts(mfilename('fullpath')));
% Define data path
datapath = [Mainpath,filesep,'data'];
% Define Result path
respath = [Mainpath,filesep,'Results'];
% Define figure path
figpath = [respath,filesep,'Figures'];
% List subfolder (sessions) in data path
subfolders = dir([datapath,filesep,'pup*']);

%%% Define variables
% Time-step for downsamping
winsize = 0.1;
% Time-step in EEG timepoints
winsizeT = round(winsize*500);
% Extent of cross-correlation (in seconds)
winsizeCorr = 120;
% Window of correlation
timepointsCorr = -winsizeCorr*500:winsizeT:winsizeCorr*500;
% Extent of cross-correlation for autonomic markers(in seconds)
winsizeCorrAuto = 60;
% Window of correlation
timepointsCorrAuto = -winsizeCorrAuto*500:winsizeT:winsizeCorrAuto*500;
% Frequencies for computation of spindle central frequency
freqspin = 10:15;
% Frequencies for cross-correlation
freqs = [1:30];
% Extent of cross-correlation (in seconds)
winsizeISO = 300;
% Frequencies of Infra-Slow Oscillations (ISO)
ISOfreqs = linspace(0,1.0/winsize/2,winsizeISO/winsize/2+1);
% Sub-frequency band considered in ISO
ISOband = [0.001,0.1];
% Window boundaries for long-scale event-related potentials
winERP = [-10,25];
% Window boundaries for long-scale event-related potentials
ERPb = [-5,-0];
% Window boundaries for infra-slow oscillations (ISO) ERPs
winERPISO = [-40,100];
% Baseline of ISO-ERPs
ERPISOb = [-40,0];
% Window boundaries for short-scale event-related potentials
winERPse = [-5,10];
% Window boundaries for short-scale event-related potentials
ERPbse = [-5,0];
% Time-step for downsamping
winsizeSE = 0.008;
% Time-step in EEG timepoints
winsizeSET = round(winsizeSE*500);

% Threshold number of events to keep the event-related activities of a
% session.
thr_nbouts = 1;

%
eyerange = linspace(0,120,60);


% Color code for sleep stages
cccSta = [0.8320    0.3672         0;...
    0.2000    0.8000    0.8000;...
    0.4000    0.6000    0.8000;...
    0.1000    0.1000    0.5000;...
    0    0.4453    0.6953;...
    0    0.6172    0.4492];

winsizeCorrPupxEOG = 100;

% % Define sleep stages of interest
% sleepStages = {[0],[1],[2],[3],[2,3],[5],[1,2,3,5],[0,1,2,3,5]};
% % Define names of sleep stages
% sleepStageNames = {'Wake','N1','N2','N3','NREM','REM','Sleep','All'};

% Define sleep stages of interest
sleepStages = {[0],[1],[2],[3],[2,3],[5]};
% Define names of sleep stages
sleepStageNames = {'Wake','N1','N2','N3','NREM','REM'};



% Define frequency bands of interest
freqbands = {[1,4],[4,8],[8,12],[12,15],[15,30]};
% Define name of frequency bands of interest
freqbandNames = {'Delta','Theta','Alpha','Sigma','Beta'};

% [~,SessionInfos] = xlsread([datapath,filesep,'SessionInfos.xlsx']);
fid = fopen([datapath,filesep,'Summary_pup.csv'],'r');
SessionInfos = textscan(fid,'%s %s %s %s %s %s %s %s','Delimiter',',');
SessionInfos = [SessionInfos{:}];
SessionInfos = SessionInfos(2:end,:);
fclose(fid);


%% Load data

load([Mainpath,filesep,'Results',filesep,'ISO.mat']);


%% Plot cross-correlation frequency power x pupil size

ccc = gyt_ColorPalet/256;
ccc = ccc([1,4,3,7,8,2,6],:);
ccc(1,:) = [0.3,0.3,0.3];


for iSta = 1:numel(sleepStages)
    
    gP = Nbouts(:,iSta)>thr_nbouts;
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    if ~exist(cfigpath,'dir')
        mkdir(cfigpath);
    end
    
    
    fig = figure('Position',[50,50,1000,600]);
    g = gyt_heatmap(timepointsCorrAuto/500,freqs(1:30),nanmean(RSpecE(1:30,:,gP,iSta),3),4)
    uistack(gca,'top')
    hold on
    caxis([-0.3,0.3])
    colormap(cmocean('balance'))
    for iFB=1:numel(freqbands)
        plot([-120,120],[1,1]*freqbands{iFB}(1),'k-');
        plot([-120,120],[1,1]*freqbands{iFB}(2),'k-');
    end
    xlim([-60,60])
    ylim([1,30])
    set(gca,'ydir','normal');
    h = colorbar;
    xlabel('Time relative to pupil size signal');
    set(get(h,'label'),'string','Correlation Pupil size x Power (Pearson''s R)');
    ylabel('Frequency (Hz)');
    savefig(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName],'-dpng','-r300');
    close(fig);

    
    
    
    fig = figure('Position',[50,50,1000,600]);
    g = gyt_heatmap(timepointsCorrAuto/500,freqs(1:30),nanmean(RSpecE_withAr(1:30,:,gP,iSta),3),4)
    uistack(gca,'top')
    hold on
    caxis([-0.3,0.3])
    colormap(cmocean('balance'))
    for iFB=1:numel(freqbands)
        plot([-120,120],[1,1]*freqbands{iFB}(1),'k-');
        plot([-120,120],[1,1]*freqbands{iFB}(2),'k-');
    end
    xlim([-60,60])
    ylim([1,30])
    set(gca,'ydir','normal');
    h = colorbar;
    xlabel('Time relative to pupil size signal');
    set(get(h,'label'),'string','Correlation Pupil size x Power (Pearson''s R)');
    ylabel('Frequency (Hz)');
    savefig(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName,'_withAr'],'compact');
    print(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName,'_withAr'],'-dpng','-r300');
    close(fig);
    
    
    fig = figure('Position',[50,50,1000,600]);
    g = gyt_heatmap(timepointsCorrAuto/500,freqs(1:30),nanmean(RSpecE_woAr(1:30,:,gP,iSta),3),4)
    uistack(gca,'top')
    hold on
    caxis([-0.3,0.3])
    colormap(cmocean('balance'))
    for iFB=1:numel(freqbands)
        plot([-120,120],[1,1]*freqbands{iFB}(1),'k-');
        plot([-120,120],[1,1]*freqbands{iFB}(2),'k-');
    end
    xlim([-60,60])
    ylim([1,30])
    set(gca,'ydir','normal');
    h = colorbar;
    xlabel('Time relative to pupil size signal');
    set(get(h,'label'),'string','Correlation Pupil size x Power (Pearson''s R)');
    ylabel('Frequency (Hz)');
    savefig(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName,'_woAr'],'compact');
    print(fig,[cfigpath,filesep,'Corr_PupSize_x_TFPwr_',StaName,'_woAr'],'-dpng','-r300');
    close(fig);


    fig = figure('Position',[50,50,800,600]);
    hold on
    h = [];
    for iBand = 1:numel(freqbands)
        inds = gyt_within(freqs,freqbands{iBand});
        temph = drawMeanSEMPlot(timepointsCorrAuto/500,squeeze(nanmean(RSpecE(inds,:,gP,iSta)))',ccc(iBand,:));
        h(iBand) = temph(2);
    end
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    legend(h,freqbandNames);
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Pupil size x Power (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_PupSize_x_FBPwr_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_PupSize_x_FBPwr_',StaName],'-dpng','-r300');
    close(fig);
    
    
end

%% Plot cross-correlation pupil-size x physiological signals
    
statstp = (timepointsCorrAuto/500>-30)&(timepointsCorrAuto/500<30);
    
for iSta = 1:numel(sleepStages)
    
    gP = Nbouts(:,iSta)>thr_nbouts;
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    if ~exist(cfigpath,'dir')
        mkdir(cfigpath);
    end

    tmpdat = squeeze(RExHR(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);

    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Heart rate x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_HeartR_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_HeartR_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
    
    tmpdat = squeeze(RExHFHR(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Heart rate x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_HFHRV_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_HFHRV_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
    
    tmpdat = squeeze(RExLFHR(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Heart rate x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_LFHRV_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_LFHRV_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
    tmpdat = squeeze(RExHRratio(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation LF/HF ratio x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_LFHFr_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_LFHFr_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
    
    tmpdat = squeeze(RExB(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Breathing rate x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_Breath_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_Breath_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
    
    tmpdat = squeeze(RExM(:,gP,iSta))';
    
    stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    fig = figure('Position',[50,50,600,400]);
    hold on
    temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,[0,0,0]);
    plot(timepointsCorrAuto(statstp)/500,statline*0.01,'-','linewidth',5,'color',[0,0,0]);
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Muscle tone x pupil size (Pearson''s R)');
    savefig(fig,[cfigpath,filesep,'Corr_EMG_x_PupSize_',StaName],'compact');
    print(fig,[cfigpath,filesep,'Corr_EMG_x_PupSize_',StaName],'-dpng','-r300');
    close(fig);
    
end

%% Cross-correlation pupil all stages on the same plot

cStages = [1,5,6];

statstp = (timepointsCorrAuto/500>-30)&(timepointsCorrAuto/500<30);

for iBand = 1:numel(freqbands)
    Fband = freqbands{iBand};


    fig = figure('Position',[50,50,400,300]);
    hold on
    h = [];
    for iSta = 1:numel(cStages)
        cSta = cStages(iSta);
        gP = Nbouts(:,cSta)>thr_nbouts;
        inds = gyt_within(freqs,Fband);
        tmpdat = squeeze(nanmean(RSpecE(inds,:,gP,cSta)))';
        
        stats = gyt_ft_TFRclusterperm({permute(tmpdat(:,statstp),[1,3,2,4]),permute(zeros(size(tmpdat(:,statstp))),[1,3,2,4])},0.05,'yes',5000);
        statline = nan(1,numel(stats.mask));
        statline(squeeze(stats.mask)==1) = 1;
        plot(timepointsCorrAuto(statstp)/500,statline*(0.1-iSta*0.01),'-','color',cccSta(cSta,:),'linewidth',2)
        
        temph = drawMeanSEMPlot(timepointsCorrAuto/500,tmpdat,cccSta(cSta,:));
        h(iSta) = temph(2);
    end
    plot([-100,100],[0,0],'k--');
    plot([0,0],ylim,'k--');
    legend(h,sleepStageNames(cStages));
    xlim([-60,60]);
    xlabel('Time relative to pupil size signal (s)');
    ylabel('Correlation Pupil size x Power (Pearson''s R)');
    savefig(fig,[figpath,filesep,'Corr_PupSize_x_',freqbandNames{iBand}],'compact');
    print(fig,[figpath,filesep,'Corr_PupSize_x_',freqbandNames{iBand}],'-dpng','-r300');
    close(fig);
end

%% Fast eye dilation- and constriction-related responses

for iSta = 1:numel(sleepStages)
    
    
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    

    gP = squeeze(all(~isnan(EREPSpec(1,:,:,iSta)),2))&squeeze(all(~isnan(EREPE(:,:,iSta)),1))';
    
    fig = figure('Position',[50,50,800,600]);
    subplot(8,1,1:2)
    hold on
    gyt_heatmap((winERP(1)*500:50:winERP(2)*500)/500,1:30,nanmean(EREPSpec(1:30,:,gP,iSta),3),4);
    colormap(cmocean('balance'))
%     colorbar();
    caxis([-3,3])
    ylim([1,30])
    xlim([winERP(1),winERP(2)])
    plot([0,0],ylim,'k--');
    ylabel('Frequency (Hz)');
    
    subplot(8,1,3)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,EREPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,4)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERHRPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Heart-rate (bpm)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,5)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERHFHRVPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('HFHRV');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,6)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERArPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Arousal probability');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,7)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,EREMGPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Muscle tone');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,8)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERBPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Breathing rate');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlabel('Time (s)');
    
    savefig(fig,[cfigpath,filesep,'ERP_EyeDil_',StaName],'compact');
    print(fig,[cfigpath,filesep,'ERP_EyeDil_',StaName],'-dpng','-r300');
    close(fig);
    
    fig = figure('Position',[50,50,1000,600]);
    hold on
    tmph = nan(1,numel(freqbands));
    for iF=1:numel(freqbands)
        temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(nanmean(EREPSpec(freqbands{iF}(1):freqbands{iF}(2),:,gP,iSta)))',ccc(iF,:));
        tmph(iF) = temph(2);
    end
%     drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(EREPSpin(:,gP,iSta))'*20,[0,0,0]);
%     drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(ERHFHRVPE(:,gP,iSta))',[0,0,0],0.2,'linestyle','-');
    ylim([-3,3])
    xlim([-5,25])
    ylabel('Power (dB)');
    yyaxis right
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,EREPE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlabel('Time (s)');
    ylim([-15,15])
    legend(tmph,freqbandNames);
    savefig(fig,[cfigpath,filesep,'ERP_EyeDil_FB'],'compact');
    print(fig,[cfigpath,filesep,'ERP_EyeDil_FB'],'-dpng','-r300');
    close(fig);
    
    
    gP = squeeze(all(~isnan(ERENSpec(1,:,:,iSta)),2))&squeeze(all(~isnan(ERENE(:,:,iSta)),1))';
    
    fig = figure('Position',[50,50,800,600]);
    subplot(8,1,1:2)
    hold on
    gyt_heatmap((winERP(1)*500:50:winERP(2)*500)/500,1:30,nanmean(ERENSpec(1:30,:,gP,iSta),3),4);
    colormap(cmocean('balance'))
%     colorbar();
    caxis([-3,3])
    ylim([1,30])
    xlim([winERP(1),winERP(2)])
    plot([0,0],ylim,'k--');
    ylabel('Frequency (Hz)');
    
    subplot(8,1,3)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERENE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,4)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERHRNE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Heart-rate (bpm)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,5)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERHFHRVNE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('HFHRV');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,6)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERArNE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Arousal probability');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,7)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,EREMGNE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Muscle tone');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    
    subplot(8,1,8)
    hold on
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERBNE(:,gP,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Breathing rate');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    xlabel('Time (s)');
    
    savefig(fig,[cfigpath,filesep,'ERP_EyeConst_',StaName],'compact');
    print(fig,[cfigpath,filesep,'ERP_EyeConst_',StaName],'-dpng','-r300');
    close(fig);
    
    
    
    fig = figure('Position',[50,50,1000,600]);
    hold on
    tmph = nan(1,numel(freqbands));
    for iF=1:numel(freqbands)
        temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(nanmean(ERENSpec(freqbands{iF}(1):freqbands{iF}(2),:,:,iSta)))',ccc(iF,:));
        tmph(iF) = temph(2);
    end
%     drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(ERENSpin(:,gP,iSta))'*20,[0,0,0]);
%     drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,squeeze(ERHFHRVNE(:,:,iSta))',[0,0,0],0.2,'linestyle','-');
    ylim([-3,3])
    xlim([-5,25])
    ylabel('Power (dB)');
    yyaxis right
    drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERENE(:,:,iSta)',[0,0,0],0.2,'linestyle','-');
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    ylim([-15,15])
    xlabel('Time (s)');
    legend(tmph,freqbandNames);
    savefig(fig,[cfigpath,filesep,'ERP_EyeConst_FB'],'compact');
    print(fig,[cfigpath,filesep,'ERP_EyeConst_FB'],'-dpng','-r300');
    close(fig);
end


%%

for iSta = 1:numel(sleepStages)
    
    
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    %%% ERPs (long-scale)

    fig = figure('Position',[50,50,800,600]);
    hold on
    h = [];
    temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERbetaB(:,:,iSta)',ccc(5,:));
    h(1) = temph(2);
    ylabel('Beta power (dB)');
    ylim([-10,10])
    
    hold on
    yyaxis right
    temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ERbetaE(:,:,iSta)',[1,0,0]);
    h(2) = temph(2);
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    ylim([-10,10])
    
    legend(h,{'Beta power','Pupil size'});
    xlabel('Time (s)');
    savefig(fig,[cfigpath,filesep,'ERP_Beta'],'compact');
    print(fig,[cfigpath,filesep,'ERP_Beta'],'-dpng','-r300');
    close(fig);
    
    
    fig = figure('Position',[50,50,800,600]);
    hold on
    h = [];
    temph = drawMeanSEMPlot((winERPISO(1)*500:50:winERPISO(2)*500)/500,ERsigmaS(:,:,iSta)',ccc(4,:));
    h(1) = temph(2);
    ylabel('Sigma power (dB)');
    ylim([-3,3])
    
    temph = drawMeanSEMPlot((winERPISO(1)*500:50:winERPISO(2)*500)/500,ERsigmaHFHRV(:,:,iSta)'*0.2,[0,0,0]);
    h(2) = temph(2);
    ylabel('Sigma power (dB)');
    ylim([-3,3])
    
    temph = drawMeanSEMPlot((winERPISO(1)*500:50:winERPISO(2)*500)/500,ERsigmaSW(:,:,iSta)'*50,[0,0,0]);
    h(2) = temph(2);
    ylabel('Sigma power (dB)');
    ylim([-3,3])
    
    yyaxis right
    temph = drawMeanSEMPlot((winERPISO(1)*500:50:winERPISO(2)*500)/500,ERsigmaE(:,:,iSta)',[1,0,0],0.2,'linestyle','-');
    h(3) = temph(2);
    ylabel('Pupil size (pixels)');
    plot(winERPISO,[0,0],'k--');
    plot([0,0],ylim,'k--');
    ylim([-5,5])
    
    legend(h,{'Sigma power','RMSSD','Pupil size'});
    xlabel('Time (s)');
    savefig(fig,[cfigpath,filesep,'ERP_Sigma'],'compact');
    print(fig,[cfigpath,filesep,'ERP_Sigma'],'-dpng','-r300');
    close(fig);
    

    
    
    fig = figure('Position',[50,50,800,600]);
    hold on
    h = [];
    temph = drawMeanSEMPlot((winERPse(1)*500:winsizeSET:winERPse(2)*500)/500,ERSWEEG(:,:,iSta)',[0,0,1]);
    h(1) = temph(2);
    ylabel('EEG (dB)');
    ylim([-120,120]);
    hold on
    
    
    yyaxis right
    temph = drawMeanSEMPlot((winERPse(1)*500:winsizeSET:winERPse(2)*500)/500,ERSWE(:,:,iSta)',[1,0,0]);
    h(2) = temph(2);
    ylabel('Pupil size (pixels)');
    plot(winERPse,[0,0],'k--');
    plot([0,0],ylim,'k--');
    ylim([-8,8]);
    
    legend(h,{'Beta power','Pupil size'});
    xlabel('Time (s)');
    savefig(fig,[cfigpath,filesep,'ERP_SW'],'compact');
    print(fig,[cfigpath,filesep,'ERP_SW'],'-dpng','-r300');
    close(fig);
end
%% ERP Arousal-locked
    
for iSta = 1:numel(sleepStages)
    
    
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    fig = figure('Position',[50,50,800,600]);
    subplot(2,1,1)
    gyt_heatmap((winERP(1)*500:50:winERP(2)*500)/500,freqs,nanmean(ArER_TFR(:,:,:,iSta),3),4);
    uistack(gca,'top');
    set(gca,'ydir','normal')
    hold on
    plot([0,0],[1,30],'k--');
    xlim(winERP)
    ylim([1,30])
    colormap(cmocean('balance'))
    colorbar;
    xlabel('Time(s)')
    ylabel('Frequency (Hz)')
    
    subplot(2,1,2)
    hold on
    h = [];
    temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ArER_EEG(:,:,iSta)',[0,0,1]);
    h(1) = temph(2);
    ylabel('EEG (microV)');
    ylim([-20,20]);
    hold on
    
    
    yyaxis right
    temph = drawMeanSEMPlot((winERP(1)*500:50:winERP(2)*500)/500,ArER_Eye(:,:,iSta)',[1,0,0]);
    h(2) = temph(2);
    ylabel('Pupil size (pixels)');
    plot(winERP,[0,0],'k--');
    plot([0,0],ylim,'k--');
    ylim([-20,20]);
    
%     legend(h,{'Beta power','Pupil size'});
    xlabel('Time (s)');
    savefig(fig,[cfigpath,filesep,'ERP_Ar_',StaName],'compact');
    print(fig,[cfigpath,filesep,'ERP_Ar_',StaName],'-dpng','-r300');
    close(fig);
    
end

%% Probability of large eye dilation

for iSta = 1:numel(sleepStages)
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    %%% ERPs (long-scale)

    fig = figure('Position',[50,50,400,300]);
    hold on
    h = [];
    temph = drawMeanSEMPlot(eyerange,probEye(:,:,iSta),[0,0,0]);
    h(1) = temph(2);
    temph = drawMeanSEMPlot(eyerange,EREPprob(:,:,iSta)',[0.5,0.5,0.5]);
    h(2) = temph(2);
    ylabel('Probability of occurence');
    xlabel('Pupil size at occurence (pixel)')
    ylim([0,0.3])
    xlim([0,120])
    
%     ME = nansum(probEye(:,:,iSta).*repmat(eyerange,[size(probEye,1),1]),2);
%     ME(ME==0) = nan;
    [Det,Imax] = nanmax(probEye(:,:,iSta),[],2);
    ME = eyerange(Imax);
    ME(isnan(Det)) = nan;
    [Det,Imax] = nanmax(EREPprob(:,:,iSta)',[],2);
    MDil = eyerange(Imax);
    MDil(isnan(Det)) = nan;
%     MDil = nansum(EREPprob(:,:,iSta)'.*repmat(eyerange,[size(probEye,1),1]),2);
%     MDil(MDil==0) = nan;

    y = brownianDistribution(ME,0,1);
    scatter(ME,ones(1,numel(ME))*0.28+y*0.002,'o','sizedata',3,'markerfacecolor',[0.5,0.5,0.5],'markeredgecolor',[0,0,0]);
    plot([min(ME),max(ME)],[1,1]*0.285,'k-','linewidth',1);
    fill([quantile(ME,0.25),quantile(ME,0.75),quantile(ME,0.75),quantile(ME,0.25)],[-1,-1,1,1]*0.002+0.285,[0.5,0.5,0.5]);
    plot([1,1]*nanmedian(ME),[-1,1]*0.002+0.285,'k-','linewidth',2)
    
    y = brownianDistribution(MDil,0,1);
    scatter(MDil,ones(1,numel(MDil))*0.26+y*0.002,'o','sizedata',3,'markerfacecolor',[0.8,0.8,0.8],'markeredgecolor',[0,0,0]);
    plot([min(MDil),max(MDil)],[1,1]*0.265,'k-','linewidth',1);
    fill([quantile(MDil,0.25),quantile(MDil,0.75),quantile(MDil,0.75),quantile(MDil,0.25)],[-1,-1,1,1]*0.002+0.265,[0.8,0.8,0.8]);
    plot([1,1]*nanmedian(MDil),[-1,1]*0.002+0.265,'k-','linewidth',2)
    plot([20,20],[0.265,0.285],'k-','linewidth',2);
    [h0,p,ci,stat] = ttest(ME-MDil);
    if p<0.001
        text(18,0.275,'***','horizontalalignment','center','rotation',90);
    elseif p<0.01
        text(18,0.275,'**','horizontalalignment','center','rotation',90);
    elseif p<0.05
        text(18,0.275,'*','horizontalalignment','center','rotation',90);
    elseif p<0.1
        text(18,0.275,'~','horizontalalignment','center','rotation',90);
    else
        text(18,0.275,'n.s.','horizontalalignment','center','rotation',90);
    end
    
    legend(h,{'Overall distribution','Fast dilations'});
    savefig(fig,[cfigpath,filesep,'Prob_PupDil'],'compact');
    print(fig,[cfigpath,filesep,'Prob_PupDil'],'-dpng','-r300');
    close(fig);
    
end

%% Probability of spindle and K-complex generation


for iSta = 1:numel(sleepStages)
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    %%% ERPs (long-scale)

    fig = figure('Position',[50,50,400,300]);
    hold on
    h = [];
    temph = drawMeanSEMPlot(eyerange,probSpin(:,:,iSta),[0,0,0]);
    h(1) = temph(2);
    temph = drawMeanSEMPlot(eyerange,probSW(:,:,iSta),[0.5,0.5,0.5]);
    h(2) = temph(2);
    ylabel('Probability of occurence');
    xlabel('Pupil size at occurence (pixel)')
    ylim([0,0.3])
    xlim([10,100])
    
    
    [Det,Imax] = nanmax(probSpin(:,:,iSta),[],2);
    Mspin = eyerange(Imax)';
    Mspin(isnan(Det)) = nan;
    [Det,Imax] = nanmax(probSW(:,:,iSta),[],2);
    MswI = eyerange(Imax)';
    MswI(isnan(Det)) = nan;
%     
%     Mspin = nansum(probSpin(:,:,iSta).*repmat(eyerange,[size(probSpin,1),1]),2);
%     Mspin(Mspin==0) = nan;
%     MswI = nansum(probSW(:,:,iSta).*repmat(eyerange,[size(probSW,1),1]),2);
%     MswI(MswI==0) = nan;
    
    yspin = brownianDistribution(Mspin,0,1);
    yswI = brownianDistribution(MswI,0,1);
    plot([Mspin,MswI]',[yspin'*0.002+0.28,yswI'*0.002+0.27]','k-')
    
    scatter(Mspin,ones(1,numel(Mspin))*0.28+yspin*0.002,'o','sizedata',3,'markerfacecolor',[0.5,0.5,0.5],'markeredgecolor',[0,0,0]);
    plot([min(Mspin),max(Mspin)],[1,1]*0.285,'k-','linewidth',1);
    fill([quantile(Mspin,0.25),quantile(Mspin,0.75),quantile(Mspin,0.75),quantile(Mspin,0.25)],[-1,-1,1,1]*0.002+0.285,[0.5,0.5,0.5]);
    plot([1,1]*nanmedian(Mspin),[-1,1]*0.002+0.285,'k-','linewidth',2)
    
    scatter(MswI,ones(1,numel(MswI))*0.27+yswI*0.002,'o','sizedata',3,'markerfacecolor',[0.8,0.8,0.8],'markeredgecolor',[0,0,0]);
    plot([min(MswI),max(MswI)],[1,1]*0.265,'k-','linewidth',1);
    fill([quantile(MswI,0.25),quantile(MswI,0.75),quantile(MswI,0.75),quantile(MswI,0.25)],[-1,-1,1,1]*0.002+0.265,[0.8,0.8,0.8]);
    plot([1,1]*nanmedian(MswI),[-1,1]*0.002+0.265,'k-','linewidth',2)
    plot([20,20],[0.265,0.285],'k-','linewidth',2);
    
    [h0,p,ci,stat] = ttest(MswI-Mspin);
    if p<0.001
        text(18,0.275,'***','horizontalalignment','center','rotation',90);
    elseif p<0.01
        text(18,0.275,'**','horizontalalignment','center','rotation',90);
    elseif p<0.05
        text(18,0.275,'*','horizontalalignment','center','rotation',90);
    elseif p<0.1
        text(18,0.275,'~','horizontalalignment','center','rotation',90);
    else
        text(18,0.275,'n.s.','horizontalalignment','center','rotation',90);
    end
    
    legend(h,{'Spindles','K-complexes'});
    savefig(fig,[cfigpath,filesep,'Prob_Grapho'],'compact');
    print(fig,[cfigpath,filesep,'Prob_Grapho'],'-dpng','-r300');
    close(fig);
    
end

%% Prob of generating an arousal


for iSta = 1:numel(sleepStages)
    
    StaName = sleepStageNames{iSta}; 
    
    cfigpath = [figpath,filesep,StaName];
    
    %%% ERPs (long-scale)

    fig = figure('Position',[50,50,400,300]);
    hold on
    h = [];
    temph = drawMeanSEMPlot(eyerange,ArER_prob(:,:,iSta)',[0,0,0]);
    h(1) = temph(2);
    ylabel('Probability of occurence');
    xlabel('Pupil size at occurence (pixel)')
    ylim([0,0.3])
    xlim([10,100])
end

%%

ccc2 = gyt_ColorPalet/256;
ccc2 = ccc2([7,6,4],:);

cfreqs = [3,6,9,14,21];

substa = [1,5,6];
fig = figure('Position',[50,50,800,600]);
h = [];
for iSta=1:numel(substa)
    gP = Nbouts(:,substa(iSta))>thr_nbouts;
    allV = nan(size(RSpecE,3),numel(freqbandNames));
    allT = nan(size(RSpecE,3),numel(freqbandNames));
    for iBand = 1:numel(freqbands)
        indsF = gyt_within(freqs,freqbands{iBand});
        indsT = find(gyt_within(timepointsCorrAuto/500,[-25,25]));
        tmpDat = squeeze(nanmean(RSpecE(indsF,indsT,gP,substa(iSta)),1))';
        [M,I] = nanmax(abs(tmpDat),[],2);
        V = tmpDat(sub2ind(size(tmpDat),1:size(tmpDat,1),I'));
        V(isnan(M))=nan;
        allV(gP,iBand) = V;
        T = timepointsCorrAuto(indsT(1)-1+I)/500;
        T(isnan(M))=nan;
        allT(gP,iBand) = T;
    end
    
    subplot(1,2,1)
    hold on
    drawMeanSEMPlot(1:numel(freqbandNames),allV,ccc2(iSta,:));
    
    subplot(1,2,2)
    hold on
    drawMeanSEMPlot(1:numel(freqbandNames),allT,ccc2(iSta,:));
    
end
        
subplot(1,2,1)
hold on
plot([0.5,5.5],[0,0],'k--');
xlabel('Frequency Band');
ylabel('Pearson''s R')
set(gca,'xtick',1:numel(freqbandNames),'xticklabel',freqbandNames,'xticklabelrotation',45)

subplot(1,2,2)
hold on
plot([0.5,5.5],[0,0],'k--');
xlabel('Frequency Band');
ylabel('Delay (s)')
set(gca,'xtick',1:numel(freqbandNames),'xticklabel',freqbandNames,'xticklabelrotation',45)

savefig(fig,[figpath,filesep,'CrossCorr_Details_PupSize_x_FBPwr'],'compact');
print(fig,[figpath,filesep,'CrossCorr_Details_PupSize_x_FBPwr'],'-dpng','-r300');
close(fig);
