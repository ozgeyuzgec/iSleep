%% movement quantification all sleep (2)

sessions = fileNames; %available on request

rrange = 0.5;
binsize = 60;
count1s = nan(numel(sessions), binsize); % for states
bin1s = nan(numel(sessions), binsize);
p1s = nan(numel(sessions), binsize);
count2s = nan(numel(sessions), binsize);
bin2s = nan(numel(sessions), binsize);
p2s = nan(numel(sessions), binsize);
count3s = nan(numel(sessions), binsize);
bin3s = nan(numel(sessions), binsize);
p3s = nan(numel(sessions), binsize);
count4s = nan(numel(sessions), binsize);
bin4s = nan(numel(sessions), binsize);
p4s = nan(numel(sessions), binsize);
count5s = nan(numel(sessions), binsize);
bin5s = nan(numel(sessions), binsize);
p5s = nan(numel(sessions), binsize);

count11s = nan(numel(sessions), binsize); % for states
bin11s = nan(numel(sessions), binsize);
p11s = nan(numel(sessions), binsize);
count22s = nan(numel(sessions), binsize);
bin22s = nan(numel(sessions), binsize);
p22s = nan(numel(sessions), binsize);
count33s = nan(numel(sessions), binsize);
bin33s = nan(numel(sessions), binsize);
p33s = nan(numel(sessions), binsize);
count44s = nan(numel(sessions), binsize);
bin44s = nan(numel(sessions), binsize);
p44s = nan(numel(sessions), binsize);
count55s = nan(numel(sessions), binsize);
bin55s = nan(numel(sessions), binsize);
p55s = nan(numel(sessions), binsize);

colors = {'k','k','b','b','g','g','r','r','m','m','y','y'};

w_stat = [];n1_stat = [];n2_stat = [];n3_stat = [];r_stat = [];
wy_stat = [];n1y_stat = [];n2y_stat = [];n3y_stat = [];ry_stat = [];

