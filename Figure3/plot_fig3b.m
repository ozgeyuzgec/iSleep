%% Fig. 3b: 3-D t-SNE of the 60-s window pupil features, coloured by AASM-scored sleep stage
% Data: fig3b_tsne.csv (three t-SNE dimensions of each window and its stage)

here = fileparts(mfilename('fullpath'));
T = readtable(fullfile(here, 'fig3b_tsne.csv'), 'TextType', 'string');

names  = {'Wake', 'NREM1', 'NREM2', 'NREM3', 'REM'};
colors = {[0.4940 0.1840 0.5560], [0 0.4470 0.7410], [1 0.6471 0], [0.4660 0.6740 0.1880], [1 0 0]};
fig = figure('Color', 'w', 'Position', [100 100 880 660]);
ax = axes(fig); hold(ax, 'all');
for k = 1:numel(names)
    m = T.stage == names{k};
    h(k) = scatter3(ax, T.tsne_1(m), T.tsne_2(m), T.tsne_3(m), 15, colors{k}, 'filled');
end
view(ax, -33, 22);
grid(ax, 'on');
legend(ax, h, names);

exportgraphics(fig, fullfile(here, 'fig3b.png'), 'Resolution', 300);
exportgraphics(fig, fullfile(here, 'fig3b.pdf'), 'ContentType', 'image', 'Resolution', 300);   % vector export of a 3-D scatter is very slow
