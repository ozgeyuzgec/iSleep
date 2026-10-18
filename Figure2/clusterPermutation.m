function [clusters,clustH,clustT,clustP] = clusterPermutation(X,trialDim,pclust,nPerm,clusterSelection)
% Cluster permutation test.
% 
%     [clusters] = clusterPermutation(X)
% Return the clusters that are significant. X is a cell array of one to two
% cells. If X contain only one cell, then the permutation are done by
% multiplying randomly each trial by +1 or -1. If X contain two cells, then
% the permutation are done by shuffling the labels. For a comparison of paired
% conditions, simply create a cell array of one cell containing the matrix
% of Condition1-Condition2.
% 
%     [clusters] = clusterPermutation(X,trialDim)
% The dimension of the trials can be specified in trialDim. (default = 1).
% 
%     [clusters] = clusterPermutation(X,trialDim,pclust)
% Cluster threshold can be specified in pclust. Any value below this
% p-value will be clustered. (default = 0.05)
% 
%     [clusters] = clusterPermutation(X,trialDim,pclust,nPerm)
% Number of permutations to compute. This value will determine the accuracy
% of the distribution of the clusters. However, more permutations means
% longer calculations. (default = 100, robust statistic needs between 1000
% and 10000 permutations. Absolute precision needs 2^n permutations, with n
% the number of trials. (not recommanded : with 16 samples, the number of  
% permutation is already 65536)).
% 
%     [clusters] =
%     clusterPermutation(X,trialDim,pclust,nPerm,clusterSelection)
% 'clusterSelection' determine the way the t-value of the cluster will be
% selected. Type 'Max' so that the cluster t is the maximum t-value of the
% cluster or 'Sum' so that the cluster t is the sum of the t-values of the
% cluster. (default = 'Sum')
% 
%     [clusters,clustH,clustT,clustP] = clusterPermutation(X,...)
% When there are at least two output arguments, then the function return
% all the clusters in 'clusters', their significance 'clustH', their
% t-values 'clustT' and the global p-value of each cluster 'clustP'.

%rng('shuffle')

if nargin<2 || isempty(trialDim)
    trialDim = 1;
end
if nargin<3 || isempty(pclust)
    pclust = 0.05;
end
if nargin<4 || isempty(nPerm)
    nPerm = 100;
end
if nargin<5 || isempty(clusterSelection)
    clusterSelection = 'Sum';
end

if ~iscell(X)
    error('X must be a cell array')
end
if numel(X)>2
    error('Cannot compare more than 2 conditions')
end

if numel(X)==1
    allCond = X{1};
    nd = ndims(allCond);
    permDim = 1:nd;
    permDim([1,trialDim]) = [trialDim,1];
    inDim = size(allCond);
    inDim(setdiff(1:nd,trialDim)) = 1;
    repDim = size(allCond);
    repDim(trialDim) = 1;
    
    if nPerm>(2^size(X{1},trialDim))
        allPossiblePerm = zeros(size(X{1},trialDim),2^size(X{1},trialDim));
        for iPermp=1:size(X{1},trialDim)
            allPossiblePerm(iPermp,:) = repmat(repvec([1,-1],2^size(X{1},trialDim)/2^iPermp),[1,2^(iPermp-1)]);
        end
        allPossiblePerm = allPossiblePerm(:,2:(end-1));
    end
    
elseif numel(X)==2
    allCond = cat(trialDim,X{1},X{2});
    nd = ndims(allCond);
end

fPerm = nPerm;
if nPerm>(2^size(X{1},trialDim))
    fPerm = 2^size(X{1},trialDim)-2;