for is = 1: length(sessions)

    load([fileloc sessions{is} '\vel_dif.mat'])
    load([fileloc sessions{is} '\pos_dif.mat'])
    load([fileloc sessions{is} '\gaze.mat'])
    load([fileloc sessions{is} '\vergence.mat'])
    load([fileloc sessions{is} '\clean_states.mat'])
    load([fileloc sessions{is} '\clean_eye_frames0.mat'])
    load([fileloc sessions{is} '\y_left.mat'])
    load([fileloc sessions{is} '\x_right.mat'])
    load([fileloc sessions{is} '\x_left.mat'])
    load([fileloc sessions{is} '\y_right.mat'])    
    load([fileloc sessions{is} '\slope.mat'])

    stage_you_want_to_look_at = 0; %wake
    fW = find(clean_states(1,:) ~= stage_you_want_to_look_at);
    Stage_W = [];
    for i = 1:length(fW)
        cef = find(clean_eye_frames0 == fW(i));
        Stage_W = [Stage_W, find(clean_eye_frames0 == fW(i))];
    end

    stage_you_want_to_look_at = 1; %nrem1
    fW = find(clean_states(1,:) == stage_you_want_to_look_at);
    Stage_n1 = [];
    for i = 1:length(fW)
        cef = find(clean_eye_frames0 == fW(i));
        Stage_n1 = [Stage_n1, find(clean_eye_frames0 == fW(i))];
    end

    stage_you_want_to_look_at = 2; %nrem2
    fW = find(clean_states(1,:) == stage_you_want_to_look_at);
    Stage_n2 = [];
    for i = 1:length(fW)
        cef = find(clean_eye_frames0 == fW(i));
        Stage_n2 = [Stage_n2, find(clean_eye_frames0 == fW(i))];
    end

    stage_you_want_to_look_at = 3; %nrem3
    fW = find(clean_states(1,:) == stage_you_want_to_look_at);
    Stage_n3 = [];
    for i = 1:length(fW)
        cef = find(clean_eye_frames0 == fW(i));
        Stage_n3 = [Stage_n3, find(clean_eye_frames0 == fW(i))];
    end

    stage_you_want_to_look_at = 5; %rem
    fW = find(clean_states(1,:) == stage_you_want_to_look_at);
    Stage_r = [];
    for i = 1:length(fW)
        cef = find(clean_eye_frames0 == fW(i));
        Stage_r = [Stage_r, find(clean_eye_frames0 == fW(i))];
    end

    diff_xx = ((x_right - x_left));
    diff_yy = ((y_right - y_left));
    variab1 = diff_xx;
    variab2 = diff_yy;

    devx = 0.055;
    devy = 0.055;

    xc = find(diff_xx>devx);
    xa = find((diff_xx>=-devx)&(diff_xx<=devx));
    xd = find(diff_xx<-devx);
    yu = find(diff_yy>devy);
    ya = find((diff_yy>=-devy)&(diff_yy<=devy));
    yd = find(diff_yy<-devy);

    [count1,bin1]=hist(variab1(Stage_W),linspace(-rrange,rrange,binsize));
    p1=count1/(nansum(count1));
    count1s(is,:) = count1;
    bin1s(is,:) = bin1;
    p1s(is,:) = p1;

    [count2, bin2]=hist(variab1(Stage_n1),linspace(-rrange,rrange,binsize));
    p2=count2/(nansum(count2));
    count2s(is,:) = count2;
    bin2s(is,:) = bin2;
    p2s(is,:) = p2;
    
    [count3, bin3]=hist(variab1(Stage_n2),linspace(-rrange,rrange,binsize));
    p3=count3/nansum(count3); 
    count3s(is,:) = count3;
    bin3s(is,:) = bin3;
    p3s(is,:) = p3;
    
    [count4, bin4]=hist(variab1(Stage_n3),linspace(-rrange,rrange,binsize));
    p4=count4/(nansum(count4));
    count4s(is,:) = count4;
    bin4s(is,:) = bin4;
    p4s(is,:) = p4;
    
    [count5, bin5]=hist(variab1(Stage_r),linspace(-rrange,rrange,binsize));
    p5=count5/(nansum(count5));
    count5s(is,:) = count5;
    bin5s(is,:) = bin5;
    p5s(is,:) = p5;

    [count1,bin1]=hist(variab2(Stage_W),linspace(-rrange,rrange,binsize));
    p1=count1/(nansum(count1));
    count11s(is,:) = count1;
    bin11s(is,:) = bin1;
    p11s(is,:) = p1;

    [count2, bin2]=hist(variab2(Stage_n1),linspace(-rrange,rrange,binsize));
    p2=count2/(nansum(count2));
    count22s(is,:) = count2;
    bin22s(is,:) = bin2;
    p22s(is,:) = p2;
    
    [count3, bin3]=hist(variab2(Stage_n2),linspace(-rrange,rrange,binsize));
    p3=count3/nansum(count3); 
    count33s(is,:) = count3;
    bin33s(is,:) = bin3;
    p33s(is,:) = p3;
    
    [count4, bin4]=hist(variab2(Stage_n3),linspace(-rrange,rrange,binsize));
    p4=count4/(nansum(count4));
    count44s(is,:) = count4;
    bin44s(is,:) = bin4;
    p44s(is,:) = p4;
    
    [count5, bin5]=hist(variab2(Stage_r),linspace(-rrange,rrange,binsize));
    p5=count5/(nansum(count5));
    count55s(is,:) = count5;
    bin55s(is,:) = bin5;
    p55s(is,:) = p5;


    idnan = sum(~isnan(x_left(Stage_W)) & ~isnan(x_right(Stage_W)));
    w_stat = [w_stat; 100*length(intersect(xd,Stage_W))/idnan...  
        100*length(intersect(xa,Stage_W))/idnan 100*length(intersect(xc,Stage_W))/idnan];
    idnan = sum(~isnan(x_left(Stage_n1)) & ~isnan(x_right(Stage_n1)));
    n1_stat = [n1_stat; 100*length(intersect(xd,Stage_n1))/idnan...
        100*length(intersect(xa,Stage_n1))/idnan 100*length(intersect(xc,Stage_n1))/idnan];
    idnan = sum(~isnan(x_left(Stage_n2)) & ~isnan(x_right(Stage_n2)));
    n2_stat = [n2_stat; 100*length(intersect(xd,Stage_n2))/idnan...
        100*length(intersect(xa,Stage_n2))/idnan 100*length(intersect(xc,Stage_n2))/idnan];
    idnan = sum(~isnan(x_left(Stage_n3)) & ~isnan(x_right(Stage_n3)));
    n3_stat = [n3_stat; 100*length(intersect(xd,Stage_n3))/idnan...
        100*length(intersect(xa,Stage_n3))/idnan 100*length(intersect(xc,Stage_n3))/idnan];
    idnan = sum(~isnan(x_left(Stage_r)) & ~isnan(x_right(Stage_r)));
    r_stat = [r_stat; 100*length(intersect(xd,Stage_r))/idnan...
        100*length(intersect(xa,Stage_r))/idnan 100*length(intersect(xc,Stage_r))/idnan];

    idnan = sum(~isnan(y_left(Stage_W)) & ~isnan(y_right(Stage_W)));
    wy_stat = [wy_stat; 100*length(intersect(yd,Stage_W))/idnan...
        100*length(intersect(ya,Stage_W))/idnan 100*length(intersect(yu,Stage_W))/idnan];
    idnan = sum(~isnan(y_left(Stage_n1)) & ~isnan(y_right(Stage_n1)));
    n1y_stat = [n1y_stat; 100*length(intersect(yd,Stage_n1))/idnan...
        100*length(intersect(ya,Stage_n1))/idnan 100*length(intersect(yu,Stage_n1))/idnan];
    idnan = sum(~isnan(y_left(Stage_n2)) & ~isnan(y_right(Stage_n2)));
    n2y_stat = [n2y_stat; 100*length(intersect(yd,Stage_n2))/idnan...
        100*length(intersect(ya,Stage_n2))/idnan 100*length(intersect(yu,Stage_n2))/idnan];
    idnan = sum(~isnan(y_left(Stage_n3)) & ~isnan(y_right(Stage_n3)));
    n3y_stat = [n3y_stat; 100*length(intersect(yd,Stage_n3))/idnan...
        100*length(intersect(ya,Stage_n3))/idnan 100*length(intersect(yu,Stage_n3))/idnan];
    idnan = sum(~isnan(y_left(Stage_r)) & ~isnan(y_right(Stage_r)));
    ry_stat = [ry_stat; 100*length(intersect(yd,Stage_r))/idnan...
        100*length(intersect(ya,Stage_r))/idnan 100*length(intersect(yu,Stage_r))/idnan];

