%% DRUG vs CONTROL
% Each diamond = one sleep session

clear; close all; clc;

figure('Color','w');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');


%% ============================================================
% DAPI
% =============================================================

fileLoc = '***';

sessionsD = { '***'};

sd_time_mean = NaN(numel(sessionsD),2);
sd_time_std  = NaN(numel(sessionsD),2);
sdc          = NaN(numel(sessionsD),1);


nexttile(1);
hold on;

title('dapi vs. control');
ylabel('Pupil diameter (px)');


for is = 1:numel(sessionsD)

    session = sessionsD{is};

    try
        load([fileLoc session '\states_syn.mat']);
    catch
    end

    try
        load([fileLoc session '\state_interp.mat']);
    catch
    end

    load([fileLoc session '\eyes_sync.mat']);
    load([fileLoc session '\rr.mat']);


    % Normalize
    diam_eye1 = diam_eye1 ./ r;
    diam_eye0 = diam_eye0 ./ l;


    % Match missing values between eyes
    diam_eye0(isnan(diam_eye1)) = NaN;
    diam_eye1(isnan(diam_eye0)) = NaN;


    % Determine drug eye from session name
    side = extractAfter(session,'dapi');

    if side(1) == 'R'
        drugdiam = diam_eye1;
        cntdiam  = diam_eye0;
    else
        drugdiam = diam_eye0;
        cntdiam  = diam_eye1;
    end


    % Per-session mean and SD
    m_d = mean(drugdiam,'omitnan');
    m_c = mean(cntdiam,'omitnan');

    s_d = std(drugdiam,0,'omitnan');
    s_c = std(cntdiam,0,'omitnan');

    sd_time_mean(is,:) = [m_d m_c];
    sd_time_std(is,:)  = [s_d s_c];


    % Plot each session
    plot(1,m_d,'dm');
    plot(2,m_c,'dk');

    % Drug/control are paired within the same session
    plot([1 2],[m_d m_c],'k-');


    % Pearson correlation between eyes
    validCorr = ~isnan(drugdiam) & ~isnan(cntdiam);

    if sum(validCorr) >= 3

        x = drugdiam(validCorr);
        y = cntdiam(validCorr);

        x = x(:);
        y = y(:);

        sdc(is) = corr(x,y,'Type','Pearson');

    else

        sdc(is) = NaN;

    end

end

xlim([0.5 2.5]);
ylim([0 13]);

xticks([1 2]);
xticklabels({'Drug','Control'});


%% DAPI paired t-test

[~,pd,ciDiffD,statsd] = ...
    ttest(sd_time_mean(:,1),sd_time_mean(:,2));


%% DAPI descriptive statistics

nD_cols = sum(~isnan(sd_time_mean),1);

muD = [mean(sd_time_mean(:,1),'omitnan'), ...
       mean(sd_time_mean(:,2),'omitnan')];

sdD = [std(sd_time_mean(:,1),0,'omitnan'), ...
       std(sd_time_mean(:,2),0,'omitnan')];

seD = sdD ./ sqrt(nD_cols);

dfD = nD_cols - 1;

tcritD = [tinv(0.975,dfD(1)), ...
          tinv(0.975,dfD(2))];

ciHW_D = tcritD .* seD;


%% ============================================================
% TROP
% =============================================================

fileLoc = '***';

sessionsT = { '***'};

st_time_mean = NaN(numel(sessionsT),2);
st_time_std  = NaN(numel(sessionsT),2);
stc          = NaN(numel(sessionsT),1);

nexttile(2);
hold on;

title('trop vs. control');
ylabel('Pupil diameter (px)');

