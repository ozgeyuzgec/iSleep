%% detection with visualization (aligned; no prewin shading; scaling option)

clear; 
% close all; clc;

base_dir = '\\nasac-m2.unige.ch\m-huberlab\GHuber\users\Ozge\Data sets\Surgery rec';

use_sessions = {
    'patient07'
    'patient09'
    'patient20'
    'patient08'
    'patient19'
    'patient18'};

% Choose eye0 for sessions containing "08","19","09" (same rule as segment script)
use_eye0 = false(size(use_sessions));
for i = 1:numel(use_sessions)
    use_eye0(i) = any(contains(string(use_sessions{i}), ["08","19","09"]));
end

% ===== Detection params (MATCH segment-collection script) =============
fs          = 30;        % Hz
win_pre_s   = 60;        % pre-window for NaN check (s)  [uses raw, unfilled]
movwin_s    = 120;       % rolling baseline window (s) for 30th percentile
alpha_amp   = 1.20;      % amplitude ratio gate (pupil/base >= alpha somewhere in segment)
z_th        = 0.2;      % start threshold on z-velocity
peak_z      = 0.2;      % peak z-velocity requirement
minDur_s    = 1;         % minimal duration (s)
minGap_s    = 0;        % minimal gap between onsets (s)
prom_frac   = 0.1;      % 10% prominence within first 5 s
prom_win_s  = 5;
bw = 15;    % percenttile range


minDur      = round(minDur_s*fs);
minGap      = round(minGap_s*fs);
prom_win    = round(prom_win_s*fs);
win_n       = movwin_s * fs;
pre_samp    = win_pre_s * fs;

% Plotting options
PLOT_PREWIN = false;     % <- do NOT show 60s pre-window NaN blocks
USE_SCALING = true;      % <- overlay scaled z-velocity on pupil axis (set false to use yyaxis)

% Low-pass filter < 0.2 Hz (same as segment script)
[b_lp, a_lp] = butter(2, 0.2/(fs/2), 'low');

% Rolling 30th percentile baseline (blockwise, same stepping as segment script)
step = 100;

