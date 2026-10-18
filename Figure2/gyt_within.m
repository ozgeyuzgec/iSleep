function ind = gyt_within(u,v)
%     ind = gyt_within(u,v)
% Find indexes of u (vector or matrix) which are within the range of v (two
% scalar input). ind is of the same size than u.

v = [min(v),max(v)];

ind = (u>=v(1))&(u<=v(2));