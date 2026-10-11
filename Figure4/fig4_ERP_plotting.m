

%% Initialization


clear all; clearvars; clc;

ft_defaults();

%%% Define pathes
% Define mainpath of the experiement relative to the path of the script
[Mainpath,~,~] = fileparts(fileparts(mfilename('fullpath')));
% Define data path
datapath = [Mainpath,filesep,'data'];
% Define Result path
respath = [Mainpath,filesep,'Results'];
% Define figure path
figpath = [respath,filesep,'Figures'];
if ~exist(figpath,'dir')
    mkdir(figpath);
end
% List subfolder (sessions) in data path
tempfold = dir([respath,filesep,'pup*']);
subfolders = {tempfold.name};

%% Parameters for the ERPs

% Timings, in seconds, pre- and post- stimulation of the Event-Related
% Potentials
ERPboundaries = [-0.5,2];
% Timings for the baseline
ERPbaseline = [-0.2,0];


% Timings, in seconds, pre- and post- stimulation of the time-frequency
% evoked power increase
TFRboundaries = [-2,5];
% Timings for the baseline
TFRbaseline = [-1,-0.25];
% Downsmapling of time-frequency plots
TFRds = 10;

% Timings for the stats
ERPstats = [0,1];

% Timings for topographies
topoT = {[0.15,0.25],[0.5,0.6]};

% Stats params
alphathr = 0.05;

% Sleep stages and stages names, "NREM = N2+N3"
stages = {[0],[1],[2],[3],[2,3],[5],[0,1,2,3,5]};
stageNames = {'Wake','N1','N2','N3','NREM','REM','All'};


elSideLab = {'Contralateral','Ispilateral'};
elSideLabr = {'Contra','Ispi'};

FOI = 1:30;
HOI = linspace(1,10,numel(FOI))./FOI;


colorslplot = [204, 85, 0;1, 63, 78]/256.0;

load('acticap-64ch-standard2.mat');
chans = {'F3','F4','C3','C4','P3','P4','O1','O2','F7','F8','T7','T8',...
    'P7','P8','Fz','Cz','Pz','Oz','FC1','FC2','CP1','CP2','FC5','FC6',...
    'CP5','CP6','TP9' ,'TP10','POz' };
layout = [];
layout.pos = nan(numel(chans),2);
layout.label = chans;
for iChan = 1:numel(chans)
    layout.pos(iChan,:) = lay.pos(find(ismember(lay.label,chans{iChan})),:);
end
fliplay = 1:numel(chans);
for iE = 1:numel(chans)
    nums = find(ismember(chans{iE},'0123456789'));
    if ~isempty(nums)
        num = str2num(chans{iE}(nums));
        if mod(num,2)==1
            fliplay(iE) = find(ismember(chans,[chans{iE}(1:nums(1)-1),num2str(num+1)]));
        else
            fliplay(iE) = find(ismember(chans,[chans{iE}(1:nums(1)-1),num2str(num-1)]));
        end
    end
end

   
res_file = [respath,filesep,'results_erps.mat'];