for si = 1:numel(use_sessions)
    sess = use_sessions{si};
    sess_dir = fullfile(base_dir, sess);
    if use_eye0(si)
        file = fullfile(sess_dir, 'eye0_filt.mat'); vName = 'eye0_filt';
    else
        file = fullfile(sess_dir, 'eye1_filt.mat'); vName = 'eye1_filt';
    end
    if ~exist(file,'file')
        warning('Missing %s; skipped.', file);
        continue
    end

    % ---------- load & keep raw for NaN check (no fill) --------------
    sig_raw_unfilled = load(file, vName).(vName);
    sig = fillmissing(sig_raw_unfilled, 'nearest');   % working copy (filled like segment code)
    N = numel(sig);

    % ---------- rolling 30th percentile baseline ---------------------
    padlen = floor(win_n/2);
    padded = [repmat(sig(1), padlen, 1); sig; repmat(sig(end), padlen, 1)];
    base30 = zeros(size(sig));
    for t = 1:step:N
        idx_block = t:min(t+step-1, N);
        W = nan(win_n, numel(idx_block));
        for j = 1:numel(idx_block)
            w_start = idx_block(j);
            W(:,j) = padded(w_start : w_start + win_n - 1);
        end
        base30(idx_block) = prctile(W, bw, 1);
    end
    base30 = fillmissing(base30, 'nearest');
    base30(base30 < eps) = eps;

    % ---------- filter, velocity, z-score ----------------------------
    sig_lp = filtfilt(b_lp, a_lp, double(sig));
    vel    = [NaN; diff(sig_lp)] * fs;                  % velocity (units/s)
    zvel   = (vel - nanmean(vel)) / nanstd(vel);        % z-score

    % ---------- velocity-based candidate segments --------------------
    active = zvel > z_th;
    edges  = diff([0; active(:); 0]);
    starts = find(edges == 1);
    ends   = find(edges == -1) - 1;

    % ---------- apply the same gates as the segment script -----------
    relSig = sig ./ base30;                              % amplitude ratio vs baseline
    keep = false(size(starts));
    for i = 1:numel(starts)
        s0 = starts(i); e0 = ends(i);
        idx = s0:e0;

        % A) Pre-stim NaN > 30%? (check unfilled raw, 60 s window)
        pre_start = max(1, s0 - pre_samp);
        pre_end   = s0 - 1;
        if pre_end >= pre_start
            pre_win = sig_raw_unfilled(pre_start:pre_end);
            if mean(isnan(pre_win)) > 0.30, continue, end
        end

        % B) min duration
        if numel(idx) < minDur, continue, end

        % C) peak z-velocity requirement
        if max(zvel(idx)) < peak_z, continue, end

        % D) amplitude ratio gate (>= alpha somewhere in segment)
        if ~any(relSig(idx) >= alpha_amp), continue, end

        % E) early-prominence gate within first 5 s after onset
        w1 = s0 : min(N, s0 + prom_win);
        if isempty(w1), continue, end
        peak_val   = max(sig(w1));
        base_val   = min(sig(w1));
        prom_thresh = prom_frac * mean(base30(w1));
        if (peak_val - base_val) < prom_thresh, continue, end

        keep(i) = true;
    end

    % Keep only accepted
    starts = starts(keep); ends = ends(keep);

    % F) enforce min gap between onsets
    if ~isempty(starts)
        keep_idx = true(size(starts));
        last_kept = starts(1);
        for i = 2:numel(starts)
            if starts(i) - last_kept < minGap
                keep_idx(i) = false;
            else
                last_kept = starts(i);
            end
        end
        starts = starts(keep_idx); ends = ends(keep_idx);
    end

    % ---------- plotting ---------------------------------------------
    figure('Name',sess,'Color','w','Position',[100 100 1300 560]); hold on

    % Pupil (left axis)
    plot(sig,'b','DisplayName','Pupil (raw)'); hold on
    plot(sig_lp,'c','DisplayName','Pupil (low-pass <0.2 Hz)');
    plot(base30,'k','LineWidth',1.0,'DisplayName',sprintf('Rolling 30th %% (%.0fs)', movwin_s));
    plot(alpha_amp*base30,'g--','LineWidth',1.0,'DisplayName',sprintf('\\alpha×baseline (\\alpha=%.2f)', alpha_amp));

    if USE_SCALING
        % -------- overlay scaled z-velocity on SAME axis -------------
        diffScale = (max(sig) - min(sig)) / 4;
        diffScale = 2;
        dPlot     = diffScale * zvel;
        dTh_line  = diffScale * z_th;
        dPk_line  = diffScale * peak_z;

        plot(dPlot,'m','DisplayName','Velocity (z) × scale');
        yline(dTh_line,'--m','LineWidth',1.0,'DisplayName',sprintf('z_{vel} > %.2f (scaled)', z_th));
        yline(dPk_line,':m','LineWidth',1.0,'DisplayName',sprintf('peak z \\ge %.2f (scaled)', peak_z));
    else
        % -------- or use dual y-axes (no scaling) --------------------
        yyaxis right
        plot(zvel,'m','DisplayName','Velocity (z)');
        yline(z_th,'--m','LineWidth',1.0,'DisplayName',sprintf('z_{vel} > %.2f', z_th));
        yline(peak_z,':m','LineWidth',1.0,'DisplayName',sprintf('peak z \\ge %.2f', peak_z));
        ylabel('Velocity (z)');
        yyaxis left
    end

    % Get left-axis limits for patches
    yL = ylim;

    % Visualize each accepted dilation and criteria (NO pre-window shading)
    for i = 1:numel(starts)
        s0 = starts(i); e0 = ends(i);

        % Segment shading
        fill([s0 e0 e0 s0], [yL(1) yL(1) yL(2) yL(2)], ...
             'r','FaceAlpha',0.10,'EdgeColor','none','HandleVisibility','off');

        % Onset/offset markers
        xline(s0,'r:','HandleVisibility','off');
        xline(e0,'r:','HandleVisibility','off');

        % 5-s early-prominence window
        w1 = s0 : min(N, s0 + prom_win);
        hPr = fill([w1(1) w1(end) w1(end) w1(1)], [yL(1) yL(1) yL(2) yL(2)], ...
                   [0.85 1.0 0.85], 'FaceAlpha',0.20, 'EdgeColor','none');
        if i==1
            set(hPr,'HandleVisibility','on');
        else
            set(hPr,'HandleVisibility','off');
        end


        % Baseline & α×baseline across the 5-s window
        plot(w1, base30(w1), 'k', 'LineWidth', 2, 'HandleVisibility', 'off');
        plot(w1, alpha_amp*base30(w1), 'g', 'LineWidth', 2, 'HandleVisibility', 'off');

        % Mark baseline & threshold at onset
        bl  = base30(s0);
        thr = alpha_amp * bl;
        if i==1
            plot(s0, bl,  'ko','MarkerFaceColor','k','DisplayName','Baseline at onset');
            plot(s0, thr, 'go','MarkerFaceColor','g','DisplayName','Threshold at onset (\\alpha×BL)');
        else
            plot(s0, bl,  'ko','MarkerFaceColor','k','HandleVisibility','off');
            plot(s0, thr, 'go','MarkerFaceColor','g','HandleVisibility','off');
        end

        % Dilation onset symbol (place on whichever axis you use for velocity)
        if USE_SCALING
            onset_val = diffScale * zvel(s0);
        else
            % if using yyaxis, plot on right axis at zvel(s0)
            yyaxis right; onset_val = zvel(s0); yyaxis left;
        end
        if i==1
            plot(s0, onset_val, 'k^', 'MarkerFaceColor','k','MarkerSize',6, 'DisplayName','Dilation onset');
        else
            plot(s0, onset_val, 'k^', 'MarkerFaceColor','k','MarkerSize',6, 'HandleVisibility','off');
        end

        % Optional text annotation: show prominence check only (no NaN%)
        peak_val   = max(sig(w1));
        base_val   = min(sig(w1));
        prom_thresh = prom_frac * mean(base30(w1)); % prominance is more than dilation window baseline 
        dprom = peak_val - base_val;
        text(s0, yL(2) - 0.05*(yL(2)-yL(1)), ...
             sprintf('\\Delta=%.3g vs thr=%.3g', dprom, prom_thresh), ...
             'Color',[0.25 0.25 0.25], 'FontSize',8, 'HorizontalAlignment','right');
    end

    title(sprintf('%s [%s] — %d dilations | z_{th}=%.2f, peak_{z}=%.2f, \\alpha=%.2f, win_{BL}=%ds%s', ...
           sess, vName, numel(starts), z_th, peak_z, alpha_amp, movwin_s));
    xlabel('Sample'); ylabel('Pupil (pixels)');
    grid on
    legend('Location','northoutside','Orientation','horizontal','NumColumns',3);