end

%%
figure('color','w'), hold on
subplot(221), hold on
shadedErrorBar(nanmean(bin1s,1),nanmean(p1s,1),nanstd(p1s,1)/sqrt(is),'k',1)
shadedErrorBar(nanmean(bin2s,1),nanmean(p2s,1),nanstd(p2s,1)/sqrt(is),'b',1)
shadedErrorBar(nanmean(bin3s,1),nanmean(p3s,1),nanstd(p3s,1)/sqrt(is),'y',1)
shadedErrorBar(nanmean(bin4s,1),nanmean(p4s,1),nanstd(p4s,1)/sqrt(is),'m',1)
shadedErrorBar(nanmean(bin5s,1),nanmean(p5s,1),nanstd(p5s,1)/sqrt(is),'g',1)
title([num2str(is) ' sessions 18 participants X movement'])
xlabel('Vergence (px)')
ylabel('Probability')
ylim([0 0.5]), box off
plot([-0.1 -0.1],[0 0.5],'r--')
plot([-0.2 -0.2],[0 0.5],'r--')
plot([0.1 0.1],[0 0.5],'r--')
plot([0.2 0.2],[0 0.5],'r--')
plot([0.3 0.3],[0 0.5],'r--')
plot([-0.3 -0.3],[0 0.5],'r--')
plot([0 0],[0 0.5],'r--')
set(gca,'TickDir','out');
xlim([-0.32 0.32])

subplot(222), hold on
shadedErrorBar(nanmean(bin11s,1),nanmean(p11s,1),nanstd(p11s,1)/sqrt(is),'k',1)
shadedErrorBar(nanmean(bin22s,1),nanmean(p22s,1),nanstd(p22s,1)/sqrt(is),'b',1)
shadedErrorBar(nanmean(bin33s,1),nanmean(p33s,1),nanstd(p33s,1)/sqrt(is),'y',1)
shadedErrorBar(nanmean(bin44s,1),nanmean(p44s,1),nanstd(p44s,1)/sqrt(is),'m',1)
shadedErrorBar(nanmean(bin55s,1),nanmean(p55s,1),nanstd(p55s,1)/sqrt(is),'g',1)
title([num2str(is) ' sessions 18 participants Y movement'])
xlim([-0.32 0.32])
ylim([0 0.5]), box off
plot([-0.1 -0.1],[0 0.5],'r--')
plot([-0.2 -0.2],[0 0.5],'r--')
plot([0.1 0.1],[0 0.5],'r--')
plot([0.2 0.2],[0 0.5],'r--')
plot([0.3 0.3],[0 0.5],'r--')
plot([-0.3 -0.3],[0 0.5],'r--')
plot([0 0],[0 0.5],'r--')
xlabel('Vergence (px)'), box off
set(gca,'TickDir','out');

