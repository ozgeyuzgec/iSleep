function stats = gyt_ft_TFRclusterperm(X,pclust,depvar,nperm)

if nargin<4
    nperm = 500;
end

Y = permute(cat(1,X{1},X{2}),[1,4,2,3]);


cfg = [];
cfg.method = 'montecarlo';
if strcmpi(depvar,'yes')
    cfg.statistic        = 'ft_statfun_depsamplesT';
    designmat = [[ones(size(X{1},1),1);ones(size(X{2},1),1)*2],[(1:size(X{1},1))';(1:size(X{1},1))']];
    cfg.uvar     = 2;
    cfg.ivar     = 1;
else
    cfg.statistic        = 'ft_statfun_indepsamplesT';
    designmat = [ones(size(X{1},1),1);ones(size(X{2},1),1)*2];
    cfg.ivar     = 1;
end
cfg.design = designmat';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = pclust;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
% cfg.alpha            = 0.025;
cfg.numrandomization = nperm;
cfg.correcttail      = 'alpha';
% cfg.dimord = 'subj_chan_freq_time';
pow = [];
pow.time = 1:size(Y,4);
pow.freq = 1:size(Y,3);
pow.label = {'X'};
pow.powspctrm = Y;
[stats] = ft_freqstatistics(cfg,pow);