end


%% grand average with session averages 
% SAME AS THE FINAL ONE ABOVE, TAKES SESSION AVG BETTER
% USE THIS
% like script 1

clear; 
close all; clc;
base_dir = '\\nasac-m2.unige.ch\m-huberlab\GHuber\users\Ozge\Data sets\Surgery rec';

sessions = {
    'patient07'
    'patient09'
    'patient20'
    'patient08'
    'patient19'
    'patient18'};

use_eye0 = false(size(sessions));
for i = 1:numel(sessions)
    use_eye0(i) = any(contains(string(sessions{i}), ["08", "19", "09"]));
end

% Settings
% fs_eye   = 30;
% fs_an    = 1;
% win_pre  = 60;   % seconds before event
% win_post = 180;  % seconds after event
% seg_eye  = (win_pre+win_post)*fs_eye + 1;
% seg_an   = (win_pre+win_post)*fs_an + 1;
% minDur   = round(1 * fs_eye);
% [b,a]    = butter(2, 0.2/(fs_eye/2), 'low');
% movwin   = 120;
% win_n    = movwin * fs_eye;
% step     = 100;
% z_th     = 0.20;
% peak_z   = 0.5;
% alpha_amp = 1.20;
% min_gap = 10 * fs_eye;
% basewin = 20; % seconds of pre-stim baseline


% Settings
fs_eye   = 30;
fs_an    = 1;
win_pre  = 60;   % seconds before event
win_post = 180;  % seconds after event
seg_eye  = (win_pre+win_post)*fs_eye + 1;
seg_an   = (win_pre+win_post)*fs_an + 1;
minDur   = round(1 * fs_eye);
[b,a]    = butter(2, 0.2/(fs_eye/2), 'low');
movwin   = 120;
win_n    = movwin * fs_eye;
step     = 100;
z_th     = 0.20;
peak_z   = 0.2;
alpha_amp = 1.20;
min_gap = 0 * fs_eye;
basewin = 20; % seconds of pre-stim baseline
bw = 15;
prom_frac   = 0.1;      % 10% prominence within first 5 s

% Grand-average collectors (all trials pooled)
PUPp_30BL = []; HRp_30BL = []; BISp_30BL = []; BPp_30BL = [];
% Grand-average collectors (per-session means; one row per session)
PUPp_30BL_sess = []; HRp_30BL_sess = []; BISp_30BL_sess = []; BPp_30BL_sess = [];
% Count dilations per session
nD_sessions = zeros(numel(sessions),1);

t_eye_template = ((-win_pre*fs_eye):(win_post*fs_eye))/fs_eye;
t_an_template  = (-win_pre):win_post;