if ~exist(res_file,'file')

    epT = (round(ERPboundaries(1)*500):round(ERPboundaries(2)*500))/500;
    epTFRt = (round(TFRboundaries(1)*500):TFRds:round(TFRboundaries(2)*500))/500;

    allTERPn = [];
    allTERPs = [];
    allTTFRs = [];
    allTPhis = [];

    allCERPn = [];
    allCERPs = [];
    allCTFRs = [];
    allCPhis = [];

    Elist = [];

    SubList = {};
    SesList = {};

    %% Loop on every EEG file
    for iSub = 1:numel(subfolders)

        tempfold = dir([respath,filesep,subfolders{iSub},filesep,'*ses*']);
        sessionsfolders = {tempfold.name};

        % Create folder for results of the participant
        partResDir = [respath,filesep,subfolders{iSub}];
        if ~exist(partResDir,'dir')
            mkdir(partResDir);
        end

        for iSes = 1:numel(sessionsfolders)

            SubList = cat(2,SubList,subfolders(iSub));
            SesList = cat(2,SesList,sessionsfolders(iSes));

            % Create folder for results of the session
            sesResDir = [partResDir,filesep,sessionsfolders{iSes}];
            if ~exist(sesResDir,'dir')
                mkdir(sesResDir);
            end

            %%

            sesFile = [sesResDir,filesep,'Results.mat'];

            if exist(sesFile,'file')
                load(sesFile);

                %%
                sesFigDir = [sesResDir,filesep,'Figures'];
                if ~exist(sesFigDir,'dir')
                    mkdir(sesFigDir);
                end

                % Get all the edf files in the folder
                files = dir([datapath,filesep,subfolders{iSub},filesep,sessionsfolders{iSes},filesep,'*.edf']);
                EEGfiles = {files.name};

                % Read side of tropicamid 
                sidefile = [datapath,filesep,subfolders{iSub},filesep,sessionsfolders{iSes},filesep,'side'];
                load(sidefile);
        %         fid = fopen(sidefile);
        %         side = fgetl(fid);
        %         fclose(fid);
                if side=='R'
                    c1t = [1]; %temporal right S1
                    c2t = [4]; %temporal left S4
                    ct = {c1t,c2t};
                    EOIs = [7,8]; % Electrodes of interest (in contralateral - ispilateral order)
                    sidelabel = {'Right','Left'};
                    sidelabelr = {'R','L'};
                elseif side=='L'
                    c1t = [4]; %temporal left S4
                    c2t = [1]; %temporal right S1
                    ct = {c1t,c2t};
                    EOIs = [8,7]; % Electrodes of interest (in contralateral - ispilateral order)
                    sidelabel = {'Left','Right'};
                    sidelabelr = {'L','R'};
                    if strcmpi(sessionsfolders{iSes},'20230710_pup024_sesnight02_TropL')
                        c1t = [6]; %temporal left S4
                        c2t = [3]; %temporal right S1
                        EOIs = [8,7]; % Electrodes of interest (in contralateral - ispilateral order)
                        sidelabel = {'Left','Right'};
                        sidelabelr = {'L','R'};
                    end
                end
                Elist = cat(1,Elist,EOIs);



                %% Baseline correction
                % Compute the indexes of the baseline
                baselineT = find((epT>=ERPbaseline(1))&(epT<=ERPbaseline(2)));

                % Baseline correction
                bepEEG = bsxfun(@minus,epEEG,mean(epEEG(:,baselineT,:),2));


                % Compute the indexes of the baseline
                baselineTFR = find((epTFRt>=TFRbaseline(1))&(epTFRt<=TFRbaseline(2)));

                % Baseline correction
                bepTFR = bsxfun(@minus,epTFR,mean(epTFR(:,:,baselineTFR,:),3));
                %% Separate the dataset in different stims

                %% 0 - wake , etc) 


                tmpTERPn = nan(length(stages),1);
                tmpTERPs = nan(length(stages),size(bepEEG,1),size(bepEEG,2));
                tmpTTFRs = nan(length(stages),size(bepTFR,1),size(bepTFR,2),size(bepTFR,3));
                tmpTPhis = nan(length(stages),size(bepTFR,1),size(bepTFR,2),size(bepTFR,3));
                tmpCERPn = nan(length(stages),1);
                tmpCERPs = nan(length(stages),size(bepEEG,1),size(bepEEG,2));
                tmpCTFRs = nan(length(stages),size(bepTFR,1),size(bepTFR,2),size(bepTFR,3));
                tmpCPhis = nan(length(stages),size(bepTFR,1),size(bepTFR,2),size(bepTFR,3));

                for iSta = 1:length(stages)

                    mrk1 = ismember(mrkV,c1t)&ismember(mrkSta,stages{iSta});
                    if sum(mrk1)>1
                        tmpTERPn(iSta) = sum(mrk1);
                        tmpTERPs(iSta,:,:) = mean(bepEEG(:,:,mrk1),3);
                        tmpTTFRs(iSta,:,:,:) = mean(bepTFR(:,:,:,mrk1),4);
                        datphi = abs(sum(exp(1i*epPhi(:,:,:,mrk1)),4))/sum(mrk1);
        %                 datphi = bsxfun(@minus,datphi,mean(datphi(:,:,baselineTFR),3));
                        tmpTPhis(iSta,:,:,:) = datphi;
                    end



                    mrk2 = ismember(mrkV,c2t)&ismember(mrkSta,stages{iSta});
                    if sum(mrk2)>1
                        tmpCERPn(iSta) = sum(mrk2);
                        tmpCERPs(iSta,:,:) = mean(bepEEG(:,:,mrk2),3);
                        tmpCTFRs(iSta,:,:,:) = mean(bepTFR(:,:,:,mrk2),4);
                        datphi = abs(sum(exp(1i*epPhi(:,:,:,mrk2)),4))/sum(mrk2);
        %                 datphi = bsxfun(@minus,datphi,mean(datphi(:,:,baselineTFR),3));
                        tmpCPhis(iSta,:,:,:) = datphi;
                    end

                end

                allTERPn = cat(2,allTERPn,tmpTERPn);
                allTERPs = cat(4,allTERPs,tmpTERPs);
                allTTFRs = cat(5,allTTFRs,tmpTTFRs);
                allTPhis = cat(5,allTPhis,tmpTPhis);
                allCERPn = cat(2,allCERPn,tmpCERPn);
                allCERPs = cat(4,allCERPs,tmpCERPs);
                allCTFRs = cat(5,allCTFRs,tmpCTFRs);
                allCPhis = cat(5,allCPhis,tmpCPhis);

            end
        end
    end
    
    save(res_file,'epT','epTFRt','allTERPn','allTERPs','allTTFRs','allTPhis','allCERPn','allCERPs','allCTFRs','allCPhis','Elist','SubList','SesList','-v7.3')
    
