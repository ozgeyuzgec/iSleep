function stats = gyt_ft_1Dclusterperm(X,pclust,depvar)

Y = permute(cat(1,X{1},X{2}),[1,3,2]);


cfg = [];
cfg.method = 'montecarlo';
if strcmpi(depvar,'yes')
    cfg.statistic        = 'ft_statfun_depsamplesT';
    designmat = [[ones(size(X{1},1),1);ones(size(X{2},1),1)*2],[(1:size(X{1},1))';(1:size(X{1},1))']];
else
    cfg.statistic        = 'ft_statfun_indepsamplesT';
    designmat = [ones(size(X{1},1),1);ones(size(X{2},1),1)*2];
end
cfg.design = designmat';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = pclust;
cfg.clusterstatistic = 'maxsum';
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.025;
cfg.numrandomization = 2000;
cfg.correcttail      = 'alpha';
cfg.uvar     = 2;
cfg.ivar     = 1;

% 
% data1 = [];
% for i=1:100
%   data1.time{i} = tim;
%   data1.trial{i}(1,:) = 1.1*erp + 0.1*randn(size(erp)); % the effect size is specified here
% end
% data1.label = {'Cz'};

% pow = [];
% pow.time = 1:size(Y,4);
% pow.freq = 1:size(Y,3);
% pow.label = {'X'};
% pow.powspctrm = Y;
[stats] = ft_timelockstatistics(cfg,Y);

