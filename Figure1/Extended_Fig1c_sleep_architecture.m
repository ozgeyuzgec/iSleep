%% Extended Data Figure 1c: Open- vs closed-eye sleep architecture
%
% This script calculates:
%   1. Fraction of the complete scored session in each sleep stage
%   2. Duration of contiguous stage bouts (seconds)
%   3. Fragmentation = number of annotated arousals / minutes scored asleep
%   4. OPTIONAL sleep-onset latency (SOL), using the original PRANA parser
%   5. Wilcoxon rank-sum comparisons between the two conditions
%
% Required folder structure:
%   this_script.m
%   data/
%       <session_name>/clean_states.mat  (variable: clean_states)
%       <session_name>/arousal_dur.mat   (variable: arousal_dur)
%       <session_name>/hpn.*.txt        (only for optional SOL calculation)
%
% REQUIREMENTS: MATLAB Statistics and Machine Learning Toolbox for
% ranksum. If calculating SOL, gyt_readPRANAEventFile.m is also required.
%

clear; close all; clc;

%% Configuration
dataRoot = fullfile(fileparts(mfilename('fullpath')), 'data');
outputRoot = fullfile(fileparts(mfilename('fullpath')), 'EDFig1c_results');
epochSeconds = 30;
stageCodes  = [0 1 2 3 5];
stageLabels = {'Wake', 'NREM1', 'NREM2', 'NREM3', 'REM'};

removeDuplicateClosedSessions = false;

calculateSOL = false;

%% Original session lists from Fig1c.m
open_eye_locs = {'***'};

closed_eye_locs = {'***'};

if removeDuplicateClosedSessions
    closed_eye_locs = unique(closed_eye_locs, 'stable');
end

if ~isfolder(dataRoot)
    error(['Data folder not found: %s\nPlace per-session data folders ' ...
           'inside a sibling folder named "data".'], dataRoot);
end
if ~isfolder(outputRoot)
    mkdir(outputRoot);
end
if calculateSOL && exist('gyt_readPRANAEventFile', 'file') ~= 2
    error('calculateSOL requires gyt_readPRANAEventFile.m on the MATLAB path.');
end

%% Load each session once and compute the three panel-c metrics
openData   = analyzeSessions(open_eye_locs,   'Open',   dataRoot, epochSeconds, stageCodes, calculateSOL);
closedData = analyzeSessions(closed_eye_locs, 'Closed', dataRoot, epochSeconds, stageCodes, calculateSOL);

fprintf('\nSession counts: open=%d, closed=%d\n', ...
    numel(open_eye_locs), numel(closed_eye_locs));
fprintf(['Fraction denominator: ALL epochs in each recording. ' ...
         'Fragmentation denominator: minutes of non-wake epochs.\n']);

%% Export panel-c source data 
sourceData = [openData.summary; closedData.summary];
writetable(sourceData, fullfile(outputRoot, 'EDFig1c_session_metrics.csv'));

boutData = [openData.bouts; closedData.bouts];
writetable(boutData, fullfile(outputRoot, 'EDFig1c_bout_durations.csv'));

%% Extended Data Figure 1c: three panels
blue = [0 0 1];
black = [0 0 0];
figure('Color', 'w', 'Position', [100 100 1300 390]);
tiledlayout(1, 3, 'TileSpacing', 'compact');

% Panel 1: time spent in each stage (% of entire scored session)
nexttile; hold on;
for s = 1:numel(stageCodes)
    xOpen = s - 0.12;
    xClosed = s + 0.12;
    plot(repmat(xOpen, size(openData.fractions,1),1), ...
        openData.fractions(:,s), 'd', 'Color', blue, 'MarkerSize', 4);
    plot(repmat(xClosed, size(closedData.fractions,1),1), ...
        closedData.fractions(:,s), 'd', 'Color', black, 'MarkerSize', 4);
    errorbar(xOpen, mean(openData.fractions(:,s)), ...
        std(openData.fractions(:,s)), 'Color', blue, 'LineStyle', 'none');
    errorbar(xClosed, mean(closedData.fractions(:,s)), ...
        std(closedData.fractions(:,s)), 'Color', black, 'LineStyle', 'none');
end
set(gca, 'XTick', 1:5, 'XTickLabel', stageLabels);
xtickangle(45); xlim([0.5 5.5]);
ylabel('Proportion of session'); title('Time Spent'); box off;