for s = 1:numel(sessions)
    sess = sessions{s}; fprintf('\n--- %s ---\n', sess);
    ssdir = fullfile(base_dir, sess);

    % Load data
    if use_eye0(s)
        load(fullfile(ssdir,'eye0_filt.mat'),'eye0_filt'); pupil = eye0_filt;
        load(fullfile(ssdir,'eye0_time.mat'),'eye0_time'); t_raw = eye0_time;
    else
        load(fullfile(ssdir,'eye1_filt.mat'),'eye1_filt'); pupil = eye1_filt;
        load(fullfile(ssdir,'eye1_time.mat'),'eye1_time'); t_raw = eye1_time;
    end

    load(fullfile(ssdir,'annotations.mat'))
    load(fullfile(ssdir,'anesthesia.mat'))
    load(fullfile(ssdir,'t1_vid.mat'))

    % Time alignment
    cam_start = 3600*str2double(t1_vid(1:2)) + 60*str2double(t1_vid(4:5)) + str2double(t1_vid(7:8));
    t_eye = cam_start + t_raw - min(t_raw);

    % Trim time
    t_min = max([min(t_eye), min(trigTimes), min(timeAnest)]);
    t_max = min([max(t_eye), max(trigTimes), max(timeAnest)]);
    idx_eye = (t_eye >= t_min & t_eye <= t_max);
    idx_an  = (timeAnest >= t_min & timeAnest <= t_max);

    % Keep raw pupil (with NaNs) for NaN-percentage check
    pupil_raw = pupil(idx_eye);
    pupil     = fillmissing(pupil_raw,'nearest'); % working signal

    t_eye = t_eye(idx_eye);
    ecg_hr = pleth_hr(idx_an);
    bis    = eeg_bis(idx_an);
    bp     = nibp_mean(idx_an);
    timeAnest = timeAnest(idx_an);

    % Rolling 30th percentile (pupil)
    padlen = floor(win_n/2);
    padded = [repmat(pupil(1), padlen, 1); pupil; repmat(pupil(end), padlen, 1)];
    movPercBase = zeros(size(pupil));
    for i = 1:step:numel(pupil)
        idx = i:min(i+step-1, numel(pupil));
        window = nan(win_n, numel(idx));
        for j = 1:numel(idx)
            w_start = idx(j);
            window(:,j) = padded(w_start:w_start+win_n-1);
        end
        movPercBase(idx) = prctile(window, bw, 1);
    end
    movPercBase = fillmissing(movPercBase, 'nearest');
    movPercBase(movPercBase < eps) = eps;

    % Velocity and z-scores (pupil)
    filt_pup = filtfilt(b,a,double(pupil));
    vel  = [NaN; diff(filt_pup)] * fs_eye;
    zvel = (vel - nanmean(vel)) / nanstd(vel);
    relSig = pupil ./ movPercBase;
    cand = zvel > z_th;
    e = diff([0; cand; 0]); starts = find(e==1); stops = find(e==-1)-1;

    good = false(size(starts));
    for k = 1:numel(starts)

        % --- REJECT if >30% of pre-stim window is NaN in raw pupil ---
        pre_samp = win_pre * fs_eye;
        pre_start = max(1, starts(k) - pre_samp);
        pre_end   = starts(k) - 1;
        if pre_end >= pre_start
            pre_win = pupil_raw(pre_start:pre_end);
            if mean(isnan(pre_win)) > 0.30
                continue; % too many NaNs before dilation → skip
            end
        end
        % -------------------------------------------------------------

        seg = starts(k):stops(k);
        if numel(seg)<minDur || max(zvel(seg))<peak_z, continue; end
        if ~any(relSig(seg) >= alpha_amp), continue; end
        win5s = starts(k):(starts(k)+round(5*fs_eye)); win5s(win5s > numel(pupil)) = [];
        if isempty(win5s), continue; end
        peak_val = max(pupil(win5s)); base_val = min(pupil(win5s));
        prom_thresh = prom_frac * mean(movPercBase(win5s));
        if (peak_val - base_val) < prom_thresh, continue; end
        good(k) = true;
    end

    starts = starts(good); stops = stops(good);
    if ~isempty(starts)
        keep_idx = true(size(starts)); last_kept = starts(1);
        for i = 2:numel(starts)
            if starts(i) - last_kept < min_gap
                keep_idx(i) = false;
            else
                last_kept = starts(i);
            end
        end
        starts = starts(keep_idx); stops = stops(keep_idx);
        nD = numel(starts);
    else
        nD = 0;
    end
    nD_sessions(s) = nD;
    if nD==0, continue, end

    % Segment collectors
    pup_r = NaN(nD, seg_eye); pup_d_30BL = pup_r; pup_p_30BL = pup_r;

    hr_r  = NaN(nD, seg_an);  hr_d_30BL  = hr_r;  hr_p_30BL  = hr_r;
    bis_r = NaN(nD, seg_an);  bis_d_30BL = bis_r; bis_p_30BL = bis_r;
    bp_r  = NaN(nD, seg_an);  bp_d_30BL  = bp_r;  bp_p_30BL  = bp_r;


    % Segment extraction
    for d = 1:nD
        iE = starts(d);
        iA = knnsearch(timeAnest(:), t_eye(iE));
        e_rng = (iE - win_pre*fs_eye):(iE + win_post*fs_eye);
        a_rng = (iA - win_pre*fs_an):(iA + win_post*fs_an);
        valid_e = e_rng >= 1 & e_rng <= numel(pupil);
        valid_a = a_rng >= 1 & a_rng <= numel(ecg_hr);

        % Pupil
        rawP = pupil(e_rng(valid_e));
        pup_r(d,valid_e) = rawP; %raw 
        base_30 = mean(rawP((win_pre*fs_eye - basewin*fs_eye):win_pre*fs_eye + 1), 'omitnan');
        pup_d_30BL(d,valid_e) = rawP - base_30; % Δ baseline removed 20s before
        pup_p_30BL(d,valid_e) = pup_d_30BL(d,valid_e) ./ base_30; % %Δ

        % HR / BIS / BP — same baseline logic
        rawHR  = ecg_hr(a_rng(valid_a));
        rawBIS = bis(a_rng(valid_a));
        rawBP  = bp(a_rng(valid_a));
        hr_r(d,valid_a)  = rawHR;
        bis_r(d,valid_a) = rawBIS;
        bp_r(d,valid_a)  = rawBP;

        idx0_an = (win_pre*fs_an - basewin*fs_an) : (win_pre*fs_an + 1);

        if all(idx0_an >= 1) && all(idx0_an <= numel(rawHR))
            base_hr = mean(rawHR(idx0_an), 'omitnan');
        else
            base_hr = NaN;
        end
        hr_d_30BL(d,valid_a) = rawHR - base_hr;
        hr_p_30BL(d,valid_a) = hr_d_30BL(d,valid_a) ./ base_hr;

        if all(idx0_an >= 1) && all(idx0_an <= numel(rawBIS))
            base_bis = mean(rawBIS(idx0_an), 'omitnan');
        else
            base_bis = NaN;
        end
        bis_d_30BL(d,valid_a) = rawBIS - base_bis;
        bis_p_30BL(d,valid_a) = bis_d_30BL(d,valid_a) ./ base_bis;

        if all(idx0_an >= 1) && all(idx0_an <= numel(rawBP))
            base_bp = mean(rawBP(idx0_an), 'omitnan');
        else
            base_bp = NaN;
        end
        bp_d_30BL(d,valid_a) = rawBP - base_bp;
        bp_p_30BL(d,valid_a) = bp_d_30BL(d,valid_a) ./ base_bp;
    end

    % === Per-session means (mean across trials) ===
    pup_sess_mean_30BL = nanmean(pup_p_30BL, 1);
    hr_sess_mean_30BL  = nanmean(hr_p_30BL,  1);
    bis_sess_mean_30BL = nanmean(bis_p_30BL, 1);
    bp_sess_mean_30BL  = nanmean(bp_p_30BL,  1);

    % Append per-session means to session-level collectors
    PUPp_30BL_sess = [PUPp_30BL_sess; pup_sess_mean_30BL];
    HRp_30BL_sess  = [HRp_30BL_sess;  hr_sess_mean_30BL];
    BISp_30BL_sess = [BISp_30BL_sess; bis_sess_mean_30BL];
    BPp_30BL_sess  = [BPp_30BL_sess;  bp_sess_mean_30BL];
    

    % Plot per-session (optional single-trial + averages)
    if ~strcmp(sess,'patient08')
        tx_e = t_eye_template(1:size(pup_d_30BL,2));
        tx_a = t_an_template(1:size(hr_d_30BL,2));
        figure('Name',[sess ' – Single Trials'],'Color','w');
        nRows = ceil(sqrt(nD)); nCols = ceil(nD / nRows);
        for d = 1:nD
            subplot(nRows,nCols,d); hold on
            plot(tx_e, pup_p_30BL(d,:), 'r'); 
            plot(tx_a, hr_p_30BL(d,:),  'b');
            xline(0,'--k'); xlim([-60 60]);
        end
        sgtitle([sess ' – Trials (Pupil % red, HR % blue)']);

        figure('Name',[sess ' – Averages'],'Color','w');
        subplot(4,1,1); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_e, nanmean(pup_p_30BL),  nanstd(pup_p_30BL)/sqrt(nD), {'r-'}); title('Pupil Δ %');  xlim([-60 180]);
        subplot(4,1,2); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(hr_p_30BL),   nanstd(hr_p_30BL)/sqrt(nD),   {'b-'}); title('HR Δ %');     xlim([-60 180]);
        subplot(4,1,3); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(bis_p_30BL),  nanstd(bis_p_30BL)/sqrt(nD), {'m-'}); title('BIS Δ %');    xlim([-60 180]);
        subplot(4,1,4); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(bp_p_30BL),   nanstd(bp_p_30BL)/sqrt(nD),  {'c-'}); title('BP Δ %');     xlim([-60 180]);
        sgtitle([sess ' – Mean % Change ' nD ' Dilations']);
    end

    % Save per-session data (includes per-session mean traces)
    save(fullfile(ssdir, 'pupil_segments_30BL.mat'), ...
        'pup_r','pup_d_30BL','pup_p_30BL', ...
        'hr_r','hr_d_30BL','hr_p_30BL', ...
        'bis_r','bis_d_30BL','bis_p_30BL', ...
        'bp_r','bp_d_30BL','bp_p_30BL', ...
        'pup_sess_mean_30BL','hr_sess_mean_30BL','bis_sess_mean_30BL','bp_sess_mean_30BL');

    % Append to grand average (all trials pooled)
    PUPp_30BL = [PUPp_30BL; pup_p_30BL];
    HRp_30BL  = [HRp_30BL;  hr_p_30BL];
    BISp_30BL = [BISp_30BL; bis_p_30BL];
    BPp_30BL  = [BPp_30BL;  bp_p_30BL];
