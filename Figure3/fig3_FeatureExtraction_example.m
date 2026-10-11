
%% Figure 3 — Pupil-derived feature extraction
% iSleep: Continuous binocular pupil tracking
%
% Simplified example illustrating the feature-extraction workflow
% used for pupil-based sleep-stage classification.
%
% This script demonstrates epoch selection, representative feature
% calculations and preparation of a classification dataset.
% It does not include the complete feature set or feature-selection
% procedure used for the reported results.
%
% Input: preprocessed binocular eye-tracking and sleep-stage data.
% Original individual recordings are not included.

clear; clc;

dataDir = './preprocessed_sessions';
outputDir = './output';

if ~exist(outputDir,'dir')
    mkdir(outputDir);
end

%% 1. Recording sessions

% Public-facing session labels.
% Exact recording dates and recording-type descriptors are omitted.
% Labels must correspond to the locally available input folders.

sessions = {
    'pup022_ses5', 'pup022_ses6', ...
    'pup023_ses5', 'pup023_ses6', ...
    'pup024_ses3', 'pup024_ses6', 'pup024_ses7', 'pup024_ses8_2', ...
    'pup030_ses3_2', 'pup030_ses5', 'pup030_ses7', ...
    'pup030_ses8', 'pup030_ses10', ...
    'pup032_ses3', 'pup032_ses5_2', 'pup032_ses6', ...
    'pup035_ses3', 'pup035_ses6', 'pup035_ses6_2', ...
    'pup035_ses8', 'pup035_ses9', ...
    'pup039_ses5', 'pup039_ses9', ...
    'pup044_ses3', 'pup044_ses4', ...
    'pup049_ses3', 'pup049_ses5', ...
    'pup050_ses3', 'pup050_ses3_2', 'pup050_ses4_2', ...
    'pup050_ses5', ...
    'pup060_ses3', 'pup060_ses5', ...
    'pup065_ses3', 'pup065_ses4', ...
    'pup003_ses1', 'pup063_ses3', ...
    'pup042_ses1_2', 'pup042_ses1', ...
    'pup062_ses4', 'pup024_ses9', ...
    'pup032_ses8', ...
    'pup023_ses8', 'pup023_ses7', 'pup023_ses3', ...
    'pup020_ses8', 'pup020_ses7', ...
    'pup011_ses8_3', 'pup011_ses8', 'pup011_ses7', 'pup011_ses6', ...
    'pup010_ses7', 'pup010_ses6', 'pup010_ses5', ...
    'pup003_ses82', 'pup004_ses5', 'pup049_ses4', ...
    'pup004_ses6'
};

% Sampling frequency is specified for each recording.
% Some original sessions were sampled at 60 Hz and others at 30 Hz.
% Use the acquisition metadata where available.

defaultFs = 30;

participantIDs = cellfun(@(s) s(1:6), ...
    sessions, 'UniformOutput', false);

fprintf('Participants: %d\n', numel(unique(participantIDs)));
fprintf('Sessions: %d\n', numel(sessions));

%% 2. Initialize feature dataset

% Eye-tracking channels:
% 1 — Horizontal pupil-center position
% 2 — Vertical pupil-center position
% 3 — Pupil diameter
% 4 — Time

% Sleep-stage coding:
% 0 = Wake, 1 = NREM1, 2 = NREM2, 3 = NREM3, 5 = REM

allFeatures = [];
allLabels = [];
allSessionIDs = {};

%% 3. Process individual sessions