% Panel 2: all uninterrupted bouts for each scored sleep state
nexttile; hold on;
for s = 1:numel(stageCodes)
    vo = openData.boutByStage{s};
    vc = closedData.boutByStage{s};
    if ~isempty(vo)
        plot(repmat(s-0.12, numel(vo), 1), vo, 'd', ...
            'Color', blue, 'MarkerSize', 4);
        errorbar(s-0.12, mean(vo), std(vo), ...
            'Color', blue, 'LineStyle', 'none');
    end
    if ~isempty(vc)
        plot(repmat(s+0.12, numel(vc), 1), vc, 'd', ...
            'Color', black, 'MarkerSize', 4);
        errorbar(s+0.12, mean(vc), std(vc), ...
            'Color', black, 'LineStyle', 'none');
    end
end
set(gca, 'XTick', 1:5, 'XTickLabel', stageLabels);
xtickangle(45); xlim([0.5 5.5]);
ylabel('Time (s)'); title('Bout Duration'); box off;

% Panel 3: session-level arousals per minute of scored sleep
nexttile; hold on;
validOpen   = openData.fragmentation(isfinite(openData.fragmentation));
validClosed = closedData.fragmentation(isfinite(closedData.fragmentation));
if ~isempty(validOpen) && ~isempty(validClosed)
    boxplot([validOpen; validClosed], ...
        [repmat({'Open'},numel(validOpen),1); ...
         repmat({'Closed'},numel(validClosed),1)], ...
        'Symbol', '', 'Widths', 0.45);
end
ylabel('Arousals / sleep duration (min)');
title('Fragmentation'); box off;

saveas(gcf, fullfile(outputRoot, 'EDFig1c_sleep_architecture.png'));

%% Statistical comparisons (original rank-sum approach)
fprintf('\nTime spent in each stage: Wilcoxon rank-sum\n');
for s = 1:numel(stageCodes)
    printRankSum(openData.fractions(:,s), closedData.fractions(:,s), stageLabels{s});
end

fprintf('\nCombined NREM2 + NREM3 fraction: Wilcoxon rank-sum\n');
printRankSum(sum(openData.fractions(:,3:4),2), ...
             sum(closedData.fractions(:,3:4),2), 'NREM2 + NREM3');

fprintf('\nBout durations: pooled bouts, Wilcoxon rank-sum\n');
for s = 1:numel(stageCodes)
    printRankSum(openData.boutByStage{s}, closedData.boutByStage{s}, stageLabels{s});
end

fprintf('\nFragmentation: session-level Wilcoxon rank-sum\n');
printRankSum(validOpen, validClosed, 'Arousals per minute asleep');

%% OPTIONAL: sleep-onset latency from the ORIGINAL PRANA scoring files
% The original Fig1_sleepquality.m used the position of the first sleep
% stage in PRANA's X{2} array, multiplied by 30/60 to obtain minutes.
% This is retained to facilitate comparison with manuscript SOL values.
% It is NOT calculated from the post-nap questionnaires.
if calculateSOL
    fprintf('\nSleep-onset latency (min) from PRANA scoring\n');
    oo = openData.solMinutes(isfinite(openData.solMinutes));
    cc = closedData.solMinutes(isfinite(closedData.solMinutes));
    if ~isempty(oo) && ~isempty(cc)
        fprintf('Open mean +/- SD: %.2f +/- %.2f (n=%d)\n',mean(oo),std(oo),numel(oo));
        fprintf('Closed mean +/- SD: %.2f +/- %.2f (n=%d)\n',mean(cc),std(cc),numel(cc));
        printRankSum(oo,cc,'SOL (minutes)');
    else
        warning('SOL data incomplete: inspect PRANA event files.');
    end
end

fprintf('\nSource data and plot saved in: %s\n', outputRoot);