end

% ==================== Grand averages ====================
baseline_str = sprintf(' %.0fs pre-stim mean', basewin);

% 1) Grand Average – all trials pooled (as before; SEM shading)
if ~isempty(PUPp_30BL)
    tx_e = t_eye_template(1:size(PUPp_30BL,2));
    tx_a = t_an_template(1:size(HRp_30BL,2));
    figure('Name','Grand Average – all trials (SEM shading)','Color','w');
    subplot(4,1,1); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_e, nanmean(PUPp_30BL), nanstd(PUPp_30BL)/sqrt(size(PUPp_30BL,1)), {'r-'}); title('Pupil Δ %');  xlim([-60 180]);
    subplot(4,1,2); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(HRp_30BL),  nanstd(HRp_30BL)/sqrt(size(HRp_30BL,1)),   {'b-'}); title('HR Δ %');     xlim([-60 180]);
    subplot(4,1,3); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(BISp_30BL), nanstd(BISp_30BL)/sqrt(size(BISp_30BL,1)), {'m-'}); title('BIS Δ %');    xlim([-60 180]);
    subplot(4,1,4); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(BPp_30BL),  nanstd(BPp_30BL)/sqrt(size(BPp_30BL,1)),   {'c-'}); title('BP Δ %');     xlim([-60 180]);
    sgtitle(sprintf(['All Trials | nz_{th}=%.2f | peak_{z}=%.2f | alpha_{amp}=%.2f | minDur=%.1fs | minGap=%.1fs | prom=10%% of baseline\n' ...
                     'Baseline:%s | win=%.0fs (%d samples) | lowpass <0.2Hz'], ...
                    z_th, peak_z, alpha_amp, ...
                    minDur/fs_eye, min_gap/fs_eye, baseline_str, movwin, win_n));