for sessionIdx = 1:numel(sessions)

    sessionName = sessions{sessionIdx};
    sessionDir = fullfile(dataDir, sessionName);

    if ~isfolder(sessionDir)
        fprintf('Input unavailable: %s\n', sessionName);
        continue
    end

    % Load preprocessed data
    R = load(fullfile(sessionDir, 'clean_eye0.mat'));
    L = load(fullfile(sessionDir, 'clean_eye1.mat'));
    S = load(fullfile(sessionDir, 'clean_states.mat'));
    F0 = load(fullfile(sessionDir, 'clean_eye_frames0.mat'));
    F1 = load(fullfile(sessionDir, 'clean_eye_frames1.mat'));

    rightEye = R.clean_eye0;
    leftEye = L.clean_eye1;
    states = S.clean_states(1,:);
    framesRight = F0.clean_eye_frames0;
    framesLeft = F1.clean_eye_frames1;

    % Use the actual sampling frequency for each recording.
    Fs = defaultFs;

    % Combine consecutive epochs having the same sleep-stage label.
    % As in the original script, adjacent 30-s epochs form
    % approximately 60-s analysis windows.

    epochStarts = find(diff(states) == 0);
    epochPairs = [epochStarts; epochStarts + 1];

    sessionFeatures = [];
    sessionLabels = [];

    %% 4. Extract features from valid epochs

    for epochIdx = 1:size(epochPairs,2)

        epochNumbers = epochPairs(:,epochIdx);
        stage = states(epochNumbers(1));

        idxR = find(ismember(framesRight, epochNumbers));
        idxL = find(ismember(framesLeft, epochNumbers));

        if isempty(idxR) || isempty(idxL)
            continue
        end

        eyeR = rightEye(:,idxR);
        eyeL = leftEye(:,idxL);

        validR = all(~isnan(eyeR),1);
        validL = all(~isnan(eyeL),1);

        % Require at least 50% valid samples for each eye.
        if mean(validR) <= 0.5 || mean(validL) <= 0.5
            continue
        end

        eyeR = eyeR(1:3,validR);
        eyeL = eyeL(1:3,validL);

        %% 5. Representative feature calculations

        epochFeatures = [];

        for eyeIdx = 1:2

            if eyeIdx == 1
                eyeData = eyeR;
            else
                eyeData = eyeL;
            end

            % Center spatial position channels
            eyeData(1,:) = eyeData(1,:) - mean(eyeData(1,:));
            eyeData(2,:) = eyeData(2,:) - mean(eyeData(2,:));

            for ch = 1:3

                x = double(eyeData(ch,:));

                % Representative distribution features
                featureMean = mean(x);
                featureStd = std(x);
                featureMedian = median(x);

                % Representative temporal feature
                featureDiff = mean(abs(diff(x)));

                % Representative frequency feature
                featureFreq = meanfreq(x,Fs);

                % Feature categories also used in the study
                % include wavelet and histogram descriptors.
                % The complete feature definitions and ranking
                % procedure are not implemented in this example.

                epochFeatures = [epochFeatures, ...
                    featureMean, featureStd, featureMedian, ...
                    featureDiff, featureFreq];

            end
        end

        sessionFeatures = [sessionFeatures; epochFeatures];
        sessionLabels = [sessionLabels; stage];

    end

    %% 6. Store session-level results

    allFeatures = [allFeatures; sessionFeatures];
    allLabels = [allLabels; sessionLabels];

    allSessionIDs = [allSessionIDs; ...
        repmat({sessionName},size(sessionFeatures,1),1)];

    fprintf('%s: %d valid epochs\n', ...
        sessionName, size(sessionFeatures,1));

end

%% 7. Prepare output

% Each row represents one analysis epoch.
% Columns contain representative binocular pupil-derived features.
% Labels correspond to manually scored sleep stages.

if ~isempty(allFeatures)

    save(fullfile(outputDir,'example_features.mat'), ...
        'allFeatures','allLabels','allSessionIDs');

    featureTable = array2table(allFeatures);
    featureTable.SleepStage = allLabels;
    featureTable.Session = allSessionIDs;

    writetable(featureTable, ...
        fullfile(outputDir,'example_features.csv'));

    fprintf('\nExtracted %d epochs with %d features.\n', ...
        size(allFeatures,1), size(allFeatures,2));

else
    fprintf('No source recordings available for extraction.\n');
end

%% 8. Downstream analysis

% The resulting feature matrix can be used for:
%
% - Feature normalization
% - Feature ranking and selection
% - Dimensionality reduction (e.g., t-SNE)
% - Sleep-stage classification
% - Cross-validation and performance assessment
%
% See Fig3_ML.ipynb for examples of downstream ML analysis.
%
% Note: this example does not reproduce the complete feature set
% or the exact classification performance reported in the manuscript.
