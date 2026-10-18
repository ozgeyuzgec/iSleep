function [statline,msg] = pup_getlinestats(x,dat,stats)

statline = nan(1,numel(stats.mask));
statline(squeeze(stats.mask)==1) = 1;

noclus = 0;
if (isfield(stats,'posclusters')&~isempty(stats.posclusters)) & (isfield(stats,'negclusters')&~isempty(stats.negclusters))
    clusts = [[stats.posclusters],[stats.negclusters]];
    clusmap = nan(numel(clusts),numel(statline));
    for iC = 1:max(stats.posclusterslabelmat)
        clusmap(iC,:) = stats.posclusterslabelmat==iC;
    end
    for iC = 1:max(stats.negclusterslabelmat)
        clusmap(iC+numel(stats.posclusters),:) = stats.negclusterslabelmat==iC;
    end
elseif (isfield(stats,'posclusters')&~isempty(stats.posclusters))
    clusts = stats.posclusters;
    clusmap = nan(numel(clusts),numel(statline));
    for iC = 1:max(stats.posclusterslabelmat)
        clusmap(iC,:) = stats.posclusterslabelmat==iC;
    end
elseif (isfield(stats,'negclusters')&~isempty(stats.negclusters))
    clusts = stats.negclusters;
    clusmap = nan(numel(clusts),numel(statline));
    for iC = 1:max(stats.negclusterslabelmat)
        clusmap(iC,:) = stats.negclusterslabelmat==iC;
    end
else
    msg = 'No cluster at all';
    noclus = 1;
end
    
if noclus==0
    fclusts = clusts([clusts.prob]<0.025);
    fclusmap = clusmap([clusts.prob]<0.025,:);
    if ~isempty(fclusts)
        msg = 'Significant cluster(s):\n';
        for iClus = 1:numel(fclusts)
            tp = find(fclusmap(iClus,:)==1);
            tmpdat = nanmean(dat(:,tp),2);
            timeext = [x(tp(1)),x(tp(end)),x(tp(end))-x(tp(1))];
            df = sum(~isnan(tmpdat))-1;
            m = nanmean(tmpdat);
            s = nanstd(tmpdat);
            sem = nanstd(tmpdat)./sqrt(df+1);
            ci = [m-2*sem,m+2*sem];
            p = fclusts(iClus).prob;
            tclus = fclusts(iClus).clusterstat;
            d = m/s;
            msg = [msg,sprintf('Time-extent: %0.03f-%0.03f (%0.03f)\\tm+/-SD: %0.03e+/-%0.03e\\tci=[%0.03e,%0.03e]\\tt(%0.f)=%0.03f\\tp=%0.03f\\td=%0.02f\\n',timeext,m,s,ci,df,tclus,p,d)];
        end
    else
        [~,I] = min([clusts.prob]);
        tp = find(clusmap(I,:)==1);
        tmpdat = nanmean(dat(:,tp),2);
        timeext = [x(tp(1)),x(tp(end)),x(tp(end))-x(tp(1))];
        df = sum(~isnan(tmpdat))-1;
        m = nanmean(tmpdat);
        s = nanstd(tmpdat);
        sem = nanstd(tmpdat)./sqrt(df+1);
        ci = [m-2*sem,m+2*sem];
        p = clusts(I).prob;
        tclus = clusts(I).clusterstat;
        d = m/s;
        msg = 'No significant cluster. Strongest cluster:\n';
        msg = [msg,sprintf('Time-extent: %0.03f-%0.03f (%0.03f)\\tm+/-SD: %0.03e+/-%0.03e\\tci=[%0.03e,%0.03e]\\tt(%0.f)=%0.03f\\tp=%0.03f\\td=%0.02f\\n',timeext,m,s,ci,df,tclus,p,d)];
    end
end
    