end

% 2) Grand Average – average of session means (std shading as requested)
if ~isempty(PUPp_30BL_sess)
    tx_e = t_eye_template(1:size(PUPp_30BL_sess,2));
    tx_a = t_an_template(1:size(HRp_30BL_sess,2));
    figure('Name','Grand Average – session means (STD shading)','Color','w');
    subplot(4,1,1); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_e, nanmean(PUPp_30BL_sess), nanstd(PUPp_30BL_sess)/sqrt(size(PUPp_30BL_sess,1)), {'r-'}); title('Pupil Δ % (session means)');  xlim([-60 180]);
    subplot(4,1,2); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(HRp_30BL_sess),  nanstd(HRp_30BL_sess)/sqrt(size(PUPp_30BL_sess,1)),  {'b-'}); title('HR Δ % (session means)');     xlim([-60 180]);
    subplot(4,1,3); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(BISp_30BL_sess), nanstd(BISp_30BL_sess)/sqrt(size(PUPp_30BL_sess,1)), {'m-'}); title('BIS Δ % (session means)');    xlim([-60 180]);
    subplot(4,1,4); hold on; xline(0,'--k'); yline(0,'--k'); shadedErrorBar(tx_a, nanmean(BPp_30BL_sess),  nanstd(BPp_30BL_sess)/sqrt(size(PUPp_30BL_sess,1)),  {'c-'}); title('BP Δ % (session means)');     xlim([-60 180]);
    sgtitle(sprintf(['Average of Session Averages (equal session weight) | Sessions: %d\n' ...
                     'Baseline:%s | win=%.0fs (%d samples) | lowpass <0.2Hz'], ...
                    size(PUPp_30BL_sess,1), baseline_str, movwin, win_n));
end





%% ===== FINAL: 4 metrics, session-means for within-person; capped-trial KW for between-people =====
clear; close all; clc;

% --- Paths & sessions ---
base_dir = '\\nasac-m2.unige.ch\m-huberlab\GHuber\users\Ozge\Data sets\Surgery rec';
sessions = {'patient07','patient09','patient20','patient08','patient19','patient18'};

% --- Sampling / windows ---
fs_eye = 30; fs_an = 1; win_pre = 60; win_post = 180;
t0_eye_idx = win_pre*fs_eye + 1;  t0_an_idx = win_pre*fs_an + 1;

% --- Feature windows ---
peak_search_eye_s = 30;   % pupil peak search window (sec); use Inf for full
peak_search_hr_s  = Inf;  % HR peak search window (sec)
prom_win_s = 5;           % early dynamics window: 0–5 s
N5_eye = round(prom_win_s*fs_eye); 
N5_an  = round(prom_win_s*fs_an);

% --- Storage (trial-level extraction) ---
% Metrics order per trial (m): [t0, t0val, t_peak, peak, t_half, v_half]
% Speed/Prom per trial (sp):  [rise_rate, max_vel_0_5s, prominence_0_5s]
p_metrics = []; h_metrics = [];
p_speedprom = []; h_speedprom = [];
trial_session = {};   % person label per trial (cellstr)

