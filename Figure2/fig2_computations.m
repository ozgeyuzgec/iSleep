
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

addpath('breathmetrics');
addpath('breathmetrics/breathmetrics_functions');

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
% Window boundaries for long-scale event-related potentials
winERPISO = [-40,100];
% Window boundaries for long-scale event-related potentials
ERPISOb = [-40,0];
% Window boundaries for short-scale event-related potentials
winERPse = [-5,10];
% Window boundaries for short-scale event-related potentials
ERPbse = [-5,0];
% Time-step for downsamping
winsizeSE = 0.008;
% Time-step in EEG timepoints
winsizeSET = round(winsizeSE*500);

%
eyerange = linspace(0,120,60);


% Color code for sleep stages
cccSta = [0.8320    0.3672         0;...
    0.2000    0.8000    0.8000;...
    0.4000    0.6000    0.8000;...
    0.1000    0.1000    0.5000;...
    0    0.4453    0.6953;...
    0    0.6172    0.4492];


% Example timepoints of session 17
exFiles = {'pup004_ses5','pup011_ses8','pup030_ses10','pup035_ses3','pup024_ses7'};
extps = {2100000:2300000,300000:500000,320000:480000,320000:480000,5950000:6150000};

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

if 1%~exist([Mainpath,filesep,'Results',filesep,'ISO.mat'])
    
    %%% Initialize variables
    ISOSpec = nan(numel(freqs),numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOsigmasp = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOeye = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOHR = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOHFHRV = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISORMSSD = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOLFHRV = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOLFHFr = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOM = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    ISOB = nan(numel(ISOfreqs),numel(subfolders),numel(sleepStages));
    RSpecE = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecE_withAr = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecE_woAr = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    
    
    RSpecH = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecRMSSD = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecHRVLF = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecHRVHF = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecHRVLFHFratio = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecB = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RSpecM = nan(numel(freqs),numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RsigmaspE = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RsigmaspH = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExHR = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExHFHR = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExLFHR = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExHRratio = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExM = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    RExB = nan(numel(timepointsCorrAuto),numel(subfolders),numel(sleepStages));
    ERbetaE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERbetaB = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERsigmaE = nan(diff(winERPISO)*500/50+1,numel(subfolders),numel(sleepStages));
    ERsigmaS = nan(diff(winERPISO)*500/50+1,numel(subfolders),numel(sleepStages));
    ERsigmaHFHRV = nan(diff(winERPISO)*500/50+1,numel(subfolders),numel(sleepStages));
    ERsigmaSpin = nan(diff(winERPISO)*500/50+1,numel(subfolders),numel(sleepStages));
    ERsigmaSW = nan(diff(winERPISO)*500/50+1,numel(subfolders),numel(sleepStages));
    ERSWE = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWEEG = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWHFHRV = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWIE = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWIEEG = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWIIE = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    ERSWIIEEG = nan(diff(winERPse)*500/winsizeSET+1,numel(subfolders),numel(sleepStages));
    EREPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERHRPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERHFHRVPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERLFHRVPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERLHrHRVPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    EREMGPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERBPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERArPE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    EREPSpec = nan(numel(freqs),diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    EREPSpin = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    EREPprob = nan(numel(eyerange),numel(subfolders),numel(sleepStages));
    ERnPE = nan(numel(subfolders),numel(sleepStages));
    ERENE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERArNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERHRNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERHFHRVNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERLFHRVNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERLHrHRVNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    EREMGNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERBNE = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERENSpec = nan(numel(freqs),diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERENSpin = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ERENprob = nan(numel(eyerange),numel(subfolders),numel(sleepStages));
    ERnNE = nan(numel(subfolders),numel(sleepStages));
    Nbouts = nan(numel(subfolders),numel(sleepStages));
    NboutsAuto = nan(numel(subfolders),numel(sleepStages));
    probEye = nan(numel(subfolders),numel(eyerange),numel(sleepStages));
    probSpin = nan(numel(subfolders),numel(eyerange),numel(sleepStages));
    probSW = nan(numel(subfolders),numel(eyerange),numel(sleepStages));
    probSWI = nan(numel(subfolders),numel(eyerange),numel(sleepStages));
    probSWII = nan(numel(subfolders),numel(eyerange),numel(sleepStages));
    
    ArER_Eye = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ArER_EEG = nan(diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ArER_TFR = nan(numel(freqs),diff(winERP)*500/50+1,numel(subfolders),numel(sleepStages));
    ArER_prob = nan(numel(eyerange),numel(subfolders),numel(sleepStages));
          
    RSpecEyeXpre = nan(winsizeCorrPupxEOG*500*2+1,numel(subfolders));
    RSpecEyeYpre = nan(winsizeCorrPupxEOG*500*2+1,numel(subfolders));
    RSpecEyeXpost = nan(winsizeCorrPupxEOG*500*2+1,numel(subfolders));
    RSpecEyeYpost = nan(winsizeCorrPupxEOG*500*2+1,numel(subfolders));
    

    % Loop on each session
    for iFile = 1:numel(subfolders)

        % List all files in subfolder
        filename = subfolders(iFile).name;
        
        fprintf('Working on %s\n',filename);
        
        % Index of the sessions in the xls file
        indSes = find(ismember(SessionInfos(:,1),subfolders(iFile).name));
        
        % Create a subfolder for participant data
        subrespath = [respath,filesep,filename];
        if ~exist(subrespath,'dir')
            mkdir(subrespath);
        end

        % Find .mat files
        files = dir([datapath,filesep,filename,filesep,'*.mat']);

        % Find mat file containing EEG and other physiological signals
        if exist([datapath,filesep,filename,filesep,'clean_signals_with_Ar.mat'],'file')
            load([datapath,filesep,filename,filesep,'clean_signals_with_Ar.mat']);
            clean_signals = clean_signals_with_Ar;
        else
            load([datapath,filesep,filename,filesep,'clean_signals.mat']);
        end
        % Find mat file containing sleep scoring
        load([datapath,filesep,filename,filesep,'clean_states.mat']);
        
        contAr = zeros(1,size(clean_signals,2));
        if exist([datapath,filesep,filename,filesep,'arousal_dur.mat'],'file')
            % Find mat file containing sleep scoring
            load([datapath,filesep,filename,filesep,'arousal_dur.mat']);
            load([datapath,filesep,filename,filesep,'arousal_start.mat']);
            for iAr=1:numel(arousal_dur)
                contAr(round(arousal_start(iAr)*500)+[1:round(arousal_dur(iAr)*500)]) = 1;
            end
        end
        
        % Find mat file containing pupil size data
        
        if exist([datapath,filesep,filename,filesep,SessionInfos{indSes,7},'_with_Ar.mat'],'file')
            eyefilename = [SessionInfos{indSes,7},'_with_Ar.mat'];
            load([datapath,filesep,filename,filesep,eyefilename]);
            eval(['clean_eye = ',eyefilename(1:10),'_with_Ar;']);
        else
            eyefilename = [SessionInfos{indSes,7},'.mat'];
            load([datapath,filesep,filename,filesep,eyefilename]);
            eval(['clean_eye = ',eyefilename(1:10),';']);
        end
        
        % Read channels label
        chanlabels = split(SessionInfos{indSes,5},' ');
        chanlabels = chanlabels(~ismember(chanlabels,{''}));
        chanindexes = find(~isnan(clean_signals(:,1)));
        
        if ~isempty(chanindexes)
            
            % Read bad channels
            badCh = split(SessionInfos{indSes,6},' ');
            indexesbad = ismember(chanlabels,badCh);
            chanindexes = chanindexes(~indexesbad);
            chanlabels = chanlabels(~indexesbad);
        end
            
            
        
        
        if any(ismember(chanlabels,{'pz','p3','p4'})) && ~isempty(chanindexes)

            
            % Create a continuous variable out of sleep scoring to match EEG sampling rate
            contscore = gyt_repunit(clean_states(1,:),30*500);
            if numel(contscore)<size(clean_signals,2)
                contscore = [contscore,zeros(1,size(clean_signals,2)-numel(contscore))];
            elseif numel(contscore)>size(clean_signals,2)
                contscore = contscore(1:size(clean_signals,2));
            end
            
            contArtefact = isnan(clean_signals(chanindexes(1),:));

            % Extract eye position (x-axis) and interpolate missing values
            eyex = interp1(clean_eye(4,:),clean_eye(1,:),(1/500):(1/500):size(clean_signals,2)/500,'linear');
            % Extract velocity (instantaneous derivative along the x-axis)
            deyex = diff(eyex);
            % Replace missing values by average velocity (necessary for the
            % computation of cross-correlation)
            deyex(isnan(deyex)) = nanmean(deyex);
            % Extract eye position (y-axis) and interpolate missing values
            eyey = interp1(clean_eye(4,:),clean_eye(2,:),(1/500):(1/500):size(clean_signals,2)/500,'linear');
            % Extract velocity (instantaneous derivative along the y-axis)
            deyey = diff(eyey);
            % Replace missing values by average velocity (necessary for the
            % computation of cross-correlation)
            deyey(isnan(deyey)) = nanmean(deyey);
            eyex2 = eyex;
            eyex2(isnan(eyex2)) = nanmean(eyex2);

            % Get the average velocity in all direction
            mvt = sqrt(deyex.^2+deyey.^2);
            % Crop velocity data when they extend beyond EEG recordings
            if numel(deyey)>size(clean_signals,2)
                deyex = deyex(1:size(clean_signals,2));
                deyey = deyey(1:size(clean_signals,2));
            end

            % Get EOG indexes from the log file
            indEOG = chanindexes(find(ismember(chanlabels,{'eog','eog1','eog2'})));
            EOGs = clean_signals(indEOG,:);
            for iEOG = 1:numel(indEOG)
                EOGs(iEOG,isnan(EOGs(iEOG,:))) = nanmean(EOGs(iEOG,:));
            end

            if numel(indEOG)>0
                [r,lags] = xcorr(nanzscore(eyex2),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                [r2,lags2] = xcorr(nanzscore(deyex),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                fig = figure;
                plot(lags2,nanzscore(r2))
                hold on
                plot(lags,nanzscore(r))
                
                if ~exist([figpath,filesep,'Examples',filesep,'CrossCorrelation'],'dir')
                    mkdir([figpath,filesep,'Examples'],'CrossCorrelation');
                end
                
                print(fig,[figpath,filesep,'Examples',filesep,'CrossCorrelation',filesep,filename],'-dpng','-r300');
                close(fig);
            end
                
            
            
            % Compute cross-correlation between velocity and EOGs
            if numel(indEOG)==2
                [r,lags] = xcorr(nanzscore(deyey),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                RSpecEyeYpre(:,iFile) = zscore(r);

                [r,lags] = xcorr(nanzscore(deyex),nanzscore(EOGs(2,:)),winsizeCorrPupxEOG*500);
                RSpecEyeXpre(:,iFile) = zscore(r);
            elseif numel(indEOG)==1
                [r,lags] = xcorr(nanzscore(deyey),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                RSpecEyeYpre(:,iFile) = zscore(r);
            else numel(indEOG)==0
                % If there is no EOG, suppose the lag between EEG and pupil
                % signal is inexistant
                r = 0 ;
                lags = 0;
            end
            
            % Find which EOG and velocity axis is best suited for the
            % computation of the lag between EEG and pupil signal. To do
            % so, we look for the maximum absolute cross-correlation value
            % between the cross-correlation x-velocity x EOG1 and
            % y-velocity x EOG2
            if numel(indEOG)~=0
                if ~all(isnan(RSpecEyeXpre(:,iFile)))
                    abscX = nanmax(abs(RSpecEyeXpre(:,iFile)));
                    abscY = nanmax(abs(RSpecEyeYpre(:,iFile)));
                    if abscY>abscX
                        r = RSpecEyeYpre(:,iFile);
                    else
                        r = RSpecEyeXpre(:,iFile);
                    end
                else
                    r = RSpecEyeYpre(:,iFile);
                end

                % Find the max and the min cross-correlation values
                [~,Imin] = nanmin(r);
                [~,Imax] = nanmax(r);
                % Check that the z-scored max and min cross-correlation
                % values are sufficiently different from the other values
                % of the cross-correlation (is there really a
                % cross-correlation, or is it noise)
                if (abs(r(Imin))+abs(r(Imax)))/2>2
                    % Find which comes first max or min cross-correlation
                    if Imin<Imax
                        tp = Imin:Imax;
                        Ist =  Imin;
                    else
                        tp = Imax:Imin;
                        Ist =  Imax;
                    end
                    % Find the 0-crossing point between max and min
                    % cross-correlation. This is the potential lag
                    % difference between EEg and pupil signal
                    Icross = find(diff(r(tp)<0)~=0);
                    clag = lags(Icross(1)+Ist)/500;
                else
                    clag = 0;
                end
            else
                clag = 0;
            end


            % Compute eye size
            eyefilename = [subrespath,filesep,'eyesizesig.mat'];
            if ~exist(eyefilename,'file')
                % Interpolate pupil size data to create a variable at the same sampling
                % rate than EEG
                tmpeyesize0 = interp1(clean_eye(4,:),clean_eye(3,:),clag+(1/500):(1/500):size(clean_signals,2)/500,'linear');
    %             tmpeyesize0 = interp1(eyeData0_beforeArousal(4,:),eyeData0_beforeArousal(3,:),30+clag+(1/500):(1/500):size(clean_signals,2)/500,'linear');
                tmpeyesize0(isnan(clean_signals(5,:))) = nan;
    %             tmpeyesize1 = interp1(clean_eye1(4,:),clean_eye1(3,:),clag+(1/500):(1/500):size(clean_signals,2)/500,'linear');
    %             tmpeyesize1(isnan(clean_signals(5,:))) = nan;
    %             eyesize = nanmean([tmpeyesize0;tmpeyesize1],1);
                eyesize = tmpeyesize0;
                if numel(eyesize)>size(clean_signals,2)
                    eyesize = eyesize(1:size(clean_signals,2));
                elseif size(clean_signals,2)>numel(eyesize)
                    eyesize = [eyesize,nan(1,size(clean_signals,2)-numel(eyesize))];
                end
                save(eyefilename,'eyesize');
            else
                load(eyefilename);
            end

            eyex = interp1(clean_eye(4,:),clean_eye(1,:),clag+(1/500):(1/500):size(clean_signals,2)/500,'linear');
            deyex = diff(eyex);
            deyex(isnan(deyex)) = nanmean(deyex);
            eyey = interp1(clean_eye(4,:),clean_eye(2,:),clag+(1/500):(1/500):size(clean_signals,2)/500,'linear');
            deyey = diff(eyey);
            deyey(isnan(deyey)) = nanmean(deyey);

            if numel(deyey)>size(clean_signals,2)
                deyex = deyex(1:size(clean_signals,2));
                deyey = deyey(1:size(clean_signals,2));
            end

            if numel(indEOG)==2
                [r,lags] = xcorr(nanzscore(deyey),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                RSpecEyeYpost(:,iFile) = zscore(r);

                [r,lags] = xcorr(nanzscore(deyex),nanzscore(EOGs(2,:)),winsizeCorrPupxEOG*500);
                RSpecEyeXpost(:,iFile) = zscore(r);
            elseif numel(indEOG)==1
                [r,lags] = xcorr(nanzscore(deyey),nanzscore(EOGs(1,:)),winsizeCorrPupxEOG*500);
                RSpecEyeYpost(:,iFile) = zscore(r);
            end


            % Compute muscle tone from EMG
            emgfilename = [subrespath,filesep,'emgsig.mat'];
            if ~exist(emgfilename,'file')
                % Find index of EMG channel
                indexEMG = chanindexes(find(ismember(chanlabels,'emg')));
                
                if ~isempty(indexEMG)
                    % Get EMG signal
                    x = clean_signals(indexEMG,:);
                    x(isnan(x)) = nanmean(x);
                    % Filter EMG between 30 and 100 Hz
                    [b,a] = butter(2,[30,100]/(500/2),'bandpass');
                    fx = filtfilt(b,a,x);
                    % Take the enveloppe of such signal by extracting the
                    % modulus of the hilbert transform
                    emgamp = abs(hilbert(fx));
                    emgamp(isnan(clean_signals(12,:))) = nan;
                    % Convolve the amplitude signal with a moving average of
                    % 4-s
                    emgamp = conv(emgamp,ones(1,500*4)/(4*500),'same');
                    tp = find(~isnan(emgamp));
                    interpX = interp1(tp,emgamp(tp)',1:numel(emgamp),'linear','extrap');
                    % Highpass filter the amplitude signal at 0.01Hz to remove
                    % slow trends
                    [b,a] = butter(1,0.01/(500/2),'high');
                    fEMG = filtfilt(b,a,interpX);
                    fEMG(isnan(emgamp)) = nan;
                else
                    fEMG = nan(1,size(clean_signals,2));
                end

                save(emgfilename,'fEMG');
            else
                load(emgfilename);
            end

            % compute breathing rate
            breathfilename = [subrespath,filesep,'breathsig.mat'];
            if ~exist(breathfilename,'file')
                indexBRE = chanindexes(find(ismember(chanlabels,'bre')));
                if ~isempty(indexBRE)
                    x = clean_signals(indexBRE,:);
                    x(isnan(x)) = nanmean(x);
                    % Use breathmetrics to extract breathing starts
                    bmobj = breathmetrics(x,500,'humanAirflow');
                    bmobj.estimateAllFeatures(0,'sliding',1,0);
                    % Extract instantaneous breathing rate 
                    bbinter = 1./(diff(bmobj.inhaleOnsets)/500)*60;
                    % Interpolate nans before filtering
                    interpBB = interp1(bmobj.inhaleOnsets(1:end-1),bbinter,1:numel(contscore),'linear');
                    % Filter with a moving average of 4-s
                    fBB = conv(interpBB,ones(1,500*4)/(4*500),'same');
                    % Add the nans
                    fBB(isnan(clean_signals(9,:))) = nan;
                else
                    fBB = nan(1,size(clean_signals,2));
                end
                save(breathfilename,'fBB');
            else
                load(breathfilename);
            end


            heartfilename = [subrespath,filesep,'heartsig.mat'];
            if ~exist(heartfilename,'file')
                indexHeart = chanindexes(find(ismember(chanlabels,'ecg')));
                if ~isempty(indexHeart)
                    % Get ECG signal and remove line noise with notch filter
                    x = clean_signals(indexHeart,:);
                    x(isnan(x)) = nanmean(x);
                    % Detect R-peaks with custom function
                    rpeaks = gyt_detectRpeaks(x,500);
                    % Compute R-R intervals
                    rrinter = 1./(diff(rpeaks)/500)*60;
                    % Interpolate R-R intervals to get a continuous variable at the same
                    % sampling rate than EEG
                    interpRR = interp1(rpeaks(1:end-1)+diff(rpeaks)/2,rrinter,1:numel(contscore),'linear');
                    interpRR(isnan(clean_signals(10,:))) = nan;
                    % Convolve the signal with a square window of 4 seconds (Same as Lecci
                    % et a., 2017)
                    fRR = conv(interpRR,ones(1,500*10)/(10*500),'same');
                    % Get High-frequency component of heart-rate variability
                    % Compute R-R intervals
                    rrinter = diff(rpeaks)/500*1000;
                    rrinter(rrinter>2000) = nan;
                    rrdiff = diff(rrinter);
                    % Interpolate R-R intervals to get a continuous variable at the same
                    % sampling rate than EEG
                    interpRR = interp1(rpeaks(2:end-1),rrdiff,1:numel(contscore),'nearest');
                    interpRR(isnan(clean_signals(10,:))) = nan;
        %             interpRR(isnan(interpRR)) = nanmean(interpRR);
                    RMSSD = sqrt(conv(interpRR.^2,ones(1,10*500)/(10*500),'same'));

                    peakstimes = rpeaks(1:end-1)+diff(rpeaks)/2;
                    interpRR = interp1(peakstimes(~isnan(rrinter)),rrinter(~isnan(rrinter)),1:numel(contscore),'linear','extrap');
                    [b,a] = butter(2,[0.15,0.4]/(500/2),'bandpass');
                    HFHRV = abs(hilbert(filtfilt(b,a,interpRR)));
                    HFHRV(isnan(clean_signals(10,:))) = nan;
                    % Get Low-frequency component of heart-rate variability
                    [b,a] = butter(2,[0.04,0.15]/(500/2),'bandpass');
                    LFHRV = abs(hilbert(filtfilt(b,a,interpRR)));
                    LFHRV(isnan(clean_signals(10,:))) = nan;
                    LFHFratio = LFHRV./HFHRV;
                else
                    fRR = nan(1,size(clean_signals,2));
                    HFHRV = nan(1,size(clean_signals,2));
                    RMSSD = nan(1,size(clean_signals,2));
                    LFHRV = nan(1,size(clean_signals,2));
                    LFHFratio = nan(1,size(clean_signals,2));
                end
                save(heartfilename,'fRR','HFHRV','RMSSD','LFHRV','LFHFratio');
            else
                load(heartfilename);
            end

            specfilename = [subrespath,filesep,'specsig.mat'];
            if ~exist(specfilename,'file')
                indexP = [];
                for iCh = 1:numel(chanlabels)
                    if strcmpi(chanlabels{iCh},'p3')|strcmpi(chanlabels{iCh},'p4')|strcmpi(chanlabels{iCh},'pz')
                        indexP = [indexP,iCh];
                    end
                end
                
                % Compute time-frequency in the full (i.e., 1-30Hz) frequency range
                spec = permute(nanmean(abs(gyt_CWT(clean_signals(chanindexes(indexP),:),500,freqs,ones(1,numel(freqs)),2)).^2,1),[3,1,2]);
                save(specfilename,'spec','-v7.3')
            else
                load(specfilename);
            end
            

            sigpwr = squeeze(nanmean(sqrt(spec(freqspin,:,:)),1));
            csigpwr = sigpwr;
            csigpwr(isnan(sigpwr)) = 0;
            [b,a] = butter(1,0.2/(500/2),'high');
            fsigpwr = filtfilt(b,a,csigpwr);
            fsigpwr(isnan(sigpwr)) = nan;

            space = linspace(-5,5,1000);
            prob = histc(fsigpwr,space);
            [mP,I] = max(prob);
            M = space(I);
            I = find(diff(cumsum([0,prob'])>mP*0.025)>0);
            S = (M-space(I))/2;

            thrD = M+2*S;
            thrB = M+0.25*S;

            detSpin = find(diff([0,squeeze(fsigpwr)'>thrD])>0);
            dsigpwr = diff([0,fsigpwr']);
            stSpin = find(diff([0,squeeze(fsigpwr)'>thrB])>0);
            endSpin = find(diff([0,squeeze(fsigpwr)'>thrB])<0);

            if numel(stSpin)>numel(endSpin)
                stSpin = stSpin(1:end-1);
            end
            diffmat = repmat(stSpin',[1,numel(endSpin)])-repmat(endSpin,[numel(stSpin),1]);
            gstSpin = ~any((diffmat>0)&(diffmat<500*0.5),2);
            gendSpin = ~any((diffmat>0)&(diffmat<500*0.5),1);
            stSpin = stSpin(gstSpin);
            endSpin = endSpin(gendSpin);




            diffmat = repmat(detSpin,[numel(stSpin),1])-repmat(stSpin',[1,numel(detSpin)]);
            diffmat(diffmat<0) = Inf;
            [~,Imin] = min(diffmat,[],1);
            stSpin = stSpin(Imin);

            diffmat = repmat(detSpin,[numel(endSpin),1])-repmat(endSpin',[1,numel(detSpin)]);
            diffmat(diffmat>=0) = -Inf;
            [~,Imax] = max(diffmat,[],1);
            endSpin = endSpin(Imax);


            tspin = (endSpin-stSpin)/500;
            gSpin = (tspin>0.5)&(tspin<3);
            stSpin = stSpin(gSpin);
            endSpin = endSpin(gSpin);

            contspin = zeros(1,numel(eyesize));
            contspin(stSpin) = 1;
            spinps = conv(contspin,gyt_gauss(-20*500:20*500,0,3*500),'same')*500;

            indexF = [];
            for iCh = 1:numel(chanlabels)
                if strcmpi(chanlabels{iCh}(1:2),'fz')
                    indexF = [indexF,iCh];
                elseif strcmpi(chanlabels{iCh}(1:2),'f3')
                    indexF = [indexF,iCh];
                end
            end

            xxx = clean_signals(chanindexes(indexF),:);
            xxx(isnan(xxx)) = nanmean(xxx);
            SWs = gyt_SWdetection(xxx,500);

            SWs = SWs(:,SWs(3,:)<-50);
            SWs = [SWs;1+(SWs(3,:)>-75)];

            gSW = (SWs(1,:)+winERPse(1)*500>0)&(SWs(1,:)+winERPse(2)*500<numel(eyesize))&(SWs(1,:)+winERP(2)*500<size(clean_signals,2));
            SWs = SWs(:,gSW);

            contSW = zeros(1,numel(eyesize));
            contSW(SWs(1,:)) = 1;
            SWps = conv(contSW,gyt_gauss(-10*500:10*500,0,1*500),'same')*500;


            contSWI = zeros(1,numel(eyesize));
            contSWI(SWs(1,SWs(end,:)==1)) = 1;

            for iSta = 1:numel(sleepStages)
                tmpspin = stSpin(ismember(contscore(stSpin),sleepStages{iSta}));
                tmpspin = tmpspin(~isnan(eyesize(tmpspin)));
                if numel(tmpspin)>0
                    probSpin(iFile,:,iSta) = histc(eyesize(tmpspin),eyerange)./numel(tmpspin);
                end

                tmpSW = SWs(1,ismember(contscore(SWs(1,:)),sleepStages{iSta}));
                tmpSW = tmpSW(~isnan(eyesize(tmpSW)));
                if numel(tmpSW)>0
                    probSW(iFile,:,iSta) = histc(eyesize(tmpSW),eyerange)./numel(tmpSW);
                end
                tmpSW = SWs(1,ismember(contscore(SWs(1,:)),sleepStages{iSta})&SWs(end,:)==1);
                tmpSW = tmpSW(~isnan(eyesize(tmpSW)));
                if numel(tmpSW)>0
                    probSWI(iFile,:,iSta) = histc(eyesize(tmpSW),eyerange)./numel(tmpSW);
                end
                tmpSW = SWs(1,ismember(contscore(SWs(1,:)),sleepStages{iSta})&SWs(end,:)==2);
                tmpSW = tmpSW(~isnan(eyesize(tmpSW)));
                if numel(tmpSW)>0
                    probSWII(iFile,:,iSta) = histc(eyesize(tmpSW),eyerange)./numel(tmpSW);
                end
                tmpE = find(ismember(contscore,sleepStages{iSta}));
                tmpE = tmpE(~isnan(eyesize(tmpE)));
                if numel(tmpE)>0
                    probEye(iFile,:,iSta) = histc(eyesize(tmpE),eyerange)./numel(tmpE);
                end
            end





            thrSpin = nanmean(eyesize(stSpin))+5*nanstd(eyesize(stSpin));



            tp = winERP(1)*500:50:winERP(2)*500;
            bp = find((tp/500>ERPb(1))&(tp/500<ERPb(2)));


            ceyesize = interp1(find(~isnan(eyesize)),eyesize(~isnan(eyesize)),1:numel(eyesize),'linear');
            stval = ceyesize(~isnan(ceyesize));
            ceyesize(isnan(ceyesize)) = stval(1);
            ceyesize(isnan(ceyesize)) = nanmean(ceyesize);
            [b,a] = butter(2,[0.01,0.2]/(500/2),'bandpass');
            feyesize = filtfilt(b,a,ceyesize);
            deye = diff([0,feyesize]);
            deye(isnan(eyesize)) = nan;
            zdeye = nanzscore(deye);

            stP = find(diff([0,abs(zdeye)>0.25])>0);
            endP = find(diff([0,abs(zdeye)>0.25])<0);
            stP = stP(1:numel(endP));
            incs = (endP-stP)/500;
            peakP = nan(1,numel(stP));
            for iP = 1:numel(stP)
                [~,I] = nanmax(abs(zdeye(stP(iP):endP(iP))));
                peakP(iP) = zdeye(stP(iP)-1+I);
            end
            dil = (peakP>1)&(incs>0.5);
            cons = (peakP<-1)&(incs>0.5);

            locs = stP;
%             locs(peakP<-1) = endP(peakP<-1);

            gp = (locs+winERP(1)*500>0)&(locs+winERP(2)*500<numel(eyesize))&(locs+winERP(2)*500<size(spec,3));
            ttt = locs(gp);
            dil = dil(gp);
            cons = cons(gp);
    %         pksigntmp = pksign(gp);
            ep = repmat(tp',[1,numel(ttt)])+repmat(ttt,[numel(tp),1]);
            epE = reshape(eyesize(ep(:)),[numel(tp),numel(ttt)]);
            bepE = epE-repmat(nanmean(epE(bp,:)),[size(epE,1),1]);
            epSpec = squeeze(reshape(10*log10(spec(:,:,ep(:))),[size(spec,1),1,numel(tp),numel(ttt)]));
            bepSpec = epSpec-repmat(nanmean(epSpec(:,bp,:),2),[1,size(epSpec,2),1]);
            epHR = reshape(fRR(ep(:)),[numel(tp),numel(ttt)]);
            bepHR = epHR-repmat(nanmean(epHR(bp,:)),[size(epHR,1),1]);
            epHFHRV = reshape(HFHRV(ep(:)),[numel(tp),numel(ttt)]);
            bepHFHRV = epHFHRV-repmat(nanmean(epHFHRV(bp,:)),[size(epHFHRV,1),1]);
            epLFHRV = reshape(LFHRV(ep(:)),[numel(tp),numel(ttt)]);
            bepLFHRV = epLFHRV-repmat(nanmean(epLFHRV(bp,:)),[size(epLFHRV,1),1]);
            epLHrHRV = reshape(LFHFratio(ep(:)),[numel(tp),numel(ttt)]);
            bepLHrHRV = epLHrHRV-repmat(nanmean(epLHrHRV(bp,:)),[size(epLHrHRV,1),1]);
            epEMG = reshape(fEMG(ep(:)),[numel(tp),numel(ttt)]);
            bepEMG = epEMG-repmat(nanmean(epEMG(bp,:)),[size(epEMG,1),1]);
            epBreath = reshape(fBB(ep(:)),[numel(tp),numel(ttt)]);
            bepBreath = epBreath-repmat(nanmean(epBreath(bp,:)),[size(epBreath,1),1]);
            epSpin = reshape(spinps(ep(:)),[numel(tp),numel(ttt)]);
            bepSpin = epSpin-repmat(nanmean(epSpin(bp,:)),[size(epSpin,1),1]);
            epAr = reshape(contAr(ep(:)),[numel(tp),numel(ttt)]);
            tmpeSize = eyesize(ttt);

            gEp = squeeze(any(~isnan(bepSpec(1,:,:)),2))'&squeeze(any(~isnan(bepE),1));


            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                if any(ismember(contscore(ttt),StOI)&gEp) %&any(ismember(contscore(locsInc),StOI))

                    posP = find(ismember(contscore(ttt),StOI)&dil&gEp);
                    EREPE(:,iFile,iSta) = nanmean(bepE(:,posP),2);
                    ERHRPE(:,iFile,iSta) = nanmean(bepHR(:,posP),2);
                    ERHFHRVPE(:,iFile,iSta) = nanmean(bepHFHRV(:,posP),2);
                    ERLFHRVPE(:,iFile,iSta) = nanmean(bepLFHRV(:,posP),2);
                    ERLHrHRVPE(:,iFile,iSta) = nanmean(bepLHrHRV(:,posP),2);
                    EREMGPE(:,iFile,iSta) = nanmean(bepEMG(:,posP),2);
                    ERBPE(:,iFile,iSta) = nanmean(bepBreath(:,posP),2);
                    EREPSpec(:,:,iFile,iSta) = nanmean(bepSpec(:,:,posP),3);
                    EREPSpin(:,iFile,iSta) = nanmean(bepSpin(:,posP),2);
                    tmptmpeSize = tmpeSize(posP(~isnan(tmpeSize(posP))));
                    if ~isempty(tmptmpeSize)
                        EREPprob(:,iFile,iSta) = histc(tmptmpeSize,eyerange)./numel(tmptmpeSize);
                    end
                    if sum(contAr)>0
                        ERArPE(:,iFile,iSta) = nanmean(epAr(:,posP),2);
                    end
                        
                    
                    negP = find(ismember(contscore(ttt),StOI)&cons&gEp);
                    ERENE(:,iFile,iSta) = nanmean(bepE(:,negP),2);
                    ERHRNE(:,iFile,iSta) = nanmean(bepHR(:,negP),2);
                    ERHFHRVNE(:,iFile,iSta) = nanmean(bepHFHRV(:,negP),2);
                    ERLFHRVNE(:,iFile,iSta) = nanmean(bepLFHRV(:,negP),2);
                    ERLHrHRVNE(:,iFile,iSta) = nanmean(bepLHrHRV(:,negP),2);
                    EREMGNE(:,iFile,iSta) = nanmean(bepEMG(:,negP),2);
                    ERBNE(:,iFile,iSta) = nanmean(bepBreath(:,negP),2);
                    ERENSpec(:,:,iFile,iSta) = nanmean(bepSpec(:,:,negP),3);
                    ERENSpin(:,iFile,iSta) = nanmean(bepSpin(:,negP),2);
                    tmptmpeSize = tmpeSize(negP(~isnan(tmpeSize(negP))));
                    if ~isempty(tmptmpeSize)
                        ERENprob(:,iFile,iSta) = histc(tmptmpeSize,eyerange)./numel(tmptmpeSize);
                    end
                    if sum(contAr)>0
                        ERArNE(:,iFile,iSta) = nanmean(epAr(:,negP),2);
                    end
                end
            end
            contdil = zeros(1,numel(eyesize));
            contdil(ttt(dil)) = 1;
            contconst = zeros(1,numel(eyesize));
            contconst(ttt(cons)) = 1;

            % Plot example traces of infra-slow oscillations in different
            % stages
            ceyesize = interp1(find(~isnan(eyesize)),eyesize(~isnan(eyesize)),1:numel(eyesize),'linear');
            [b,a] = butter(2,1/(500/2),'low');
            feyezise = filtfilt(b,a,ceyesize);
            
            if any(ismember(exFiles,filename))
                
                extp = extps{find(ismember(exFiles,filename))};
                
                temptfr = nan(size(spec,1),numel(extp));
                for iF = 1:numel(freqs)
                    temptfr(iF,:) = conv(10*log10(squeeze(spec(iF,:,extp))),ones(1,500*4)/(500*4),'same');
                end

                shortScore = contscore(extp);
                shortAr = contAr(extp);
                tmpStages = [0,1,2,3,5];
                corresCol = [1,2,3,4,6];

                fig = figure('position',[0,0,400,2000]);

                subplot(10,1,1)
                hold on
                plot((1:numel(extp))/500,feyezise(extp))
                scatter(find(contdil(extp)==1)/500,feyezise(extp(contdil(extp)==1)),'ko','filled','sizedata',7)
                scatter(find(contconst(extp)==1)/500,feyezise(extp(contconst(extp)==1)),'ro','filled','sizedata',7)
                xlim([1,numel(extp)/500])
                ylabel(sprintf('Pupil size\n(pixels)'))
                ylims = ylim;
                yposline = ylims(2)-diff(ylims)/20;
                for iSta=1:numel(tmpStages)
                    cLine = nan(1,numel(extp));
                    cLine(shortScore==tmpStages(iSta)) = 1;
                    ppp = plot((1:numel(extp))/500,cLine*yposline,'color',cccSta(corresCol(iSta),:),'linewidth',2);
                    uistack(ppp, 'bottom');
                end
                cLine = nan(1,numel(extp));
                cLine(shortAr==1) = 1;
                ppp = plot((1:numel(extp))/500,cLine*yposline*0.9,'color','r','linewidth',2);



                for iF = 1:numel(freqbands)
                    FOI = (freqs>=freqbands{iF}(1)) & (freqs<=freqbands{iF}(2));
                    subplot(10,1,iF+1)
                    hold on
                    plot((1:numel(extp))/500,squeeze(nanmean(spec(FOI,:,extp))),'color',[0.7,0.7,0.7]);
                    s = nanstd(nanmean(spec(FOI,:,extp)));
                    ylim([0,s*5])
                    ylabel(sprintf([freqbandNames{iF},'\npower\n(\muV^2)']))
                    yyaxis right
                    plot((1:numel(extp))/500,nanmean(temptfr(FOI,:)),'k-')
                    xlim([1,numel(extp)/500])
                    ylabel('dB')
                end

                subplot(10,1,numel(freqbands)+2)
                hold on
                plot((1:numel(extp))/500,HFHRV(extp))
                xlim([1,numel(extp)/500])
                ylabel('HFHRV')


                subplot(10,1,numel(freqbands)+3)
                hold on
                plot((1:numel(extp))/500,fBB(extp))
                xlim([1,numel(extp)/500])
                ylabel('Breathing')

                subplot(10,1,numel(freqbands)+4)
                hold on
                plot((1:numel(extp))/500,fRR(extp))
                xlim([1,numel(extp)/500])
                ylabel(sprintf('Heart\nRate(min-1)'))

                subplot(10,1,numel(freqbands)+5)
                hold on
                plot((1:numel(extp))/500,clean_signals(1,extp))
                scatter(find(contSW(extp)==1)/500,clean_signals(1,extp(contSW(extp)==1)),'ko','filled','sizedata',7)
                xlim([1,numel(extp)/500])
                ylabel('EEG (Fz)')

                savefig(fig,[figpath,filesep,'Examples',filesep,filename],'compact');
                print(fig,[figpath,filesep,'Examples',filesep,filename],'-dpng','-r300');
                close(fig);
            end

            

            indexP = [];
            for iCh = 1:numel(chanlabels)
                if strcmpi(chanlabels{iCh},'p3')|strcmpi(chanlabels{iCh},'p4')|strcmpi(chanlabels{iCh},'pz')
                    indexP = [indexP,iCh];
                end
            end

            tp = winERP(1)*500:50:winERP(2)*500;
            bp = find((tp/500>ERPb(1))&(tp/500<ERPb(2)));

            stAr = find(diff([0,contAr])>0);
            stAr = stAr((stAr<size(clean_signals,2)-winERP(2)*500)&(stAr<numel(eyesize)-winERP(2)*500));
            if ~isempty(stAr)
                ep = repmat(tp',[1,numel(stAr)])+repmat(stAr,[numel(tp),1]);
                epE = reshape(eyesize(ep(:)),[numel(tp),numel(stAr)]);
                bepE = epE-repmat(nanmean(epE(bp,:)),[size(epE,1),1]);
                epEEG = reshape(clean_signals(indexP(1),ep(:)),[numel(tp),numel(stAr)]);
                bepEEG = epEEG-repmat(nanmean(epEEG(bp,:)),[size(epEEG,1),1]);
                epSpec = squeeze(reshape(10*log10(spec(:,:,ep(:))),[size(spec,1),1,numel(tp),numel(stAr)]));
                bepSpec = epSpec-repmat(nanmean(epSpec(:,bp,:),2),[1,size(epSpec,2),1]);
                
                for iSta = 1:numel(sleepStages)
                    StOI = sleepStages{iSta};

                    if any(ismember(contscore(stAr),StOI))
                        
                        ArER_Eye(:,iFile,iSta) = nanmean(bepE,2);
                        ArER_EEG(:,iFile,iSta) = nanmean(bepEEG,2);
                        ArER_TFR(:,:,iFile,iSta) = nanmean(bepSpec,3);
                        
                        
                        
                        tmpSize = eyesize(stAr(~isnan(eyesize(stAr))));
                        if ~isempty(tmptmpeSize)
                            ArER_prob(:,iFile,iSta) = histc(tmpSize,eyerange)./numel(tmpSize);
                        end
                    end
                end
            end




            beta = squeeze(nanmean(10*log10(spec(freqbands{5},:,:))));
            cbeta = interp1(find(~isnan(beta)),beta(~isnan(beta)),1:numel(beta),'linear','extrap');
            [b,a] = butter(2,[0.01,1]/(500/2),'bandpass');
            fbeta = filtfilt(b,a,cbeta);
            zbeta = nanzscore(fbeta);
            theta = squeeze(nanmean(spec(freqbands{2},:,:)));
            ztheta = nanzscore(theta);
            sigma = squeeze(nanmean(spec(freqbands{4},:,:)));
            zsigma = nanzscore(sigma);

            ttt = find(diff([0,zbeta,0]>0)>0);
            tend = find(diff([0,zbeta,0]>0)<0);
            ttt = ttt((tend-ttt)>500*3);
            ttt = ttt((ttt+winERP(1)*500>0)&(ttt+winERP(2)*500<numel(eyesize))&(ttt+winERP(2)*500<numel(beta)));
            tp = winERP(1)*500:50:winERP(2)*500;
            ep = repmat(tp',[1,numel(ttt)])+repmat(ttt,[numel(tp),1]);
            epE = reshape(eyesize(ep(:)),[numel(tp),numel(ttt)]);
            bepE = epE-repmat(nanmean(epE(bp,:)),[size(epE,1),1]);
            epB = reshape(beta(ep(:)),[numel(tp),numel(ttt)]);
            bepB = epB-repmat(nanmean(epB(bp,:)),[size(epB,1),1]);
            epT = reshape(theta(ep(:)),[numel(tp),numel(ttt)]);
            bepT = epT-repmat(nanmean(epT(bp,:)),[size(epT,1),1]);

            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                ERbetaE(:,iFile,iSta) = nanmean(bepE(:,ismember(contscore(ttt),StOI)),2);
                ERbetaB(:,iFile,iSta) = nanmean(bepB(:,ismember(contscore(ttt),StOI)),2);
            end


            tp = winERPISO(1)*500:50:winERPISO(2)*500;
            bp = find((tp/500>ERPISOb(1))&(tp/500<ERPISOb(2)));

            zsigma = interp1(find(~isnan(zsigma)),zsigma(~isnan(zsigma)),1:numel(zsigma),'linear','extrap');
            [b,a] = butter(2,[0.01,0.03]/(500/2),'bandpass');
            fsigma = filtfilt(b,a,zsigma);
            phi = angle(hilbert(fsigma));
            tphi = find(diff(phi>0)<0);

            tphi = tphi((tphi+winERPISO(1)*500>0)&(tphi+winERPISO(2)*500<numel(eyesize))&(tphi+winERP(2)*500<numel(sigma)));
            ep = repmat(tp',[1,numel(tphi)])+repmat(tphi,[numel(tp),1]);
            epE = reshape(eyesize(ep(:)),[numel(tp),numel(tphi)]);
            bepE = epE-repmat(nanmean(epE(bp,:)),[size(epE,1),1]);
            epS = reshape(10*log10(sigma(ep(:))),[numel(tp),numel(tphi)]);
            bepS = epS-repmat(nanmean(epS(bp,:)),[size(epS,1),1]);
            epHFHRV = reshape(RMSSD(ep(:)),[numel(tp),numel(tphi)]);
            bepHFHRV = epHFHRV-repmat(nanmean(epHFHRV(bp,:)),[size(epHFHRV,1),1]);
            epSpin = reshape(spinps(ep(:)),[numel(tp),numel(tphi)]);
            bepSpin = epSpin-repmat(nanmean(epSpin(bp,:)),[size(epSpin,1),1]);
            epSW = reshape(SWps(ep(:)),[numel(tp),numel(tphi)]);
            bepSW = epSW-repmat(nanmean(epSW(bp,:)),[size(epSW,1),1]);

            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                ERsigmaE(:,iFile,iSta) = nanmean(bepE(:,ismember(contscore(tphi),StOI)),2);
                ERsigmaS(:,iFile,iSta) = nanmean(bepS(:,ismember(contscore(tphi),StOI)),2);
                ERsigmaHFHRV(:,iFile,iSta) = nanmean(bepHFHRV(:,ismember(contscore(tphi),StOI)),2);
                ERsigmaSpin(:,iFile,iSta) = nanmean(bepSpin(:,ismember(contscore(tphi),StOI)),2);
                ERsigmaSW(:,iFile,iSta) = nanmean(epSW(:,ismember(contscore(tphi),StOI)),2);
            end



            tp = winERPse(1)*500:winsizeSET:winERPse(2)*500;
            bp = find((tp/500>ERPbse(1))&(tp/500<ERPbse(2)));


            ceyesize = eyesize;
            ceyesize(isnan(ceyesize)) = nanmean(ceyesize);
            [b,a] = butter(1,[10,30]/(500/2),'bandpass');
            feyesize = filtfilt(b,a,ceyesize);
            feyesize = ceyesize;


            ttt = SWs(1,:);
            ep = repmat(tp',[1,numel(ttt)])+repmat(ttt,[numel(tp),1]);
            epE = reshape(feyesize(ep(:)),[numel(tp),numel(ttt)]);
            bepE = epE-repmat(nanmean(epE(bp,:)),[size(epE,1),1]);
            epS = reshape(clean_signals(1,ep(:)),[numel(tp),numel(ttt)]);
            bepS = epS-repmat(nanmean(epS(bp,:)),[size(epS,1),1]);
            epH = reshape(HFHRV(ep(:)),[numel(tp),numel(ttt)]);
            bepH = epH-repmat(nanmean(epH(bp,:)),[size(epH,1),1]);


            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                ERSWE(:,iFile,iSta) = nanmean(bepE(:,ismember(contscore(ttt),StOI)),2);
                ERSWEEG(:,iFile,iSta) = nanmean(bepS(:,ismember(contscore(ttt),StOI)),2);
                ERSWHFHRV(:,iFile,iSta) = nanmean(bepH(:,ismember(contscore(ttt),StOI)),2);

                ERSWIE(:,iFile,iSta) = nanmean(bepE(:,ismember(contscore(ttt),StOI)&(SWs(7,:)==1)),2);
                ERSWIEEG(:,iFile,iSta) = nanmean(bepS(:,ismember(contscore(ttt),StOI)&(SWs(7,:)==1)),2);

                ERSWIIE(:,iFile,iSta) = nanmean(bepE(:,ismember(contscore(ttt),StOI)&(SWs(7,:)==2)),2);
                ERSWIIEEG(:,iFile,iSta) = nanmean(bepS(:,ismember(contscore(ttt),StOI)&(SWs(7,:)==2)),2);
            end

            crosscorrfolder = [subrespath,filesep,'Crosscorr'];
            if ~exist(crosscorrfolder,'dir')
                mkdir(crosscorrfolder);
            end

            
            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                endP = find(mod(gyt_CountContinuous(+ismember(contscore,StOI)),winsizeCorrAuto*500)==winsizeCorrAuto*500-1);
                staP = endP-winsizeCorrAuto*500;
                gP = (staP>winsizeCorrAuto*500)&(endP<numel(contscore)-winsizeCorrAuto*500);
                staP = staP(gP);
                endP = endP(gP);
                Nbouts(iFile,iSta) = numel(staP);
                if numel(staP)>0
                    ep = repmat((1:winsizeCorrAuto*500)',[1,numel(staP)])+repmat(staP,[winsizeCorrAuto*500,1]);
                    ArP = any(reshape(contAr(ep(:)),[winsizeCorrAuto*500,numel(staP)])==1,1);
                else
                    ArP = [];
                end
                if numel(staP)>0
                    ep = repmat((1:winsizeCorrAuto*500)',[1,numel(staP)])+repmat(staP,[winsizeCorrAuto*500,1]);
                    ArteP = any(reshape(contArtefact(ep(:)),[winsizeCorrAuto*500,numel(staP)])==1,1);
                else
                    ArteP = [];
                end


                crosscorrname = [subrespath,filesep,'Crosscorr',filesep,sprintf('crosscorr_%s_SpecxEye.mat',sleepStageNames{iSta})];
                if ~exist(crosscorrname,'file')

                    tmpRE = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));

                    for iP = 1:numel(staP)

                        cstaP = staP(iP);
                        cendP = endP(iP);
                        timepoints = cstaP:winsizeT:cendP;

                        % Loop on each frequency
                        for iF = 1:numel(freqs)

                            % Get continuous power of the frequnecy currently considered
    %                         tempsig = squeeze(spec(iF,:));
                            tempsig = conv(10*log10(squeeze(spec(iF,:,:))),ones(1,500*4)/(500*4),'same');

                            % Normalize power and remove nan (replace them by mean power)
    %                         tempsigp = 10*log10(tempsig);
                            tempsigp = tempsig;
    %                         tempsigp(isnan(tempsigp)) = nanmean(tempsigp);

                            % Downsample all signals
                            dimcontscore = contscore(timepoints);
                            reye = eyesize(timepoints);

                            % Epoch time-frequency power signal for each timepoint of the
                            % cross-correlation
                            ep = repmat(timepoints,[numel(timepointsCorrAuto),1])+repmat(timepointsCorrAuto',[1,numel(timepoints)]);
                            fscore = reshape(contscore(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            fsigsigmar = reshape(tempsigp(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);

                            if all(sum(repmat(~isnan(reye),[size(fsigsigmar,1),1])&~isnan(fsigsigmar),2)>5)
                                % Cross-correlation pupil size-power
                                rrrE = corr(reye',fsigsigmar','row','pairwise');
                                tmpRE(iF,:,iP) = rrrE;
                            end
                        end
                    end
                    save(crosscorrname,'tmpRE');
                else
                    load(crosscorrname);
                end
                if ~all(ArteP==1)
                    RSpecE(:,:,iFile,iSta) = nanmean(tmpRE(:,:,ArteP==0),3);
                end
                if any(ArP==1)
                    RSpecE_withAr(:,:,iFile,iSta) = nanmean(tmpRE(:,:,ArP==1),3);
                end
                if any(ArP==0)
                    RSpecE_woAr(:,:,iFile,iSta) = nanmean(tmpRE(:,:,ArP==0),3);
                end

%                 crosscorrname = [subrespath,filesep,'Crosscorr',filesep,sprintf('crosscorr_%s_SpecxHeart.mat',sleepStageNames{iSta})];
%                 if ~exist(crosscorrname,'file')
%                     tmpRH = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
%                     tmpRHRVHF = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
%                     tmpRHRVLF = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
%                     tmpRHRVLFHFratio = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
%                     tmpRMSSD = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
% 
%                     for iP = 1:numel(staP)
% 
%                         cstaP = staP(iP);
%                         cendP = endP(iP);
%                         timepoints = cstaP:winsizeT:cendP;
% 
%                         % Loop on each frequency
%                         for iF = 1:numel(freqs)
% 
%                             % Get continuous power of the frequnecy currently considered
%                             tempsig = conv(10*log10(squeeze(spec(iF,:,:))),ones(1,500*4)/(500*4),'same');
% 
%                             % Normalize power and remove nan (replace them by mean power)
%                             tempsigp = tempsig;
%                     %         tempsigp(isnan(tempsigp)) = nanmean(tempsigp);
% 
%                             % Downsample all signals
%                             dimcontscore = contscore(timepoints);
%                             rRR = fRR(timepoints);
%                             rHFHRV = HFHRV(timepoints);
%                             rRMSSD = RMSSD(timepoints);
%                             rLFHRV = LFHRV(timepoints);
%                             rLFHFratio = LFHFratio(timepoints);
% 
%                             % Epoch time-frequency power signal for each timepoint of the
%                             % cross-correlation
%                             ep = repmat(timepoints,[numel(timepointsCorrAuto),1])+repmat(timepointsCorrAuto',[1,numel(timepoints)]);
%                             fscore = reshape(contscore(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
%                             fsigsigmar = reshape(tempsigp(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
% 
%                             if all(sum(repmat(~isnan(rRR),[size(fsigsigmar,1),1])&~isnan(fsigsigmar),2)>5)
%                                 % Cross-correlation pupil size-power
%                                 rrrH = corr(rRR',fsigsigmar','row','pairwise');
%                                 tmpRH(iF,:,iP) = rrrH;
%                                 % Cross-correlation heart-rate-power
%                                 rrrH = corr(rHFHRV',fsigsigmar','row','pairwise');
%                                 tmpRHRVHF(iF,:,iP) = rrrH;
%                                 % Cross-correlation heart-rate-power
%                                 rrrH = corr(rRMSSD',fsigsigmar','row','pairwise');
%                                 tmpRMSSD(iF,:,iP) = rrrH;
%                                 % Cross-correlation heart-rate-power
%                                 rrrH = corr(rLFHRV',fsigsigmar','row','pairwise');
%                                 tmpRHRVLF(iF,:,iP) = rrrH;
%                                 % Cross-correlation heart-rate-power
%                                 rrrH = corr(rLFHFratio',fsigsigmar','row','pairwise');
%                                 tmpRHRVLFHFratio(iF,:,iP) = rrrH;
% 
%                             end
%                         end
%                     end
%                     save(crosscorrname,'tmpRH','tmpRHRVHF','tmpRHRVLF','tmpRHRVLFHFratio','tmpRMSSD');
%                 else
%                     load(crosscorrname);
%                 end
%                 if any(ismember(chanlabels,'ecg'))
%                     RSpecH(:,:,iFile,iSta) = nanmean(tmpRH,3);
%                     RSpecHRVHF(:,:,iFile,iSta) = nanmean(tmpRHRVHF,3);
%                     RSpecRMSSD(:,:,iFile,iSta) = nanmean(tmpRMSSD,3);
%                     RSpecHRVLF(:,:,iFile,iSta) = nanmean(tmpRHRVLF,3);
%                     RSpecHRVLFHFratio(:,:,iFile,iSta) = nanmean(tmpRHRVLFHFratio,3);
%                 end
% 
% 
%                 crosscorrname = [subrespath,filesep,'Crosscorr',filesep,sprintf('crosscorr_%s_SpecxMuscle.mat',sleepStageNames{iSta})];
%                 if ~exist(crosscorrname,'file')
%                     tmpRM = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
% 
%                     for iP = 1:numel(staP)
% 
%                         cstaP = staP(iP);
%                         cendP = endP(iP);
%                         timepoints = cstaP:winsizeT:cendP;
% 
%                         % Loop on each frequency
%                         for iF = 1:numel(freqs)
% 
%                             % Get continuous power of the frequnecy currently considered
%                             tempsig = conv(10*log10(squeeze(spec(iF,:,:))),ones(1,500*4)/(500*4),'same');
% 
%                             % Normalize power and remove nan (replace them by mean power)
%                             tempsigp = tempsig;
%                     %         tempsigp(isnan(tempsigp)) = nanmean(tempsigp);
% 
%                             % Downsample all signals
%                             dimcontscore = contscore(timepoints);
%                             rEMG = fEMG(timepoints);
% 
%                             % Epoch time-frequency power signal for each timepoint of the
%                             % cross-correlation
%                             ep = repmat(timepoints,[numel(timepointsCorrAuto),1])+repmat(timepointsCorrAuto',[1,numel(timepoints)]);
%                             fscore = reshape(contscore(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
%                             fsigsigmar = reshape(tempsigp(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
% 
%                             if all(sum(repmat(~isnan(rEMG),[size(fsigsigmar,1),1])&~isnan(fsigsigmar),2)>5)
%                                 % Cross-correlation muscle tone
%                                 rrrM = corr(rEMG',fsigsigmar','row','pairwise');
%                                 tmpRM(iF,:,iP) = rrrM;
%                             end
%                         end
%                     end
%                     save(crosscorrname,'tmpRM');
%                 else
%                     load(crosscorrname);
%                 end
%                 
%                 if any(ismember(chanlabels,'emg'))
%                     RSpecM(:,:,iFile,iSta) = nanmean(tmpRM,3);
%                 end
% 
%                 crosscorrname = [subrespath,filesep,'Crosscorr',filesep,sprintf('crosscorr_%s_SpecxBreathing.mat',sleepStageNames{iSta})];
%                 if ~exist(crosscorrname,'file')
%                     tmpRB = nan(numel(freqs),numel(timepointsCorrAuto),numel(staP));
% 
%                     for iP = 1:numel(staP)
% 
%                         cstaP = staP(iP);
%                         cendP = endP(iP);
%                         timepoints = cstaP:winsizeT:cendP;
% 
%                         % Loop on each frequency
%                         for iF = 1:numel(freqs)
% 
%                             % Get continuous power of the frequnecy currently considered
%                             tempsig = conv(10*log10(squeeze(spec(iF,:,:))),ones(1,500*4)/(500*4),'same');
% 
%                             % Normalize power and remove nan (replace them by mean power)
%                             tempsigp = tempsig;
%                     %         tempsigp(isnan(tempsigp)) = nanmean(tempsigp);
% 
%                             % Downsample all signals
%                             dimcontscore = contscore(timepoints);
%                             rBB = fBB(timepoints);
% 
%                             % Epoch time-frequency power signal for each timepoint of the
%                             % cross-correlation
%                             ep = repmat(timepoints,[numel(timepointsCorrAuto),1])+repmat(timepointsCorrAuto',[1,numel(timepoints)]);
%                             fscore = reshape(contscore(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
%                             fsigsigmar = reshape(tempsigp(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
% 
%                             if all(sum(repmat(~isnan(rBB),[size(fsigsigmar,1),1])&~isnan(fsigsigmar),2)>5)
%                                 % Cross-correlation breathing rate-power
%                                 rrrB = corr(rBB',fsigsigmar','row','pairwise');
%                                 tmpRB(iF,:,iP) = rrrB;
%                             end
%                         end
%                     end
%                     save(crosscorrname,'tmpRB');
%                 else
%                     load(crosscorrname);
%                 end
%                 if any(ismember(chanlabels,'bre')) && any(ismember({'good','ok'},SessionInfos{indSes,8}))
%                     RSpecB(:,:,iFile,iSta) = nanmean(tmpRB,3);
%                 end
            end
            
            for iSta = 1:numel(sleepStages)
                StOI = sleepStages{iSta};

                endP = find(mod(gyt_CountContinuous(+ismember(contscore,StOI)),winsizeCorrAuto*500)==winsizeCorrAuto*500-1);
                staP = endP-winsizeCorrAuto*500;
                gP = (staP>winsizeCorrAuto*500)&(endP<numel(contscore)-winsizeCorrAuto*500);
                staP = staP(gP);
                endP = endP(gP);
                NboutsAuto(iFile,iSta) = numel(staP);
                if numel(staP)>0
                    ep = repmat((1:winsizeCorrAuto*500)',[1,numel(staP)])+repmat(staP,[winsizeCorrAuto*500,1]);
                    ArteP = any(reshape(contArtefact(ep(:)),[winsizeCorrAuto*500,numel(staP)])==1,1);
                else
                    ArteP = [];
                end
                
                crosscorrname = [subrespath,filesep,'Crosscorr',filesep,sprintf('crosscorr_%s_EyexPhysio.mat',sleepStageNames{iSta})];
                if ~exist(crosscorrname,'file')

                    tmpRHxE = nan(numel(timepointsCorrAuto),numel(staP));
                    tmpLFRHxE = nan(numel(timepointsCorrAuto),numel(staP));
                    tmpHFRHxE = nan(numel(timepointsCorrAuto),numel(staP));
                    tmpRHratioxE = nan(numel(timepointsCorrAuto),numel(staP));
                    tmpMxE = nan(numel(timepointsCorrAuto),numel(staP));
                    tmpBxE = nan(numel(timepointsCorrAuto),numel(staP));


                    for iP = 1:numel(staP)

                        cstaP = staP(iP);
                        cendP = endP(iP);
                        timepoints = cstaP:winsizeT:cendP;

                        % Downsample all signals
                        dimcontscore = contscore(timepoints);
                        reye = eyesize(timepoints);

                        % Epoch time-frequency power signal for each timepoint of the
                        % cross-correlation
                        ep = repmat(timepoints,[numel(timepointsCorrAuto),1])+repmat(timepointsCorrAuto',[1,numel(timepoints)]);
                        fscore = reshape(contscore(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                        ffRR = reshape(fRR(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);

                        if all(sum(repmat(~isnan(reye),[size(ffRR,1),1])&~isnan(ffRR),2)>5) 
                            % Cross-correlation heart-rate x pupil size
                            rrrHxE = corr(reye',ffRR','row','pairwise');
                            tmpRHxE(:,iP) = rrrHxE;

                            fHFHRV = reshape(HFHRV(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            % Cross-correlation heart-rate x pupil size
                            rrrHFHxE = corr(reye',fHFHRV','row','pairwise');
                            tmpHFRHxE(:,iP) = rrrHFHxE;

                            fLFHRV = reshape(LFHRV(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            % Cross-correlation heart-rate x pupil size
                            rrrLFHxE = corr(reye',fLFHRV','row','pairwise');
                            tmpLFRHxE(:,iP) = rrrLFHxE;

                            ffRRatio = reshape(LFHFratio(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            % Cross-correlation heart-rate x pupil size
                            rrrHratioxE = corr(reye',ffRRatio','row','pairwise');
                            tmpRHratioxE(:,iP) = rrrHratioxE;

                            fM = reshape(fEMG(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            % Cross-correlation heart-rate x pupil size
                            rrrMxE = corr(reye',fM','row','pairwise');
                            tmpMxE(:,iP) = rrrMxE;

                            fB = reshape(fBB(ep(:)),[numel(timepointsCorrAuto),numel(timepoints)]);
                            % Cross-correlation heart-rate x pupil size
                            rrrBxE = corr(reye',fB','row','pairwise');
                            tmpBxE(:,iP) = rrrBxE;
                        end
                    end
                    save(crosscorrname,'tmpRHxE','tmpHFRHxE','tmpLFRHxE','tmpRHratioxE','tmpMxE','tmpBxE');
                else
                    load(crosscorrname);
                end
                if any(ismember(chanlabels,'ecg')) && ~all(ArteP==1)
                    RExHR(:,iFile,iSta) = nanmean(tmpRHxE(:,ArteP==0),2);
                    RExHFHR(:,iFile,iSta) = nanmean(tmpHFRHxE(:,ArteP==0),2);
                    RExLFHR(:,iFile,iSta) = nanmean(tmpLFRHxE(:,ArteP==0),2);
                    RExHRratio(:,iFile,iSta) = nanmean(tmpRHratioxE(:,ArteP==0),2);
                end
                if any(ismember(chanlabels,'emg')) && ~all(ArteP==1)
                    RExM(:,iFile,iSta) = nanmean(tmpMxE(:,ArteP==0),2);
                end
                if any(ismember(chanlabels,'bre')) && any(ismember({'good','ok'},SessionInfos{indSes,8})) && ~all(ArteP==1)
                    RExB(:,iFile,iSta) = nanmean(tmpBxE(:,ArteP==0),2);
                end

            end  
        end
    end

    save([Mainpath,filesep,'Results',filesep,'ISO.mat'],'timepointsCorr',...
        'winsize','Nbouts','NboutsAuto','RSpecE','RSpecE_withAr','RSpecE_woAr','RSpecH','RExHR','RExHFHR','RExLFHR','RExHRratio','RExM','RExB',...
        'RSpecRMSSD','RSpecHRVHF','RSpecB','RSpecM',...
        'freqs','ISOfreqs');
else
    load([Mainpath,filesep,'Results',filesep,'ISO.mat']);
end

%%

function z = nanzscore(x, dim)

if nargin<2
    if ndims(x)>2
        dim = 1;
    elseif sum(size(x)>1)>1
        dim = 1;
    else
        dim = find(size(x)>1);
    end
end

z = (x-nanmean(x,dim))/nanstd(x,[],dim);

end
