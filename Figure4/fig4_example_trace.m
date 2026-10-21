    win = 5; Fs = 500;
    t1 = 0;
    t2 = 9;

    figure('color','w'), hold
    plot(eeg_time_syn, drug_eye_source,'b'); % left
    plot(eeg_time_syn, cnt_eye_source,'r'); % right

    for k = 2:length(c1T_syn) % DRUG
        tt = eeg_time_syn(c1T_syn(k));
        plot([tt tt], [t1 t2],'--k')
    end
 
    for k = 2:length(c2T_syn) % CONTROL
        tt = eeg_time_syn(c2T_syn(k));
        plot([tt tt], [t1 t2],'--m')
    end
    xlabel('Time (s)')