%%===== 1) Extract trial-level features =====
for s = 1:numel(sessions)
    f = fullfile(base_dir, sessions{s}, 'pupil_segments_30BL.mat');
    if ~exist(f,'file'), warning('Missing %s', f); continue; end
    S = load(f);
    if ~isfield(S,'pup_p_30BL') || ~isfield(S,'hr_p_30BL')
        warning('Missing %%Δ fields in %s', f); continue;
    end
    [ntr,~] = size(S.pup_p_30BL);

    for k = 1:ntr
        % ----- PUPIL %Δ -----
        m = nan(1,6); sp = [NaN NaN NaN];
        sig = S.pup_p_30BL(k,:);
        if ~isempty(sig) && any(~isnan(sig)) && t0_eye_idx<=numel(sig) && ~isnan(sig(t0_eye_idx))
            if isfinite(peak_search_eye_s) && peak_search_eye_s>0
                end_idx = min(numel(sig), t0_eye_idx + round(peak_search_eye_s*fs_eye));
            else
                end_idx = numel(sig);
            end
            post = sig(t0_eye_idx:end_idx);
            [pk, pk_idx] = max(post);
            if ~isempty(pk_idx) && ~isnan(pk)
                t0v = sig(t0_eye_idx); tpk = pk_idx-1;
                hv = t0v + 0.5*(pk - t0v);
                rising = post(1:pk_idx);
                hidx = find(rising <= hv, 1, 'last');
                if isempty(hidx), th = NaN; vh = NaN; else, th = hidx-1; vh = post(hidx); end
                m = [0, t0v, tpk, pk, th, vh];
                if tpk>0, sp(1) = (pk - t0v)/(tpk/fs_eye); end
                seg = sig(t0_eye_idx:min(numel(sig), t0_eye_idx+N5_eye));
                if numel(seg)>=3
                    vel = diff(movmean(seg,5,'omitnan'))*fs_eye; 
                    sp(2) = max(vel,[],'omitnan');
                    sp(3) = max(seg,[],'omitnan') - min(seg,[],'omitnan');
                end
            end
        end
        p_metrics    = [p_metrics; m]; 
        p_speedprom  = [p_speedprom; sp]; 
        trial_session{end+1,1}=sessions{s}; %#ok<AGROW>

        % ----- HR %Δ -----
        m = nan(1,6); sp = [NaN NaN NaN];
        sig = S.hr_p_30BL(k,:);
        if ~isempty(sig) && any(~isnan(sig)) && t0_an_idx<=numel(sig) && ~isnan(sig(t0_an_idx))
            if isfinite(peak_search_hr_s) && peak_search_hr_s>0
                end_idx = min(numel(sig), t0_an_idx + round(peak_search_hr_s*fs_an));
            else
                end_idx = numel(sig);
            end
            post = sig(t0_an_idx:end_idx);
            [pk, pk_idx] = max(post);
            if ~isempty(pk_idx) && ~isnan(pk)
                t0v = sig(t0_an_idx); tpk = pk_idx-1;
                hv = t0v + 0.5*(pk - t0v);
                rising = post(1:pk_idx);
                hidx = find(rising <= hv, 1, 'last');
                if isempty(hidx), th = NaN; vh = NaN; else, th = hidx-1; vh = post(hidx); end
                m = [0, t0v, tpk, pk, th, vh];
                if tpk>0, sp(1) = (pk - t0v)/tpk; end
            end
            seg = sig(t0_an_idx:min(numel(sig), t0_an_idx+N5_an));
            if numel(seg)>=3
                vel = diff(movmean(seg,3,'omitnan')); 
                sp(2)=max(vel,[],'omitnan');
                sp(3) = max(seg,[],'omitnan') - min(seg,[],'omitnan');
            end
        end
        h_metrics   = [h_metrics; m]; 
        h_speedprom = [h_speedprom; sp];
    end
end

% ===== 2) Assemble trial-level matrices =====
% Columns: [1=t_to_peak, 2=t_to_50, 3=peak, 4=rise_rate, 5=max_vel_0_5s, 6=prom_0_5s]
xP_trials = [p_metrics(:,3)./fs_eye, p_metrics(:,5)./fs_eye, p_metrics(:,4), p_speedprom(:,1), p_speedprom(:,2), p_speedprom(:,3)];
xH_trials = [h_metrics(:,3),          h_metrics(:,5),          h_metrics(:,4), h_speedprom(:,1), h_speedprom(:,2), h_speedprom(:,3)];

uSess = unique(trial_session,'stable'); 
ns = numel(uSess);

% ===== 3) Session means (per person) for within-person tests & Fig 1 =====
muP_sess = nan(ns,6); muH_sess = nan(ns,6);
for s = 1:ns
    mask = strcmp(trial_session, uSess{s});
    muP_sess(s,:) = mean(xP_trials(mask,:), 1, 'omitnan');
    muH_sess(s,:) = mean(xH_trials(mask,:), 1, 'omitnan');
end

% Keep 4 metrics: [Time to Peak, Max velocity 0–5 s, Prominence 0–5 s, Peak]
labels_all = {'Time to Peak (s)','Time to 50% (s)','Peak (%\Delta)',...
              'Rise rate (%/s)','Max velocity 0–5 s (%/s)','Prominence 0–5 s (%)'};
keep_idx   = [1, 5, 6, 3];     % order: TTP, MaxVel, Prominence, Peak
labels     = labels_all(keep_idx);

P_sess = muP_sess(:, keep_idx);      % pupil session means (ns × 4)
H_sess = muH_sess(:, keep_idx);      % HR    session means (ns × 4)

% Group mean ± SD across people
muP_grp = mean(P_sess, 1, 'omitnan');   sdP_grp = std(P_sess, 0, 1, 'omitnan');
muH_grp = mean(H_sess, 1, 'omitnan');   sdH_grp = std(H_sess, 0, 1, 'omitnan');

% Paired t-tests (within-person: Pupil vs HR)
p_within = nan(1,4);
for i = 1:4
    v = ~isnan(P_sess(:,i)) & ~isnan(H_sess(:,i));
    if any(v), [~,p_within(i)] = ttest(P_sess(v,i), H_sess(v,i)); end
end

% ===== 4) Between-people (Pupil only): cap trials to the lowest valid count per metric =====
rng(1);  % reproducible subsampling
p_kw_balanced = nan(1,4);
capped_vals   = cell(1,4);   % for plotting: capped per-person vectors

for ii = 1:4
    col = keep_idx(ii);
    vals = xP_trials(:, col);
    ok   = ~isnan(vals);
    ppl  = unique(trial_session(ok),'stable');

    % count valid trials per person for THIS metric
    n_by = zeros(numel(ppl),1);
    for p = 1:numel(ppl)
        n_by(p) = sum(ok & strcmp(trial_session, ppl{p}));
    end
    ncap = min(n_by);
    if isempty(ncap) || ncap < 1
        p_kw_balanced(ii) = NaN; 
        capped_vals{ii} = repmat({[]}, ns, 1);
        continue;
    end

    y = []; g = {}; per_person_vals = cell(ns,1);
    for s = 1:ns
        idx = find(ok & strcmp(trial_session, uSess{s}));
        if numel(idx) >= ncap
            idx = idx(randperm(numel(idx), ncap));    % subsample equally
            per_person_vals{s} = vals(idx);
            y   = [y; vals(idx)];                     %#ok<AGROW>
            g   = [g; repmat(uSess(s), ncap, 1)];     %#ok<AGROW>
        else
            per_person_vals{s} = [];
        end
    end
    capped_vals{ii} = per_person_vals;
    p_kw_balanced(ii) = kruskalwallis(y, g, 'off');