end
allMaxPClust = zeros(1,fPerm);
allMaxNClust = zeros(1,fPerm);
for iPerm = 1:fPerm
    
    if numel(X)==1
        perms = repmat(randi(2,inDim)*2-3,repDim);
        if nPerm>(2^size(X{1},trialDim))
            perms = repmat(permute(allPossiblePerm(:,iPerm),permDim),repDim);
        end
        
        [h,p,~,stats] = ttest(allCond.*perms,0,'Alpha',pclust,'Tail','both','dim',trialDim);
    elseif numel(X)==2
        currPerm = randperm(size(allCond,trialDim));
        index1 = repmat({':'},1,nd);
        index1{trialDim} = currPerm(1:size(X{1},trialDim));
        index2 = repmat({':'},1,nd);
        index2{trialDim} = currPerm(size(X{1},trialDim)+(1:size(X{2},trialDim)));

        if size(X{1},trialDim)==size(X{2},trialDim)
            [h,p,~,stats] = ttest2(allCond(index1{:}),allCond(index2{:}),'Alpha',pclust,'Tail','both','Vartype','equal','dim',trialDim);
        else
            [h,p,~,stats] = ttest2(allCond(index1{:}),allCond(index2{:}),'Alpha',pclust,'Tail','both','Vartype','unequal','dim',trialDim);
        end
    end
    
    pospClust = detectClusters(squeeze(h.*(stats.tstat>0)));
    pClustT = nan(length(pospClust),1);
    for iClust = 1:length(pospClust)
        if strcmpi(clusterSelection,'Max')
            pClustT(iClust) = nanmax(stats.tstat(pospClust{iClust}));
        elseif strcmpi(clusterSelection,'Sum')
            pClustT(iClust) = nansum(stats.tstat(pospClust{iClust}));
        elseif strcmpi(clusterSelection,'Size')
            pClustT(iClust) = numel(pospClust{iClust});
        end
    end
    
    negpClust = detectClusters(squeeze(h.*(stats.tstat<0)));
    nClustT = nan(length(negpClust),1);
    for iClust = 1:length(negpClust)
        if strcmpi(clusterSelection,'Max')
            nClustT(iClust) = nanmin(stats.tstat(negpClust{iClust}));
        elseif strcmpi(clusterSelection,'Sum')
            nClustT(iClust) = nansum(stats.tstat(negpClust{iClust}));
        elseif strcmpi(clusterSelection,'Size')
            nClustT(iClust) = numel(negpClust{iClust});
        end
    end
    
    clear('pospClust','negpClust');

    if isempty(pClustT)
        allMaxPClust(iPerm) = 0;
    else
        allMaxPClust(iPerm) = nanmax(pClustT);
    end
    
    if isempty(nClustT)
        allMaxNClust(iPerm) = 0;
    else
        allMaxNClust(iPerm) = -nanmax(abs(nClustT));
    end
end

if numel(X)==1
    [h,p,~,stats] = ttest(allCond,0,'Alpha',pclust,'Tail','both','dim',trialDim);
elseif numel(X)==2
    if size(X{1},trialDim)==size(X{2},trialDim)
        [h,p,~,stats] = ttest2(X{1},X{2},'Alpha',pclust,'Tail','both','Vartype','equal','dim',trialDim);
    else
        [h,p,~,stats] = ttest2(X{1},X{2},'Alpha',pclust,'Tail','both','Vartype','unequal','dim',trialDim);
    end
end

posClust = detectClusters(squeeze(h.*(stats.tstat>0)));
pClustT = nan(length(posClust),1);
pClustP = nan(length(posClust),1);
pClustH = nan(length(posClust),1);
for iClust = 1:length(posClust)
    if strcmpi(clusterSelection,'Max')
        pClustT(iClust) = nanmax(stats.tstat(posClust{iClust}));
    elseif strcmpi(clusterSelection,'Sum')
        pClustT(iClust) = nansum(stats.tstat(posClust{iClust}));
    elseif strcmpi(clusterSelection,'Size')
        pClustT(iClust) = numel(posClust{iClust});
    end
    pClustP(iClust) = (nansum(allMaxPClust>pClustT(iClust))/fPerm)*2;
    pClustH(iClust) = pClustP(iClust)<0.05;
end

negClust = detectClusters(squeeze(h.*(stats.tstat<0)));
nClustT = nan(length(negClust),1);
nClustP = nan(length(negClust),1);
nClustH = nan(length(negClust),1);
for iClust = 1:length(negClust)
    if strcmpi(clusterSelection,'Max')
        nClustT(iClust) = nanmin(stats.tstat(negClust{iClust}));
    elseif strcmpi(clusterSelection,'Sum')
        nClustT(iClust) = nansum(stats.tstat(negClust{iClust}));
    elseif strcmpi(clusterSelection,'Size')
        nClustT(iClust) = numel(negClust{iClust});
    end
    nClustP(iClust) = (nansum(allMaxNClust<nClustT(iClust))/fPerm)*2;
    nClustH(iClust) = nClustP(iClust)<0.05;
end

clusters = {posClust{:},negClust{:}};
clustT = [pClustT',nClustT'];
clustH = [pClustH',nClustH'];
clustP = [pClustP',nClustP'];
clustP(clustP>1) = 1;
clear('posClust','negClust');

if nargout<2
    clusters = clusters(clustH==1);
end

end
    
