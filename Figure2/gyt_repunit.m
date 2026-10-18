function mp = gyt_repunit(m,n,dim)
%     mp = gyt_repunit(m,n)
%     mp = gyt_repunit(m,n,dim)
% Repeat 'n' times each elements of 'm' in the dimension 'dim' (default:
% dim=1);

if nargin<3
    if sum(size(m)>1)==1
        dim = find(size(m)>1);
    else
        dim = 1;
    end
end


% Version 1.0 the fastest.

dimsize = size(m);
addDim = numel(dimsize)+1;
dimsize(dim) = dimsize(dim)*n;
changeDim = 1:numel(dimsize);
changeDim = [changeDim([1:dim]),addDim,changeDim([(dim+1):end])];
repDim = ones(1,addDim);
repDim(dim+1) = n;
backSwitchDim = 1:addDim;
backSwitchDim([dim,dim+1]) = [dim+1,dim];

mp = reshape(permute(repmat(permute(m,changeDim),repDim),backSwitchDim),dimsize);



% Version 2.0, more elegant, but slow...

% indexes = repmat({':'},[1,ndims(m)]);
% repind = floor(linspace(1,size(m,dim)+1-1/n,size(m,dim)*n));
% indexes{dim} = repind;
% mp = m(indexes{:});