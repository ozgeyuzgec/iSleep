function y = gyt_gauss(x,m,s)

if size(x,1)<2
    x = x';
end

if size(m,1)>1
    m = m';
end

if size(s,1)>1
    s = s';
end

y = 1./(repmat(s,[numel(x),1])*sqrt(2*pi)).*exp(-(repmat(x,[1,numel(s)])-repmat(m,[numel(x),1])).^2./(2*repmat(s,[numel(x),1]).^2));
y = y./sum(y);