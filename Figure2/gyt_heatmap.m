function img = gyt_heatmap(x,y,z,fact)




origspaceX = linspace(x(1),x(end),numel(x)*fact);
origspaceY = linspace(y(1),y(end),numel(y)*fact);

[X,Y] = meshgrid(origspaceX,origspaceY);
[Xq,Yq,Vq] = griddata(x,y,z,X,Y,'cubic');

img = imagesc(origspaceX,origspaceY,Vq);