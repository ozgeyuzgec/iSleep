%% Extended Data Figure 1d - Post-nap questionnaire analysis
%
% Files required alongside this script:
%   PrePostQts_ses1_post.txt
%   PrePostQts_ses3_post.txt
%   PrePostQts_finalses_post.txt
%
clear; close all; clc;
folder = fileparts(mfilename('fullpath'));

%% Load questionnaire responses
closed = loadPostQ(fullfile(folder,'PrePostQts_ses1_post.txt'),false);
early  = loadPostQ(fullfile(folder,'PrePostQts_ses3_post.txt'),false);
final  = loadPostQ(fullfile(folder,'PrePostQts_finalses_post.txt'),true);

% Keep the original ordinal scores for categorical responses:
% Q1 = slept well: Non=1, Oui=2
% Q2 = tired compared with usual nap: Moins=1, Pareil=2, Plus=3
% Q3 = tired compared with before nap: Moins=1, Pareil=2, Plus=3
% Q4 = eye comfort: Mauvais=1, Acceptable=2, Bien=3, Tres bien=4, Excellent=5
% Q5 = eye humidity: same five-point scale as Q4
choices = { ...
    {'Non','Oui'}, ...
    {'Moins','Pareil','Plus'}, ...
    {'Moins','Pareil','Plus'}, ...
    {'Mauvais','Acceptable','Bien','Très bien','Excellent'}, ...
    {'Mauvais','Acceptable','Bien','Très bien','Excellent'} ...
};
X_closed = scoreAnswers(closed.answers,choices);
X_early  = scoreAnswers(early.answers,choices);
X_final  = scoreAnswers(final.answers,choices);

%% Figure 1d: plot questionnaire response percentages
% Colors: final open-eye = blue, closed-eye = black.
figure('Color','w','Position',[100,100,1200,330]);

subplot(1,3,1);
plotResponseBars(X_final,X_closed,1,[2 1],{'Yes','No'}, ...
    'Did you sleep well?');

subplot(1,3,2);
plotResponseBars(X_final,X_closed,2,[3 2 1],{'More','Same','Less'}, ...
    'Tiredness compared with a usual nap');

subplot(1,3,3);
plotResponseBars(X_final,X_closed,5,[5 4 3 2 1], ...
    {'Excellent','Very good','Good','Acceptable','Not good'}, ...
    'Eye humidity after nap');

%% Paired statistics

[found,earlyRow] = ismember(closed.ids,early.ids);
assert(all(found),'Participant IDs do not match between sessions 1 and 3.');

testQuestions = [1,3,5];
testNames = {'Slept well','Tiredness vs before nap','Eye humidity'};
for i = 1:numel(testQuestions)
    q = testQuestions(i);
    a = X_closed(:,q);
    b = X_early(earlyRow,q);
    valid = isfinite(a) & isfinite(b);
    [p,~,stats] = signrank(a(valid),b(valid),'method','approximate');
    fprintf('%s, ses1 vs ses3: n=%d, z=%.3f, p=%.4f\n', ...
        testNames{i},sum(valid),stats.zval,p);
    if q == 5
        differences = a(valid) - b(valid);
        d = mean(differences)/std(differences); % Original paired effect-size calculation
        fprintf('Eye humidity paired difference d = %.3f\n',d);
    end
end

%% Local helper functions
function Q = loadPostQ(filename,isFinal)
    fid = fopen(filename,'rt','n','windows-1252');
    if fid < 0
        error('Could not open %s', filename);
    end
    c = onCleanup(@() fclose(fid));
    ids = strings(0,1);
    answers = strings(0,5);
    line = fgetl(fid);
    while ischar(line)
        fields = strsplit(line,sprintf('\t'),'CollapseDelimiters',false);
        offset = double(isFinal); 
        if numel(fields) >= 8+offset && ~isempty(strtrim(fields{1}))
            ids(end+1,1) = lower(string(strtrim(fields{1})));
            answers(end+1,:) = string(fields([2 3 4 7 8]+offset));
        end
        line = fgetl(fid);
    end
    assert(numel(unique(ids)) == numel(ids), ...
        'Duplicate participant ID in %s: check the questionnaire file.',filename);
    Q.ids = ids;
    Q.answers = strtrim(answers);
end

function scores = scoreAnswers(answers,choices)
    scores = nan(size(answers));
    for q = 1:numel(choices)
        for r = 1:numel(choices{q})
            scores(answers(:,q)==string(choices{q}{r}),q) = r;
        end
    end
end

function plotResponseBars(X_open,X_closed,question,order,ticklabels,titleText)
    a = X_open(:,question);
    b = X_closed(:,question);
    a = a(isfinite(a));
    b = b(isfinite(b));
    pa = 100*arrayfun(@(v)sum(a==v)/numel(a),order);
    pb = 100*arrayfun(@(v)sum(b==v)/numel(b),order);
    h = bar(1:numel(order),[pa(:),pb(:)],'grouped');
    h(1).FaceColor = [0 0.25 1];
    h(2).FaceColor = [0 0 0];
    set(gca,'XTick',1:numel(order),'XTickLabel',ticklabels);
    ylabel('Percentage'); ylim([0 100]); title(titleText);
    box off;
    legend({'Final open eye','Closed eye'},'Location','best');
end