% position time spent
subplot(223), hold on
bar(1,nanmean(w_stat(:,1)),'r');
errorbar(1,nanmean(w_stat(:,1)),nanstd(w_stat(:,1)),'k','LineWidth',2)
bar(2,nanmean(w_stat(:,2)),'k'); 
errorbar(2,nanmean(w_stat(:,2)),nanstd(w_stat(:,2)),'k','LineWidth',2)
bar(3,nanmean(w_stat(:,3)),'b'); 
errorbar(3,nanmean(w_stat(:,3)),nanstd(w_stat(:,3)),'k','LineWidth',2)
bar(5,nanmean(n1_stat(:,1)),'r'); 
errorbar(5,nanmean(n1_stat(:,1)),nanstd(n1_stat(:,1)),'k','LineWidth',2)
bar(6,nanmean(n1_stat(:,2)),'k'); 
errorbar(6,nanmean(n1_stat(:,2)),nanstd(n1_stat(:,2)),'k','LineWidth',2)
bar(7,nanmean(n1_stat(:,3)),'b'); 
errorbar(7,nanmean(n1_stat(:,3)),nanstd(n1_stat(:,3)),'k','LineWidth',2)
bar(9,nanmean(n2_stat(:,1)),'r'); 
errorbar(9,nanmean(n2_stat(:,1)),nanstd(n2_stat(:,1)),'k','LineWidth',2)
bar(10,nanmean(n2_stat(:,2)),'k'); 
errorbar(10,nanmean(n2_stat(:,2)),nanstd(n2_stat(:,2)),'k','LineWidth',2)
bar(11,nanmean(n2_stat(:,3)),'b');
errorbar(11,nanmean(n2_stat(:,3)),nanstd(n2_stat(:,3)),'k','LineWidth',2)
bar(13,nanmean(n3_stat(:,1)),'r'); 
errorbar(13,nanmean(n3_stat(:,1)),nanstd(n3_stat(:,1)),'k','LineWidth',2)
bar(14,nanmean(n3_stat(:,2)),'k');
errorbar(14,nanmean(n3_stat(:,2)),nanstd(n3_stat(:,2)),'k','LineWidth',2)
bar(15,nanmean(n3_stat(:,3)),'b'); 
errorbar(15,nanmean(n3_stat(:,3)),nanstd(n3_stat(:,3)),'k','LineWidth',2)
bar(17,nanmean(r_stat(:,1)),'r'); 
errorbar(17,nanmean(r_stat(:,1)),nanstd(r_stat(:,1)),'k','LineWidth',2)
bar(18,nanmean(r_stat(:,2)),'k'); 
errorbar(18,nanmean(r_stat(:,2)),nanstd(r_stat(:,2)),'k','LineWidth',2)
bar(19,nanmean(r_stat(:,3)),'b'); 
errorbar(19,nanmean(r_stat(:,3)),nanstd(r_stat(:,3)),'k','LineWidth',2)
xticks([-2 2 6 10 14 18])
xticklabels({'WAKE','Sleep','NREM1','NREM2','NREM3','REM'})

title('x position')
ylabel('Probability')
title('x position')
ylabel('Probability')
text(15,90,'Divergent','Color','red')
text(15,95,'Normal','Color','black')
text(15,100,'Convergent','Color','blue')
ylim([0 100])
xlim([-4 20])

subplot(224), hold on
bar(1,nanmean(wy_stat(:,1)),'r'); 
errorbar(1,nanmean(wy_stat(:,1)),nanstd(wy_stat(:,1)),'k','LineWidth',2)
bar(2,nanmean(wy_stat(:,2)),'k'); 
errorbar(2,nanmean(wy_stat(:,2)),nanstd(wy_stat(:,2)),'k','LineWidth',2)
bar(3,nanmean(wy_stat(:,3)),'b'); 
errorbar(3,nanmean(wy_stat(:,3)),nanstd(wy_stat(:,3)),'k','LineWidth',2)
bar(5,nanmean(n1y_stat(:,1)),'r'); 
errorbar(5,nanmean(n1y_stat(:,1)),nanstd(n1y_stat(:,1)),'k','LineWidth',2)
bar(6,nanmean(n1y_stat(:,2)),'k'); 
errorbar(6,nanmean(n1y_stat(:,2)),nanstd(n1y_stat(:,2)),'k','LineWidth',2)
bar(7,nanmean(n1y_stat(:,3)),'b'); 
errorbar(7,nanmean(n1y_stat(:,3)),nanstd(n1y_stat(:,3)),'k','LineWidth',2)
bar(9,nanmean(n2y_stat(:,1)),'r'); 
errorbar(9,nanmean(n2y_stat(:,1)),nanstd(n2y_stat(:,1)),'k','LineWidth',2)
bar(10,nanmean(n2y_stat(:,2)),'k'); 
errorbar(10,nanmean(n2y_stat(:,2)),nanstd(n2y_stat(:,2)),'k','LineWidth',2)
bar(11,nanmean(n2y_stat(:,3)),'b'); 
errorbar(11,nanmean(n2y_stat(:,3)),nanstd(n2y_stat(:,3)),'k','LineWidth',2)
bar(13,nanmean(n3y_stat(:,1)),'r');
errorbar(13,nanmean(n3y_stat(:,1)),nanstd(n3y_stat(:,1)),'k','LineWidth',2)
bar(14,nanmean(n3y_stat(:,2)),'k'); 
errorbar(14,nanmean(n3y_stat(:,2)),nanstd(n3y_stat(:,2)),'k','LineWidth',2)
bar(15,nanmean(n3y_stat(:,3)),'b');
errorbar(15,nanmean(n3y_stat(:,3)),nanstd(n3y_stat(:,3)),'k','LineWidth',2)
bar(17,nanmean(ry_stat(:,1)),'r'); 
errorbar(17,nanmean(ry_stat(:,1)),nanstd(ry_stat(:,1)),'k','LineWidth',2)
bar(18,nanmean(ry_stat(:,2)),'k'); 
errorbar(18,nanmean(ry_stat(:,2)),nanstd(ry_stat(:,2)),'k','LineWidth',2)
bar(19,nanmean(ry_stat(:,3)),'b'); 
errorbar(19,nanmean(ry_stat(:,3)),nanstd(ry_stat(:,3)),'k','LineWidth',2)
xticks([2 6 10 14 18])
xticklabels({'Sleep','NREM1','NREM2','NREM3','REM'})