for is = 1:numel(sessionsT)

    session = sessionsT{is};

    try
        load([fileLoc session '\states_syn.mat']);
    catch
    end

    try
        load([fileLoc session '\state_interp.mat']);
    catch
    end

    load([fileLoc session '\eyes_sync.mat']);
    load([fileLoc session '\rr.mat']);

    % Normalize
    diam_eye1 = diam_eye1 ./ r;
    diam_eye0 = diam_eye0 ./ l;

    % Match missing values between eyes
    diam_eye0(isnan(diam_eye1)) = NaN;
    diam_eye1(isnan(diam_eye0)) = NaN;

    % Determine drug eye from session name
    side = extractAfter(session,'trop');

    if side(1) == 'R'
        drugdiam = diam_eye1;
        cntdiam  = diam_eye0;
    else
        drugdiam = diam_eye0;
        cntdiam  = diam_eye1;
    end


    % Per-session mean and SD
    m_d = mean(drugdiam,'omitnan');
    m_c = mean(cntdiam,'omitnan');

    s_d = std(drugdiam,0,'omitnan');
    s_c = std(cntdiam,0,'omitnan');

    st_time_mean(is,:) = [m_d m_c];
    st_time_std(is,:)  = [s_d s_c];

    % Plot each session
    plot(1,m_d,'db');
    plot(2,m_c,'dk');

    % Drug/control are paired within the same session
    plot([1 2],[m_d m_c],'k-');

    % Pearson correlation between eyes
    validCorr = ~isnan(drugdiam) & ~isnan(cntdiam);

    if sum(validCorr) >= 3

        x = drugdiam(validCorr);
        y = cntdiam(validCorr);

        x = x(:);
        y = y(:);

        stc(is) = corr(x,y,'Type','Pearson');

    else

        stc(is) = NaN;

    end

end


xlim([0.5 2.5]);
ylim([0 13]);

xticks([1 2]);
xticklabels({'Drug','Control'});


%% TROP paired t-test

[~,pt,ciDiffT,statst] = ...
    ttest(st_time_mean(:,1),st_time_mean(:,2));


%% TROP descriptive statistics

nT_cols = sum(~isnan(st_time_mean),1);

muT = [mean(st_time_mean(:,1),'omitnan'), ...
       mean(st_time_mean(:,2),'omitnan')];

sdT = [std(st_time_mean(:,1),0,'omitnan'), ...
       std(st_time_mean(:,2),0,'omitnan')];

seT = sdT ./ sqrt(nT_cols);

dfT = nT_cols - 1;

tcritT = [tinv(0.975,dfT(1)), ...
          tinv(0.975,dfT(2))];

ciHW_T = tcritT .* seT;



%% ============================================================
% INTER-EYE CORRELATION: DAPI vs TROP
% =============================================================

nexttile(3);
hold on;

title('Inter-eye correlation');
ylabel('Pearson r');

xlim([0.5 2.5]);
ylim([0.2 1]);

xticks([1 2]);
xticklabels({'dapi','trop'});


%% Remove NaNs

rD = sdc(~isnan(sdc));
rT = stc(~isnan(stc));

nDcorr = numel(rD);
nTcorr = numel(rT);


%% Plot ALL individual session correlations

for is = 1:numel(rD)
    plot(1,rD(is),'dm');
end

for is = 1:numel(rT)
    plot(2,rT(is),'db');
end



%% ============================================================
% STATISTICS FOR CORRELATIONS
% Fisher-z transform + Welch ttest2
% =============================================================

rD_safe = rD;
rT_safe = rT;

rD_safe(rD_safe >= 1)  = 0.999999;
rD_safe(rD_safe <= -1) = -0.999999;

rT_safe(rT_safe >= 1)  = 0.999999;
rT_safe(rT_safe <= -1) = -0.999999;

% Fisher-z transformation
zD = atanh(rD_safe);
zT = atanh(rT_safe);

% Independent Welch t-test
[~,ps,~,stats_corr] = ...
    ttest2(zD,zT,'Vartype','unequal');



%% ============================================================
% CORRELATION DESCRIPTIVE STATISTICS + 95% CI
% =============================================================

meanZD = mean(zD);
meanZT = mean(zT);

sdZD = std(zD);
sdZT = std(zT);

seZD = sdZD ./ sqrt(nDcorr);
seZT = sdZT ./ sqrt(nTcorr);