end

% ===== 5) Plot A: Within-person lines (Fig 1) =====
figure('Color','w','Name','Fig 1 — Within-person: session means (Pupil vs HR)');
C = lines(ns);
for i = 1:4
    subplot(2,2,i); hold on; box on; grid on
    for s = 1:ns
        plot([1 2],[P_sess(s,i) H_sess(s,i)],'-o',...
             'Color',C(s,:), 'LineWidth',1.4, ...
             'MarkerFaceColor',C(s,:), 'MarkerEdgeColor','k');
    end
    % Group mean ± SD (black squares)
    errorbar(1, muP_grp(i), sdP_grp(i), 'ks', 'MarkerFaceColor','k', 'LineWidth',1.4);
    errorbar(2, muH_grp(i), sdH_grp(i), 'ks', 'MarkerFaceColor','k', 'LineWidth',1.4);
    xlim([0.5 2.5]); xticks([1 2]); xticklabels({'Pupil','HR'}); ylabel(labels{i});
    title(sprintf('%s — paired t-test p=%.3g', labels{i}, p_within(i)));
end
legend(uSess, 'Location','southoutside','NumColumns',min(ns,3));
sgtitle('Fig 1 — Within-person (session means): lines=people, squares=group mean ± SD');



% ===== 7) Print concise summary =====
fprintf('\n==== Summary (session means; mean ± SD across people) ====\n');
for i = 1:4
    fprintf('%d) %s\n', i, labels{i});
    fprintf('   Pupil: %.4g ± %.4g | HR: %.4g ± %.4g\n', muP_grp(i), sdP_grp(i), muH_grp(i), sdH_grp(i));
    fprintf('   Within-person (paired t-test): p=%.3g\n', p_within(i));
    fprintf('   Between-people (Pupil; Kruskal–Wallis on capped trials): p=%.3g\n\n', p_kw_balanced(i));
end

%% ===== 8) Save aggregates =====
% out_file = fullfile(base_dir,'dilation_metrics_30BL_pct_SESSIONMEANS_balancedKW.mat');
% save(out_file, 'uSess','P_sess','H_sess','labels','keep_idx', ...
%                'muP_grp','sdP_grp','muH_grp','sdH_grp', ...
%                'p_within','p_kw_balanced','capped_vals', ...
%                'fs_eye','fs_an','win_pre','win_post','prom_win_s','peak_search_eye_s','peak_search_hr_s');
% fprintf('Saved to %s\n', out_file);

%% ============================================================
% COMPILE EXISTING SOURCE DATA ONLY
% No recomputation
% ============================================================

clearvars -except P_sess H_sess labels muP_grp sdP_grp muH_grp sdH_grp p_within
clc

base_dir = '\\nasac-m2.unige.ch\m-huberlab\GHuber\users\Ozge\Data sets\Surgery rec';

sessions = {'patient07','patient09','patient20', ...
            'patient08','patient19','patient18'};

publicID = {'P01','P02','P03','P04','P05','P06'};


% ------------------------------------------------------------
% 1. EXISTING DILATION-ALIGNED TRACES
% ------------------------------------------------------------

Segments = struct();

for s = 1:numel(sessions)

    f = fullfile(base_dir, sessions{s}, 'pupil_segments_30BL.mat');

    if ~exist(f,'file')
        warning('Missing: %s', f)
        continue
    end

    S = load(f);

    id = publicID{s};

    Segments.(id).pupil_pct = S.pup_p_30BL;
    Segments.(id).hr_pct    = S.hr_p_30BL;
    Segments.(id).bis_pct   = S.bis_p_30BL;
    Segments.(id).bp_pct    = S.bp_p_30BL;

end

% Time axes corresponding to the already-saved arrays
Segments.time_pupil_s  = -60 : 1/30 : 180;
Segments.time_vitals_s = -60 : 1 : 180;


% ------------------------------------------------------------
% 2. EXISTING EXTENDED DATA FIG. 6c METRICS
% ------------------------------------------------------------

Metrics = struct();

Metrics.Session = string(publicID(:));

Metrics.labels = labels;

Metrics.P_sess = P_sess;
Metrics.H_sess = H_sess;

Metrics.muP_grp = muP_grp;
Metrics.sdP_grp = sdP_grp;

Metrics.muH_grp = muH_grp;
Metrics.sdH_grp = sdH_grp;

Metrics.p_within = p_within;


%% ------------------------------------------------------------
% 3. SAVE
% ------------------------------------------------------------

out_file = fullfile('C:\Users\huberlab\Desktop\NBME submission\code\fig6','Fig6_source_data.mat');

save(out_file,'Segments','Metrics');

fprintf('\nSaved:\n%s\n',out_file)