else
    load(res_file)
end

%%



latTERPs = allTERPs;
latTTFRs = allTTFRs;
latTPhis = allTPhis;

latCERPs = allCERPs;
latCPhis = allCPhis;
latCTFRs = allCTFRs;

for iP=1:size(allTERPs,4)
    if Elist(iP,1)==8
        latTERPs(:,:,:,iP) = allTERPs(:,fliplay,:,iP);
        latTTFRs(:,:,:,:,iP) = allTTFRs(:,fliplay,:,:,iP);
        latTPhis(:,:,:,:,iP) = allTPhis(:,fliplay,:,:,iP);
    else
        latCERPs(:,:,:,iP) = allCERPs(:,fliplay,:,iP);
        latCTFRs(:,:,:,:,iP) = allCTFRs(:,fliplay,:,:,iP);
        latCPhis(:,:,:,:,iP) = allCPhis(:,fliplay,:,:,iP);
    end
end

%%

sidedTERPs = nan(size(allTERPs,1),2,size(allTERPs,3),size(allTERPs,4));
sidedTTFRs = nan(size(allTTFRs,1),2,size(allTTFRs,3),size(allTTFRs,4),size(allTTFRs,5));
sidedTPhis = nan(size(allTPhis,1),2,size(allTPhis,3),size(allTPhis,4),size(allTPhis,5));
sidedCERPs = nan(size(allCERPs,1),2,size(allCERPs,3),size(allCERPs,4));
sidedCTFRs = nan(size(allCTFRs,1),2,size(allCTFRs,3),size(allCTFRs,4),size(allCTFRs,5));
sidedCPhis = nan(size(allCPhis,1),2,size(allCPhis,3),size(allCPhis,4),size(allCPhis,5));

for iP=1:size(sidedTERPs,4)
    sidedTERPs(:,:,:,iP) = allTERPs(:,Elist(iP,:),:,iP);
    sidedTTFRs(:,:,:,:,iP) = allTTFRs(:,Elist(iP,:),:,:,iP);
    sidedTPhis(:,:,:,:,iP) = allTPhis(:,Elist(iP,:),:,:,iP);
    
    sidedCERPs(:,:,:,iP) = allCERPs(:,fliplr(Elist(iP,:)),:,iP);
    sidedCTFRs(:,:,:,:,iP) = allCTFRs(:,fliplr(Elist(iP,:)),:,:,iP);
    sidedCPhis(:,:,:,:,iP) = allCPhis(:,fliplr(Elist(iP,:)),:,:,iP);