%% Local helper functions
function results = analyzeSessions(sessionNames, condition, dataRoot, epochSeconds, stageCodes, calculateSOL)
    n = numel(sessionNames);
    nStates = numel(stageCodes);
    fractions = nan(n, nStates);
    fragmentation = nan(n,1);
    solMinutes = nan(n,1);
    boutByStage = cell(1,nStates);
    for s = 1:nStates
        boutByStage{s} = zeros(0,1);
    end

    boutCondition = cell(0,1);
    boutSessionIndex = zeros(0,1);
    boutStage = cell(0,1);
    boutSeconds = zeros(0,1);
    stageLabels = {'Wake','NREM1','NREM2','NREM3','REM'};

    for i = 1:n
        sessionFolder = fullfile(dataRoot, sessionNames{i});
        statesFile = fullfile(sessionFolder, 'clean_states.mat');
        arousalFile = fullfile(sessionFolder, 'arousal_dur.mat');
        if ~isfile(statesFile) || ~isfile(arousalFile)
            error(['Missing source file(s) for %s.\nExpected:\n%s\n%s'], ...
                sessionNames{i}, statesFile, arousalFile);
        end

        S = load(statesFile, 'clean_states');
        A = load(arousalFile, 'arousal_dur');
        states = S.clean_states(1,:);
        if isempty(states)
            error('Empty clean_states in %s.', statesFile);
        end

        % (a) Stage fractions; denominator includes Wake
        for s = 1:nStates
            fractions(i,s) = sum(states == stageCodes(s)) / numel(states);

            % (b) Consecutive 30-s scored epochs in the same stage.
            inStage = (states == stageCodes(s));
            transitions = diff([false, inStage, false]);
            starts = find(transitions == 1);
            stops = find(transitions == -1);
            seconds = (stops - starts)' * epochSeconds;
            seconds = seconds(:);

            boutByStage{s} = [boutByStage{s}; seconds]; 
            nBout = numel(seconds);
            boutCondition = [boutCondition; repmat({condition},nBout,1)]; 
            boutSessionIndex = [boutSessionIndex; repmat(i,nBout,1)]; 
            boutStage = [boutStage; repmat(stageLabels(s),nBout,1)]; 
            boutSeconds = [boutSeconds; seconds]; 
        end

        % (c) Arousal count / minutes of non-Wake epochs; preserves the
        % calculation in Fig1c.m. It assumes all nonzero states are sleep.
        sleepMinutes = sum(states ~= 0) * epochSeconds / 60;
        if sleepMinutes > 0
            fragmentation(i) = length(A.arousal_dur) / sleepMinutes;
        end

        % (d) Optional sleep onset from original PRANA exports.
        if calculateSOL
            eventFiles = dir(fullfile(sessionFolder, 'hpn.*.txt'));
            if ~isempty(eventFiles)
                [X,~] = gyt_readPRANAEventFile( ...
                    fullfile(sessionFolder,eventFiles(1).name),0);
                firstSleepIndex = find(ismember(X{2},[1,2,3,5]),1,'first');
                if ~isempty(firstSleepIndex)
                    solMinutes(i) = firstSleepIndex * epochSeconds / 60;
                end
            else
                warning('No hpn.*.txt for SOL in %s.',sessionNames{i});
            end
        end
        fprintf('%s %2d/%2d: %s\n',condition,i,n,sessionNames{i});
    end

    conditionColumn = repmat({condition},n,1);
    sessionIndex = (1:n)';
    T = table(conditionColumn, sessionIndex, ...
        fractions(:,1),fractions(:,2),fractions(:,3),fractions(:,4),fractions(:,5), ...
        fragmentation,solMinutes, ...
        'VariableNames', {'Condition','SessionIndex','WakeFraction','NREM1Fraction', ...
        'NREM2Fraction','NREM3Fraction','REMFraction','ArousalsPerSleepMinute','SOL_Min'});

    results.summary = T;
    results.fractions = fractions;
    results.fragmentation = fragmentation;
    results.solMinutes = solMinutes;
    results.boutByStage = boutByStage;
    results.bouts = table(boutCondition,boutSessionIndex,boutStage,boutSeconds, ...
        'VariableNames',{'Condition','SessionIndex','Stage','BoutDuration_s'});
end

function printRankSum(x,y,description)
    x = x(isfinite(x));
    y = y(isfinite(y));
    if isempty(x) || isempty(y)
        fprintf('%s: insufficient data\n',description);
        return;
    end
    [p,~,stats] = ranksum(x,y);
    pooledSD = sqrt(((numel(x)-1)*var(x) + (numel(y)-1)*var(y)) / ...
                    (numel(x)+numel(y)-2));
    if pooledSD > 0
        d = (mean(x)-mean(y))/pooledSD;
    else
        d = NaN;
    end
    fprintf('%s: open %.3f +/- %.3f; closed %.3f +/- %.3f; d=%.3f\n', ...
        description,mean(x),std(x),mean(y),std(y),d);
    if isfield(stats,'zval')
        fprintf('%s: open n=%d, closed n=%d, z=%.3f, p=%.4g\n', ...
            description,numel(x),numel(y),stats.zval,p);
    else
        fprintf('%s: open n=%d, closed n=%d, p=%.4g\n', ...
            description,numel(x),numel(y),p);
    end
end