title('y position')
ylim([0 100])
xlim([-4 20])

% with underlaying scatter plots

% position time spent - X
subplot(223), hold on

b=bar(1,nanmean(w_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(1,nanmean(w_stat(:,1)),nanstd(w_stat(:,1)),'k','LineWidth',2)
scatter(1 + (rand(size(w_stat(:,1)))-0.5)*0.4, w_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(2,nanmean(w_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(2,nanmean(w_stat(:,2)),nanstd(w_stat(:,2)),'k','LineWidth',2)
scatter(2 + (rand(size(w_stat(:,2)))-0.5)*0.4, w_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(3,nanmean(w_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(3,nanmean(w_stat(:,3)),nanstd(w_stat(:,3)),'k','LineWidth',2)
scatter(3 + (rand(size(w_stat(:,3)))-0.5)*0.4, w_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(5,nanmean(n1_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(5,nanmean(n1_stat(:,1)),nanstd(n1_stat(:,1)),'k','LineWidth',2)
scatter(5 + (rand(size(n1_stat(:,1)))-0.5)*0.4, n1_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(6,nanmean(n1_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(6,nanmean(n1_stat(:,2)),nanstd(n1_stat(:,2)),'k','LineWidth',2)
scatter(6 + (rand(size(n1_stat(:,2)))-0.5)*0.4, n1_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(7,nanmean(n1_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(7,nanmean(n1_stat(:,3)),nanstd(n1_stat(:,3)),'k','LineWidth',2)
scatter(7 + (rand(size(n1_stat(:,3)))-0.5)*0.4, n1_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(9,nanmean(n2_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(9,nanmean(n2_stat(:,1)),nanstd(n2_stat(:,1)),'k','LineWidth',2)
scatter(9 + (rand(size(n2_stat(:,1)))-0.5)*0.4, n2_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(10,nanmean(n2_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(10,nanmean(n2_stat(:,2)),nanstd(n2_stat(:,2)),'k','LineWidth',2)
scatter(10 + (rand(size(n2_stat(:,2)))-0.5)*0.4, n2_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(11,nanmean(n2_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(11,nanmean(n2_stat(:,3)),nanstd(n2_stat(:,3)),'k','LineWidth',2)
scatter(11 + (rand(size(n2_stat(:,3)))-0.5)*0.4, n2_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(13,nanmean(n3_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(13,nanmean(n3_stat(:,1)),nanstd(n3_stat(:,1)),'k','LineWidth',2)
scatter(13 + (rand(size(n3_stat(:,1)))-0.5)*0.4, n3_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(14,nanmean(n3_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(14,nanmean(n3_stat(:,2)),nanstd(n3_stat(:,2)),'k','LineWidth',2)
scatter(14 + (rand(size(n3_stat(:,2)))-0.5)*0.4, n3_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(15,nanmean(n3_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(15,nanmean(n3_stat(:,3)),nanstd(n3_stat(:,3)),'k','LineWidth',2)
scatter(15 + (rand(size(n3_stat(:,3)))-0.5)*0.4, n3_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(17,nanmean(r_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(17,nanmean(r_stat(:,1)),nanstd(r_stat(:,1)),'k','LineWidth',2)
scatter(17 + (rand(size(r_stat(:,1)))-0.5)*0.4, r_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(18,nanmean(r_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(18,nanmean(r_stat(:,2)),nanstd(r_stat(:,2)),'k','LineWidth',2)
scatter(18 + (rand(size(r_stat(:,2)))-0.5)*0.4, r_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(19,nanmean(r_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(19,nanmean(r_stat(:,3)),nanstd(r_stat(:,3)),'k','LineWidth',2)
scatter(19 + (rand(size(r_stat(:,3)))-0.5)*0.4, r_stat(:,3), 16,'k',  'LineWidth',0.5)

xticks([2 6 10 14 18])
xticklabels({'Sleep','NREM1','NREM2','NREM3','REM'})
ylabel('Probability')
ylim([0 100])
xlim([-1 20])
% position time spent - Y
subplot(224), hold on

b=bar(1,nanmean(wy_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(1,nanmean(wy_stat(:,1)),nanstd(wy_stat(:,1)),'k','LineWidth',2)
scatter(1 + (rand(size(wy_stat(:,1)))-0.5)*0.4, wy_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(2,nanmean(wy_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(2,nanmean(wy_stat(:,2)),nanstd(wy_stat(:,2)),'k','LineWidth',2)
scatter(2 + (rand(size(wy_stat(:,2)))-0.5)*0.4, wy_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(3,nanmean(wy_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(3,nanmean(wy_stat(:,3)),nanstd(wy_stat(:,3)),'k','LineWidth',2)
scatter(3 + (rand(size(wy_stat(:,3)))-0.5)*0.4, wy_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(5,nanmean(n1y_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(5,nanmean(n1y_stat(:,1)),nanstd(n1y_stat(:,1)),'k','LineWidth',2)
scatter(5 + (rand(size(n1y_stat(:,1)))-0.5)*0.4, n1y_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(6,nanmean(n1y_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(6,nanmean(n1y_stat(:,2)),nanstd(n1y_stat(:,2)),'k','LineWidth',2)
scatter(6 + (rand(size(n1y_stat(:,2)))-0.5)*0.4, n1y_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(7,nanmean(n1y_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(7,nanmean(n1y_stat(:,3)),nanstd(n1y_stat(:,3)),'k','LineWidth',2)
scatter(7 + (rand(size(n1y_stat(:,3)))-0.5)*0.4, n1y_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(9,nanmean(n2y_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(9,nanmean(n2y_stat(:,1)),nanstd(n2y_stat(:,1)),'k','LineWidth',2)
scatter(9 + (rand(size(n2y_stat(:,1)))-0.5)*0.4, n2y_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(10,nanmean(n2y_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(10,nanmean(n2y_stat(:,2)),nanstd(n2y_stat(:,2)),'k','LineWidth',2)
scatter(10 + (rand(size(n2y_stat(:,2)))-0.5)*0.4, n2y_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(11,nanmean(n2y_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(11,nanmean(n2y_stat(:,3)),nanstd(n2y_stat(:,3)),'k','LineWidth',2)
scatter(11 + (rand(size(n2y_stat(:,3)))-0.5)*0.4, n2y_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(13,nanmean(n3y_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(13,nanmean(n3y_stat(:,1)),nanstd(n3y_stat(:,1)),'k','LineWidth',2)
scatter(13 + (rand(size(n3y_stat(:,1)))-0.5)*0.4, n3y_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(14,nanmean(n3y_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(14,nanmean(n3y_stat(:,2)),nanstd(n3y_stat(:,2)),'k','LineWidth',2)
scatter(14 + (rand(size(n3y_stat(:,2)))-0.5)*0.4, n3y_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(15,nanmean(n3y_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(15,nanmean(n3y_stat(:,3)),nanstd(n3y_stat(:,3)),'k','LineWidth',2)
scatter(15 + (rand(size(n3y_stat(:,3)))-0.5)*0.4, n3y_stat(:,3), 16,'k',  'LineWidth',0.5)

b=bar(17,nanmean(ry_stat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(17,nanmean(ry_stat(:,1)),nanstd(ry_stat(:,1)),'k','LineWidth',2)
scatter(17 + (rand(size(ry_stat(:,1)))-0.5)*0.4, ry_stat(:,1), 16,'k',  'LineWidth',0.5)

b=bar(18,nanmean(ry_stat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(18,nanmean(ry_stat(:,2)),nanstd(ry_stat(:,2)),'k','LineWidth',2)
scatter(18 + (rand(size(ry_stat(:,2)))-0.5)*0.4, ry_stat(:,2), 16,'k',  'LineWidth',0.5)

b=bar(19,nanmean(ry_stat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(19,nanmean(ry_stat(:,3)),nanstd(ry_stat(:,3)),'k','LineWidth',2)
scatter(19 + (rand(size(ry_stat(:,3)))-0.5)*0.4, ry_stat(:,3), 16,'k',  'LineWidth',0.5)

xticks([2 6 10 14 18])
xticklabels({'Sleep','NREM1','NREM2','NREM3','REM'})
ylabel('Probability')
ylim([0 100])
xlim([-1 20])

%% Keep sleep source data before WAKE variables overwrite them

sleep_sessions = sessions;

sleep_binX = {bin1s, bin2s, bin3s, bin4s, bin5s};
sleep_probX = {p1s, p2s, p3s, p4s, p5s};

sleep_binY = {bin11s, bin22s, bin33s, bin44s, bin55s};
sleep_probY = {p11s, p22s, p33s, p44s, p55s};

sleep_Xstat = {w_stat, n1_stat, n2_stat, n3_stat, r_stat};
sleep_Ystat = {wy_stat, n1y_stat, n2y_stat, n3y_stat, ry_stat};


%% WAKE movement quantification

sessions = fileNames; %available on request

rrange = 0.5;
binsize = 60; %2s bins
count1s = nan(numel(sessions), binsize); % for states
bin1s = nan(numel(sessions), binsize);
p1s = nan(numel(sessions), binsize);
count2s = nan(numel(sessions), binsize); % for states
bin2s = nan(numel(sessions), binsize);
p2s = nan(numel(sessions), binsize);
xstat = [];
ystat = [];

for is = 1: length(sessions)

    load([fileloc sessions{is} '\x_left.mat'])
    load([fileloc sessions{is} '\x_right.mat'])
    load([fileloc sessions{is} '\y_left.mat'])
    load([fileloc sessions{is} '\y_right.mat'])
    load([fileloc sessions{is} '\clean_eye0.mat'])

    diff_xx = ((x_right - x_left));
    diff_yy = ((y_right - y_left));
    variab1 = diff_xx;
    variab2 = diff_yy;

    devx = 0.055;
    devy = 0.055;

    xc = find(diff_xx>devx);
    xa = find((diff_xx>=-devx)&(diff_xx<=devx));
    xd = find(diff_xx<-devx);
    yu = find(diff_yy>devy);
    ya = find((diff_yy>=-devy)&(diff_yy<=devy));
    yd = find(diff_yy<-devy);

    [count1,bin1]=hist(variab1,linspace(-rrange,rrange,binsize));
    p1=count1/(nansum(count1));
    count1s(is,:) = count1;
    bin1s(is,:) = bin1;
    p1s(is,:) = p1;

    [count2,bin2]=hist(variab2,linspace(-rrange,rrange,binsize));
    p2=count2/(nansum(count2));
    count2s(is,:) = count2;
    bin2s(is,:) = bin2;
    p2s(is,:) = p2;

    idnan = sum(~isnan(x_left) & ~isnan(x_right));

    xstat = [xstat; 100*length((xd))/idnan, 100*length((xa))/idnan, 100*length((xc))/idnan];
    ystat = [ystat; 100*length((yd))/idnan, 100*length((ya))/idnan, 100*length((yu))/idnan];
ylim([-20 120])

end

%
subplot(221), hold on
shadedErrorBar(nanmean(bin1s,1),nanmean(p1s,1),nanstd(p1s,1)/sqrt(is),'k',1)
xlim([-0.32 0.32])
plot([-0.1 -0.1],[0 0.5],'r--')
plot([-0.2 -0.2],[0 0.5],'r--')
plot([0.1 0.1],[0 0.5],'r--')
plot([0.2 0.2],[0 0.5],'r--')
plot([0.3 0.3],[0 0.5],'r--')
plot([-0.3 -0.3],[0 0.5],'r--')
plot([0 0],[0 0.5],'r--')
xlabel('Horizontal Vergence %')
ylabel('Probability')

subplot(222), hold on
shadedErrorBar(nanmean(bin2s,1),nanmean(p2s,1),nanstd(p2s,1)/sqrt(is),'k',1)
xlim([-0.32 0.32])
plot([-0.1 -0.1],[0 0.5],'r--')
plot([-0.2 -0.2],[0 0.5],'r--')
plot([0.1 0.1],[0 0.5],'r--')
plot([0.2 0.2],[0 0.5],'r--')
plot([0.3 0.3],[0 0.5],'r--')
plot([-0.3 -0.3],[0 0.5],'r--')
plot([0 0],[0 0.5],'r--')
xlabel('Vertical Vergence %')

subplot(223), hold on  % with underlaying dots

b=bar(-3,nanmean(xstat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(-3,nanmean(xstat(:,1)),nanstd(xstat(:,1)),'k','LineWidth',2)
scatter(-3 + (rand(size(xstat(:,1)))-0.5)*0.4, xstat(:,1),  16,'k',...
    'LineWidth',0.5)

b=bar(-2,nanmean(xstat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(-2,nanmean(xstat(:,2)),nanstd(xstat(:,2)),'k','LineWidth',2)
scatter(-2 + (rand(size(xstat(:,2)))-0.5)*0.4, xstat(:,2),  16,'k',...
    'LineWidth',0.5)

b=bar(-1,nanmean(xstat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(-1,nanmean(xstat(:,3)),nanstd(xstat(:,3)),'k','LineWidth',2)
scatter(-1 + (rand(size(xstat(:,3)))-0.5)*0.4, xstat(:,3),  16,'k',...
    'LineWidth',0.5)
xlim([-4 20])

subplot(224), hold on

b=bar(-3,nanmean(ystat(:,1)),'r'); b.FaceAlpha = 0.4;
errorbar(-3,nanmean(ystat(:,1)),nanstd(ystat(:,1)),'k','LineWidth',2)
scatter(-3 + (rand(size(ystat(:,1)))-0.5)*0.4, ystat(:,1),  16,'k',...
    'LineWidth',0.5)

b=bar(-2,nanmean(ystat(:,2)),'k'); b.FaceAlpha = 0.4;
errorbar(-2,nanmean(ystat(:,2)),nanstd(ystat(:,2)),'k','LineWidth',2)
scatter(-2 + (rand(size(ystat(:,2)))-0.5)*0.4, ystat(:,2), 16,'k',...
    'LineWidth',0.5)

b=bar(-1,nanmean(ystat(:,3)),'b'); b.FaceAlpha = 0.4;
errorbar(-1,nanmean(ystat(:,3)),nanstd(ystat(:,3)),'k','LineWidth',2)
scatter(-1 + (rand(size(ystat(:,3)))-0.5)*0.4, ystat(:,3), 16,'k',...
    'LineWidth',0.5)
xlim([-4 20])



%% ============================================================
% FIGURE 5C SOURCE DATA
% ============================================================

wake_sessions = wake_source_names;

% ------------------------------------------------------------
% UPPER PANELS
% One row = one session x one vergence bin
% ------------------------------------------------------------

UpperX = table();
UpperY = table();

sleep_states = {'Sleep','NREM1','NREM2','NREM3','REM'};

for s = 1:5

    for i = 1:length(sleep_source_names)

        nBins = size(sleep_binX{s},2);

        T = table( ...
            repmat(sleep_source_names(i),nBins,1), ...
            repmat(sleep_states(s),nBins,1), ...
            sleep_binX{s}(i,:)', ...
            sleep_probX{s}(i,:)', ...
            'VariableNames',{'Session','State','Vergence','Probability'});

        UpperX = [UpperX; T];


        T = table( ...
            repmat(sleep_source_names(i),nBins,1), ...
            repmat(sleep_states(s),nBins,1), ...
            sleep_binY{s}(i,:)', ...
            sleep_probY{s}(i,:)', ...
            'VariableNames',{'Session','State','Vergence','Probability'});

        UpperY = [UpperY; T];

    end
end


% Add WAKE distributions
for i = 1:length(wake_source_names)

    nBins = size(bin1s,2);

    T = table( ...
        repmat(wake_source_names(i),nBins,1), ...
        repmat({'Wake'},nBins,1), ...
        bin1s(i,:)', ...
        p1s(i,:)', ...
        'VariableNames',{'Session','State','Vergence','Probability'});

    UpperX = [UpperX; T];


    T = table( ...
        repmat(wake_source_names(i),nBins,1), ...
        repmat({'Wake'},nBins,1), ...
        bin2s(i,:)', ...
        p2s(i,:)', ...
        'VariableNames',{'Session','State','Vergence','Probability'});

    UpperY = [UpperY; T];

end

% ------------------------------------------------------------
% LOWER PANELS
% One row = one session
% ------------------------------------------------------------

LowerX = table();
LowerY = table();

for s = 1:5

    X = sleep_Xstat{s};
    Y = sleep_Ystat{s};

    T = table( ...
        sleep_source_names, ...
        repmat(sleep_states(s),length(sleep_source_names),1), ...
        X(:,1),X(:,2),X(:,3), ...
        'VariableNames', ...
        {'Session','State','Divergent','Normal','Convergent'});

    LowerX = [LowerX; T];


    T = table( ...
        sleep_source_names, ...
        repmat(sleep_states(s),length(sleep_source_names),1), ...
        Y(:,1),Y(:,2),Y(:,3), ...
        'VariableNames', ...
        {'Session','State','NegativeY','Normal','PositiveY'});

    LowerY = [LowerY; T];

end


% Add WAKE
T = table( ...
    wake_source_names, ...
    repmat({'Wake'},length(wake_source_names),1), ...
    xstat(:,1),xstat(:,2),xstat(:,3), ...
    'VariableNames', ...
    {'Session','State','Divergent','Normal','Convergent'});

LowerX = [LowerX; T];


T = table( ...
    wake_source_names, ...
    repmat({'Wake'},length(wake_source_names),1), ...
    ystat(:,1),ystat(:,2),ystat(:,3), ...
    'VariableNames', ...
    {'Session','State','NegativeY','Normal','PositiveY'});

LowerY = [LowerY; T];

% ------------------------------------------------------------
% Information about the source data
% ------------------------------------------------------------

Fig5c_info = struct;

Fig5c_info.UpperPanels = ...
    'Probability distributions. Each row is one session and vergence bin.';

Fig5c_info.LowerPanels = ...
    'Percentage of recording time in each vergence category for each session.';

Fig5c_info.AlignmentThreshold = 0.055;

Fig5c_info.UpperError = 'SEM across sessions';
Fig5c_info.LowerError = 'SD across sessions';


% Save one MATLAB source-data file
% save('Fig5c_source_data.mat', ...
%     'UpperX','UpperY','LowerX','LowerY','Fig5c_info');