tcritZD = tinv(0.975,nDcorr-1);
tcritZT = tinv(0.975,nTcorr-1);

ciZD_low  = meanZD - tcritZD*seZD;
ciZD_high = meanZD + tcritZD*seZD;

ciZT_low  = meanZT - tcritZT*seZT;
ciZT_high = meanZT + tcritZT*seZT;


% Transform back to r
mDcorr = tanh(meanZD);
mTcorr = tanh(meanZT);

ciRD_low  = tanh(ciZD_low);
ciRD_high = tanh(ciZD_high);

ciRT_low  = tanh(ciZT_low);
ciRT_high = tanh(ciZT_high);



%% ============================================================
% PRINT RESULTS
% =============================================================

fprintf('\n=== DAPI ===\n');

fprintf(['Drug: mean = %.3f, SD = %.3f, ' ...
         '95%% CI = [%.3f, %.3f], n = %d sessions\n'], ...
    muD(1),sdD(1), ...
    muD(1)-ciHW_D(1),muD(1)+ciHW_D(1), ...
    nD_cols(1));

fprintf(['Control: mean = %.3f, SD = %.3f, ' ...
         '95%% CI = [%.3f, %.3f], n = %d sessions\n'], ...
    muD(2),sdD(2), ...
    muD(2)-ciHW_D(2),muD(2)+ciHW_D(2), ...
    nD_cols(2));

fprintf('Paired t-test: t(%d) = %.3f, p = %.4g\n', ...
    statsd.df,statsd.tstat,pd);

fprintf('95%% CI paired difference = [%.3f, %.3f]\n', ...
    ciDiffD(1),ciDiffD(2));


fprintf('\n=== TROP ===\n');

fprintf(['Drug: mean = %.3f, SD = %.3f, ' ...
         '95%% CI = [%.3f, %.3f], n = %d sessions\n'], ...
    muT(1),sdT(1), ...
    muT(1)-ciHW_T(1),muT(1)+ciHW_T(1), ...
    nT_cols(1));

fprintf(['Control: mean = %.3f, SD = %.3f, ' ...
         '95%% CI = [%.3f, %.3f], n = %d sessions\n'], ...
    muT(2),sdT(2), ...
    muT(2)-ciHW_T(2),muT(2)+ciHW_T(2), ...
    nT_cols(2));

fprintf('Paired t-test: t(%d) = %.3f, p = %.4g\n', ...
    statst.df,statst.tstat,pt);

fprintf('95%% CI paired difference = [%.3f, %.3f]\n', ...
    ciDiffT(1),ciDiffT(2));


fprintf('\n=== INTER-EYE CORRELATION ===\n');

fprintf(['DAPI: mean r = %.3f, 95%% CI = [%.3f, %.3f], ' ...
         'n = %d sessions\n'], ...
    mDcorr,ciRD_low,ciRD_high,nDcorr);

fprintf(['TROP: mean r = %.3f, 95%% CI = [%.3f, %.3f], ' ...
         'n = %d sessions\n'], ...
    mTcorr,ciRT_low,ciRT_high,nTcorr);

fprintf(['DAPI vs TROP: Welch t-test on Fisher-z r: ' ...
         't(%.2f) = %.3f, p = %.4g\n'], ...
    stats_corr.df,stats_corr.tstat,ps);



%% ============================================================
% SOURCE DATA FOR PUBLISHER
% =============================================================

DAPI_source = table( ...
    sessionsD(:), ...
    sd_time_mean(:,1), ...
    sd_time_mean(:,2), ...
    sdc, ...
    'VariableNames', ...
    {'Session','DrugMean','ControlMean','PearsonR'});


TROP_source = table( ...
    sessionsT(:), ...
    st_time_mean(:,1), ...
    st_time_mean(:,2), ...
    stc, ...
    'VariableNames', ...
    {'Session','DrugMean','ControlMean','PearsonR'});


disp(' ');
disp('DAPI source data:');
disp(DAPI_source);

disp(' ');
disp('TROP source data:');
disp(TROP_source);