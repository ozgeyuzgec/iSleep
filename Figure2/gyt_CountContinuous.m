function y = gyt_CountContinuous(x)

y = x;
for iX=2:numel(x)
    if x(iX)==1
        y(iX) = y(iX-1)+1;
    end
end