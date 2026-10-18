function u = repvec(v,n)

if size(v,1)>1
    v = v';
end

u = reshape(repmat(v,[n,1]),[1,numel(v)*n]);