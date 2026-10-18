function stats = gyt_ft_chantime_clusterperm(X,epos,pclust,depvar)


fakechan = {};
for iChan = 1:size(X{1},2)
    fakechan{iChan} = num2str(iChan);
end

data1 = [];
data1.label = fakechan;
data1.trial = squeeze(mat2cell(permute(X{1},[2,3,1]),size(X{1},2),size(X{1},3),ones(1,size(X{1},1))));
data1.time = repmat({1:size(X{1},3)},[size(X{1},1),1]);

data2 = [];
data2.label = fakechan;
data2.trial = squeeze(mat2cell(permute(X{2},[2,3,1]),size(X{2},2),size(X{2},3),ones(1,size(X{2},1))));
data2.time = repmat({1:size(X{2},3)},[size(X{2},1),1]);

cfg = [];
cfg.keeptrials = 'yes';
timelock1 = ft_timelockanalysis(cfg, data1);
timelock2 = ft_timelockanalysis(cfg, data2);

layout = [];
layout.label = data2.label;
layout.pos = epos;

if size(X{1},2)>1
    cfg = [];
    cfg.method = 'triangulation';
    cfg.channels = layout.label';
    cfg.layout   = layout;
    neighbours = ft_prepare_neighbours(cfg, layout);
end

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
cfg.alpha            = 0.05;
cfg.numrandomization = 2500;
cfg.correcttail      = 'alpha';
cfg.uvar     = 2;
cfg.ivar     = 1;

if size(X{1},2)>1
    cfg.neighbours  = neighbours;
end



[stats] = ft_timelockstatistics(cfg,timelock1,timelock2);