end

%%

fid2 = fopen([figpath,filesep,'NumberStim.tsv'],'wt+');
fprintf(fid2,'%s\t%s\t%s\t%s\t%s\n','SleepStage','Eye','Nsub','Nses','Nevents');

for iSta=1:size(allTERPn,1)
    gP = allTERPn(iSta,:)>0;
    
    fprintf(fid2,'%s\t%s\t%0.f\t%0.f\t%0.f\n',stageNames{iSta},'Tropicamid',numel(unique(SubList(gP))),sum(gP),sum(allTERPn(iSta,gP)));
    
    gP = allCERPn(iSta,:)>0;
    
    fprintf(fid2,'%s\t%s\t%0.f\t%0.f\t%0.f\n',stageNames{iSta},'Control',numel(unique(SubList(gP))),sum(gP),sum(allCERPn(iSta,gP)));
end

fclose(fid2);



%% ERP Avg occipital electrodes

% Define figure path
ERPpath = [figpath,filesep,'ERP'];
if ~exist(ERPpath,'dir')
    mkdir(ERPpath);
end

Oelecs = [7,8,18];

stattime = find((epT>0)&(epT<1));
topotime = find((epT>0.5)&(epT<1));
for iSta=1:numel(stages)

        
    datT = squeeze(nanmean(latTERPs(iSta,Oelecs,:,:),2))';
    datC = squeeze(nanmean(latCERPs(iSta,Oelecs,:,:),2))';
    
    
    stats = gyt_ft_TFRclusterperm({permute(datT(:,stattime),[1,3,2,4]),permute(datC(:,stattime),[1,3,2,4])},0.05,'yes',5000);
    statline = nan(1,numel(stats.mask));
    statline(squeeze(stats.mask)==1) = 1;
    
    
    m1 = squeeze(nanmean(datT,1));
    sem1 = squeeze(nanstd(datT,[],1)./sqrt(sum(~isnan(datT(:,1)),1)-1));
    m2 = squeeze(nanmean(datC,1));
    sem2 = squeeze(nanstd(datC,[],1)./sqrt(sum(~isnan(datC(:,1)),1)-1));
    
    h=[];
    fig = figure('position',[50,50,800,400]);
    hold on
    fill([epT,fliplr(epT)],[m1+sem1,fliplr(m1-sem1)],colorslplot(1,:),'facealpha',0.2);
    h(1) = plot(epT,m1,'color',colorslplot(1,:),'linewidth',2);
    fill([epT,fliplr(epT)],[m2+sem2,fliplr(m2-sem2)],colorslplot(2,:),'facealpha',0.2);
    h(2) = plot(epT,m2,'color',colorslplot(2,:),'linewidth',2);
    plot(epT(stattime),statline*10,'k-','linewidth',4);
    xlim(ERPboundaries)
    ylim([-15,15])
    plot(xlim,[0,0],'k--')
    plot([0,0],ylim,'k--')
    title([stageNames{iSta},' - Avg Occipital '])
    legend(h,{'Trop','Ctrl'});

    figname = [ERPpath,filesep,'ERP_Occipital_',stageNames{iSta}];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
    
end


%% TFR - Scalp average


% Define figure path
TFRpath = [figpath,filesep,'TFR'];
if ~exist(TFRpath,'dir')
    mkdir(TFRpath);
end

StageClimsBase = {[-2,2],[-2,2],[-1.5,1.5],[-1.5,1.5],[-1,1],[-2,2],[-1,1]};
StageClims = {[-1.5,1.5],[-1.5,1.5],[-1,1],[-1,1],[-1,1],[-2,2],[-0.5,0.5]};


FreqBand = {[1,4],[4,8],[8,12],[12,15],[15,30]};
FreqBandNames = {'Delta','Theta','Alpha','Sigma','Beta'};


