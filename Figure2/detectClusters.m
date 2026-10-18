function clusters = detectClusters(X)


nd = ndims(X);
Xsizes = size(X);

clusters = {};
allIndex = find(X>0);
if ~isempty(allIndex)
    Indexsize = size(allIndex);
    if Indexsize(1)==1 && ~all(Indexsize==1)
        allDims = 1:ndims(Indexsize);
        allDims(find(Indexsize>1)) = 1;
        allDims(1) = find(Indexsize>1);
        allIndex = permute(allIndex,allDims);
        clear('allDims')
    end
    clear('Indexsize')
    if sum(Xsizes>1)==1
        allSubscripts = ones(nd,numel(allIndex));
        allSubscripts(find(Xsizes>1),:) = allIndex;
    else
        [C{1:nd}] = ind2sub(Xsizes, allIndex);
        allSubscripts = cell2mat(C)';
    end
    allIndex = allIndex';

    nClust = 0;
    tempInd = [];
    tempSub = [];
    while ~isempty(allIndex)

        if isempty(tempInd)
            nClust = nClust+1;
            clusters{1,nClust} = [];
            tempInd = allIndex(1);
            tempSub = allSubscripts(:,1);
            allSubscripts = allSubscripts(:,~ismember(allIndex,tempInd));
            allIndex = allIndex(~ismember(allIndex,tempInd));
        end


        newInd = [];
        newSub = [];
        for iTemp = 1:numel(tempInd)
            diffSub = allSubscripts-repmat(tempSub(:,iTemp),1,size(allSubscripts,2));
            goodInd = nansum(abs(diffSub),1)==1; % Fieldtrip Version (no diagonal)
            % goodInd = all(abs(diffSub)<2,1); % Version with diagonal
            newInd = [newInd,allIndex(goodInd)];
            newSub = [newSub,allSubscripts(:,goodInd)];
            allSubscripts = allSubscripts(:,~ismember(allIndex,newInd));
            allIndex = allIndex(~ismember(allIndex,newInd));
        end

        clusters{1,nClust} = [clusters{1,nClust},tempInd];
        tempInd = newInd;
        tempSub = newSub;

        if isempty(allIndex)
            clusters{1,nClust} = [clusters{1,nClust},tempInd];
        end
    end
end
