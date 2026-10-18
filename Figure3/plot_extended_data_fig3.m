%% Sleep-staging performance: 30 s vs 60 s epochs (per-session boxes + general model)
% Data: session_scores.csv (one row per session and window length) and general_model_scores.csv

clear; close all;

here = fileparts(mfilename('fullpath'));
T = readtable(fullfile(here, 'session_scores.csv'));        % per-session scores
G = readtable(fullfile(here, 'general_model_scores.csv'));  % general model

metrics = {'f1_score', 'cohens_kappa', 'precision', 'sensitivity', ...
           'specificity', 'balanced_accuracy'};

s30 = T{T.epoch_s == 30, metrics};
s60 = T{T.epoch_s == 60, metrics};
g30 = G{G.epoch_s == 30, metrics};
g60 = G{G.epoch_s == 60, metrics};

excludePerfect = true;
if excludePerfect
    s30(s30 >= 1) = NaN;
    s60(s60 >= 1) = NaN;
end

labels = {'f1-score', 'cohen''s kappa', 'Precision', 'Sensitivity', ...
          'Specificity', 'Balanced Accuracy'};

% ---------- style ----------
c30   = [0.000 0.447 0.741];   % blue
c60   = [0.850 0.325 0.098];   % orange-red
cG60  = [0.850 0.150 0.150];   % general model 60 s (red)
cG30  = [0.150 0.250 0.700];   % general model 30 s (blue)
off   = 0.18;                  % box offset from category centre
bw    = 0.30;                  % box width
lw    = 1.6;                   % box line width
nCat  = numel(labels);

figure('Color', 'w', 'Units', 'centimeters', 'Position', [2 2 14 13]);
ax = axes; hold(ax, 'on');

h30 = []; h60 = [];
for k = 1:nCat
    h30 = drawBox(ax, k - off, s30(:, k), bw, c30, [1 1 1], lw);
    h60 = drawBox(ax, k + off, s60(:, k), bw, c60, c60 + 0.85*(1 - c60), lw);  % light tint
end

% ---------- axes (limits first: dash lengths are computed on screen) ----------
set(ax, 'XLim', [0.5 nCat + 0.5], 'YLim', [0 1], ...
        'XTick', 1:nCat, 'XTickLabel', labels, 'XTickLabelRotation', 30, ...
        'YTick', 0:0.1:1, 'Box', 'off', 'TickDir', 'out', ...
        'FontName', 'Arial', 'FontSize', 12, 'LineWidth', 1);
ylabel(ax, 'Score (%)');

% ---------- general model lines (long dashes) ----------
dashLen = 0.045;   % dash length, as a fraction of the axes width
gapLen  = 0.020;   % gap length,  as a fraction of the axes width
hg60 = longDash(ax, (1:nCat) + off, g60, cG60, 1, dashLen, gapLen);   % through the 60 s box centres
hg30 = longDash(ax, (1:nCat) - off, g30, cG30, 1, dashLen, gapLen);   % through the 30 s box centres

legend(ax, [h30 h60 hg60 hg30], ...
       {'30 sec', '60 sec', '60 sec general model', '30 sec general model'}, ...
       'Location', 'southeast', 'Box', 'off', 'FontSize', 11);

%% ======================= local functions =======================
function hBox = drawBox(ax, x, y, w, edgeCol, faceCol, lw)
    y = y(~isnan(y));
    q  = mprctile(y, [25 50 75]);
    iq = q(3) - q(1);
    lo = min(y(y >= q(1) - 1.5*iq));          % whisker ends = most extreme
    hi = max(y(y <= q(3) + 1.5*iq));          % points inside 1.5*IQR

    plot(ax, [x x], [hi q(3)], 'k-', 'LineWidth', lw);   % upper whisker
    plot(ax, [x x], [q(1) lo], 'k-', 'LineWidth', lw);   % lower whisker
    cw = w/4;                                             % whisker cap half-width
    plot(ax, x + cw*[-1 1], [hi hi], 'k-', 'LineWidth', lw);   % upper cap
    plot(ax, x + cw*[-1 1], [lo lo], 'k-', 'LineWidth', lw);   % lower cap
    hBox = patch(ax, x + w/2*[-1 1 1 -1], [q(1) q(1) q(3) q(3)], faceCol, ...
                 'EdgeColor', edgeCol, 'LineWidth', lw);
    plot(ax, x + w/2*[-1 1], [q(2) q(2)], '-', 'Color', edgeCol, 'LineWidth', lw);
end

function p = mprctile(y, pct)
    % same definition as MATLAB prctile / boxplot (no Statistics Toolbox needed)
    y = sort(y(:)); n = numel(y);
    pos = [0; 100*((1:n)' - 0.5)/n; 100];
    val = [y(1); y; y(n)];
    p = interp1(pos, val, pct);
end

function h = longDash(ax, x, y, col, lw, dash, gap)
    % dashed line with adjustable dash/gap length (MATLAB's '--' is fixed)
    pos = getpixelposition(ax); xl = xlim(ax); yl = ylim(ax);
    X = (x - xl(1))/diff(xl)*pos(3);  Y = (y - yl(1))/diff(yl)*pos(4);
    d = [0 cumsum(hypot(diff(X), diff(Y)))];          % arc length in pixels
    dpx = dash*pos(3);  gpx = gap*pos(3);
    xs = []; ys = [];
    for s = 0:(dpx + gpx):d(end)
        e = min(s + dpx, d(end));
        t = [s, d(d > s & d < e), e];                 % keep corners inside a dash
        xs = [xs, interp1(d, x, t), NaN];              
        ys = [ys, interp1(d, y, t), NaN];              
    end
    h = plot(ax, xs, ys, '-', 'Color', col, 'LineWidth', lw);
end