stattime = find((epTFRt>0)&(epTFRt<3));

for iSta=1:numel(stages)
    
    fig = figure('position',[50,50,1200,200]);
        
    subplot(1,3,1)
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allTTFRs(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    caxis(StageClimsBase{iSta})
    colorbar();
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Trop'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    colormap(cmocean('balance'))

    subplot(1,3,2)
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allCTFRs(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    caxis(StageClimsBase{iSta})
    colorbar();
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Ctrl'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')


%     tmpdat = squeeze(nanmean(allTTFRs(iSta,:,:,stattime,:)-allCTFRs(iSta,:,:,stattime,:),2));
%     tmpdat = tmpdat(:,:,squeeze(~isnan(tmpdat(1,1,:))));
%     [clusters,clustH,clustT,clustP] = clusterPermutation({tmpdat},3,0.05,5000,'sum');
%     statmap = nan(size(tmpdat,1),size(tmpdat,2));
%     statmap([clusters{find(clustP<0.05)}]) = 1;


    subplot(1,3,3)
    
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allTTFRs(iSta,:,:,:,:)-allCTFRs(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    caxis(StageClims{iSta})
%     contour(epTFRt(stattime),FOI,squeeze(+(statmap>0)),'color','k')
    colorbar();
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Diff'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    colormap(cmocean('balance'))
    
    figname = [TFRpath,filesep,'Avg_TFR_',stageNames{iSta}];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
end



%% TFR - Scalp average - divided in freq bands


% Define figure path
TFRpath = [figpath,filesep,'TFR'];
if ~exist(TFRpath,'dir')
    mkdir(TFRpath);
end


FreqBand = {[1,4],[4,8],[8,12],[12,15],[15,30],[4,30]};
FreqBandNames = {'Delta','Theta','Alpha','Sigma','Beta','Broadband'};

addE = [16,15];
stattime = find((epTFRt>0)&(epTFRt<2));
mtime = find((epTFRt>1)&(epTFRt<3));

for iSta=1:numel(stages)
    
    fid = fopen([TFRpath,filesep,'PWR_stim_stats_',stageNames{iSta},'.log'],'wt+');
    
    fig = figure('position',[50,50,1200,300]);
    for iFB = 1:numel(FreqBand)
        
        cF = find((FOI>=FreqBand{iFB}(1))&(FOI<=FreqBand{iFB}(2)));
        
            
        datT = squeeze(nanmean(nanmean(allTTFRs(iSta,:,cF,:,:),2),3))';
        datC = squeeze(nanmean(nanmean(allCTFRs(iSta,:,cF,:,:),2),3))';

%         tmpdat = datT(:,stattime)-datC(:,stattime);
%         tmpdat = tmpdat(~isnan(tmpdat(:,1)),:);
% %         [clusters,clustH,clustT,clustP] = clusterPermutation({tmpdat},1,0.05,5000,'sum');
% %         statline = nan(1,size(tmpdat,2));
% %         statline([clusters{find(clustP<0.05)}]) = 1;
%         
%         [h,p] = ttest(tmpdat);
%         statline = nan(1,size(tmpdat,2));
%         statline(p<0.05) = 1;
            
        stats = gyt_ft_TFRclusterperm({permute(datT(:,stattime),[1,3,2,4]),permute(datC(:,stattime),[1,3,2,4])},0.05,'yes',5000);
        [statline,msg] = pup_getlinestats(epTFRt(stattime),datT(:,stattime),stats);
        fprintf(fid,'Stats on %s\n',FreqBandNames{iFB});
        fprintf(fid,msg);


        m1 = squeeze(nanmean(datT));
        sem1 = squeeze(nanstd(datT)./sqrt(sum(~isnan(datT(:,1)),1)-1));
        m2 = squeeze(nanmean(datC));
        sem2 = squeeze(nanstd(datC)./sqrt(sum(~isnan(datC(:,1)),1)-1));

        subplot(1,numel(FreqBand),iFB)
        hold on
        fill([epTFRt,fliplr(epTFRt)],[m1+sem1,fliplr(m1-sem1)],colorslplot(1,:),'facealpha',0.2);
        h(1) = plot(epTFRt,m1,'color',colorslplot(1,:),'linewidth',2);
        fill([epTFRt,fliplr(epTFRt)],[m2+sem2,fliplr(m2-sem2)],colorslplot(2,:),'facealpha',0.2);
        h(2) = plot(epTFRt,m2,'color',colorslplot(2,:),'linewidth',2);
        plot(epTFRt(stattime),statline*0.5,'k-','linewidth',4);
        xlim([-1,3])
        ylim([-2,2])
        plot(xlim,[0,0],'k--')
        plot([0,0],ylim,'k--')
        xlabel('Time (s)')
        ylabel('Power (dB)')
        title([stageNames{iSta},' - ',FreqBandNames{iFB}])

    end
    
    figname = [TFRpath,filesep,'Avg_FB_',stageNames{iSta}];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
    
    fclose(fid);
end


%% Phi Avg scalp

% Define figure path
Phipath = [figpath,filesep,'ITPC'];
if ~exist(Phipath,'dir')
    mkdir(Phipath);
end

FreqBand = {[1,4],[4,8],[8,12],[12,15],[15,30]};
FreqBandNames = {'Delta','Theta','Alpha','Sigma','Beta'};

ColorLimsBase = {[0.15,0.35],[0.15,0.35],[0,0.25],[0,0.25],[0,0.25],[0.15,0.35],[0,0.25]};


stattime = find((epTFRt>0)&(epTFRt<2));

for iSta=1:numel(stages)
    
    fig = figure('position',[50,50,800,200]);

    subplot(1,2,1)
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allTPhis(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
    caxis(ColorLimsBase{iSta})
%     colormap(flipud(cmocean('matter')))
    colormap(cmocean('balance'))
    colorbar();
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Trop'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')

    subplot(1,2,2)
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allCPhis(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
    caxis(ColorLimsBase{iSta})
    colorbar();
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Ctrl'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')

    %         [~,p] = ttest(sidedTPhis(iSta,iE,:,:,:)-sidedCPhis(iSta,iE,:,:,:),0,'dim',5);tmpdat = squeeze(allTPhis(iSta,addE(iE),:,:,:)-allCPhis(iSta,addE(iE),:,:,:));
%     tmpdat = squeeze(nanmean(allTPhis(iSta,:,:,stattime,:)-allCPhis(iSta,:,:,stattime,:),2));
%     tmpdat = tmpdat(:,:,squeeze(~isnan(tmpdat(1,1,:))));
%     [clusters,clustH,clustT,clustP] = clusterPermutation({tmpdat},3,alphathr,2000,'sum');
%     statmap = nan(size(tmpdat,1),size(tmpdat,2));
%     statmap([clusters{find(clustP<0.05)}]) = 1;

    figname = [Phipath,filesep,'ITPC_Avg_',stageNames{iSta},'_base'];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
    
    fig = figure('position',[50,50,400,200]);
    gyt_heatmap(epTFRt,FOI,squeeze(nanmean(nanmean(allTPhis(iSta,:,:,:,:)-allCPhis(iSta,:,:,:,:),2),5)),4);
    uistack(gca,'top')
    set(gca,'ydir','normal')
    hold on
    for iFB=1:numel(FreqBand)
        plot([-1,3],[1,1]*FreqBand{iFB}(1),'k-')
        plot([-1,3],[1,1]*FreqBand{iFB}(2),'k-')
    end
    plot([0,0],[1,30],'k-')
    plot([0.5,0.5],[1,30],'k-')
%     contour(epTFRt(stattime),FOI,squeeze(+(statmap>0)),'color','k')
    caxis([-0.1,0.1])
    colormap(cmocean('balance'))
    cbar = colorbar();
    cbar.Label.String = sprintf('\delta ITPC (a.u.)');
    xlim([-1,3])
    ylim([1,30])
    title([stageNames{iSta},' - Avg - Diff'])
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    
    figname = [Phipath,filesep,'ITPC_Avg_',stageNames{iSta},'_diff'];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
end


%%

FreqBand = {[1,4],[4,8],[8,12],[12,15],[15,30]};
FreqBandNames = {'Delta','Theta','Alpha','Sigma','Beta'};

stattime = find((epTFRt>0)&(epTFRt<1));
for iSta=1:numel(stages)
    
    
    
    fid = fopen([Phipath,filesep,'Avg_FB_',stageNames{iSta},'.log'],'wt+');
    
    fprintf(fid,['Pupil dilations:\n\n']);
    
    fig = figure('position',[50,50,1600,400]);
    for iFB=1:numel(FreqBand)
        cF = find((FOI>=FreqBand{iFB}(1))&(FOI<=FreqBand{iFB}(2)));

        datT = squeeze(nanmean(nanmean(allTPhis(iSta,:,cF,:,:),2),3))';
        datC = squeeze(nanmean(nanmean(allCPhis(iSta,:,cF,:,:),2),3))';
        
%         tmpdat = squeeze(nanmean(nanmean(allTPhis(iSta,:,cF,stattime,:)-allCPhis(iSta,:,cF,stattime,:),2),3));
%         tmpdat = tmpdat(:,squeeze(~isnan(tmpdat(1,:))));
%         [clusters,clustH,clustT,clustP] = clusterPermutation({tmpdat},2,alphathr,5000,'sum');
%         statmap = nan(size(tmpdat,1),1);
%         statmap([clusters{find(clustP<0.05)}]) = 1;
% 
%         [~,p,~,stat] = ttest(tmpdat,0,'dim',2);
        
        stats = gyt_ft_TFRclusterperm({permute(datT(:,stattime),[1,3,2,4]),permute(datC(:,stattime),[1,3,2,4])},0.05,'yes',5000);
%         statline = nan(1,numel(stats.mask));
%         statline(squeeze(stats.mask)==1) = 1;
        [statline,msg] = pup_getlinestats(epTFRt(stattime),datT(:,stattime),stats);
        fprintf(fid,'Stats on %s ITPC:\n',FreqBandNames{iFB});
        fprintf(fid,msg);

        m1 = squeeze(nanmean(nanmean(nanmean(allTPhis(iSta,:,cF,:,:),2),3),5))';
        sem1 = squeeze(nanstd(nanmean(nanmean(allTPhis(iSta,:,cF,:,:),2),3),[],5)./sqrt(sum(~isnan(allTPhis(iSta,1,1,1,:)),5)-1))';
        m2 = squeeze(nanmean(nanmean(nanmean(allCPhis(iSta,:,cF,:,:),2),3),5))';
        sem2 = squeeze(nanstd(nanmean(nanmean(allCPhis(iSta,:,cF,:,:),2),3),[],5)./sqrt(sum(~isnan(allCPhis(iSta,1,1,1,:)),5)-1))';

        subplot(1,numel(FreqBand),iFB)
        hold on
        fill([epTFRt,fliplr(epTFRt)],[m1+sem1,fliplr(m1-sem1)],colorslplot(1,:),'facealpha',0.2);
        h(1) = plot(epTFRt,m1,'color',colorslplot(1,:),'linewidth',2);
        fill([epTFRt,fliplr(epTFRt)],[m2+sem2,fliplr(m2-sem2)],colorslplot(2,:),'facealpha',0.2);
        h(2) = plot(epTFRt,m2,'color',colorslplot(2,:),'linewidth',2);
    %     plot(epTFRt(stattime),stat.tstat,'k-')
        plot(epTFRt(stattime),statline*0.1,'k-','linewidth',4);
        xlim([-1,3])
    %     ylim([-0.2,0.2])
        plot(xlim,[0,0],'k--')
        plot([0,0],ylim,'k--')
        title([stageNames{iSta},' - ',FreqBandNames{iFB}]);
    end
    figname = [Phipath,filesep,'Avg_FB_',stageNames{iSta}];
    savefig(fig,figname);
    print(fig,figname,'-dpng','-r300');
    close(fig);
    
    fclose(fid);
end


        



