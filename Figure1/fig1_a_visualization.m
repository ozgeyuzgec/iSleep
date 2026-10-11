%% fig 1 
load('arousal_dur.mat')
load('arousal_start.mat')
load('clean_eye0_with_Ar.mat')
load('clean_eye1_with_Ar.mat')
load('clean_eye_frames0.mat')
load('clean_eye_frames1.mat')
load('clean_signals_with_Ar.mat')
load('clean_states.mat')
load('soL.mat')
load('soR.mat')

signal = clean_eye1_with_Ar(3,:);
signal2 = clean_eye0_with_Ar(3,:);

% Find the indices of non-NaN elements
valid_indices = find(~isnan(signal));

% Interpolate NaN values
interp_indices = 1:numel(signal);
interp_signal = interp1(valid_indices, signal(valid_indices), interp_indices, 'linear');

eye0_filt = lowpass(interp_signal, 1, 60);

%% eeg 
sig = clean_signals_with_Ar(1,:);
sig(isnan(sig)) = 0;

LPcf = 0.1; HPcf = 30; Fs = 500;
[B,A]=butter(2,[LPcf/(Fs/2) HPcf/(Fs/2)]);
% 
f3_filt = filtfilt(B,A,sig); 

%% emg 
emg = clean_signals_with_Ar(12,:);
emg(isnan(emg)) = 0;

LPcf = 10; HPcf = 150; Fs = 500;
[B,A]=butter(2,[LPcf/(Fs/2) HPcf/(Fs/2)]);

emg_filt = filtfilt(B,A,emg); 
emg_filt(abs(emg_filt)>30)=nan;

%% eog
ecg = clean_signals_with_Ar(10,:);
ecg(isnan(ecg)) = 0;
eog = clean_signals_with_Ar(13,:);
eog(isnan(eog)) = 0;

LPcf = 0.1; HPcf = 10; Fs = 500;
[B,A]=butter(2,[LPcf/(Fs/2) HPcf/(Fs/2)]);
 
eog_filt = filtfilt(B,A,eog); 
ecg_filt = filtfilt(B,A,ecg);

%% br

br = clean_signals_with_Ar(9,:);
br(isnan(br)) = 0;

LPcf = 0.05; HPcf = 1; Fs = 500;
[B,A]=butter(2,[LPcf/(Fs/2) HPcf/(Fs/2)]);
br_filt = filtfilt(B,A,br); 
time = 0:1/500:(length(clean_signals_with_Ar)-1)/500;

%%
figure

hold on

Yinf = 1000;
Ysup = -600;

states = clean_states;
for i = 1:size(states, 2)
	idx2 = find(clean_eye_frames0 == i);

    if(states(1, i) == 0)
        h = fill([clean_eye0_with_Ar(4, idx2(1)) clean_eye0_with_Ar(4, idx2(end))...
            clean_eye0_with_Ar(4, idx2(end)) clean_eye0_with_Ar(4, idx2(1))], ...
                    [Ysup Ysup Yinf Yinf], 'k', 'FaceAlpha',0.3, 'LineStyle',"none");
    elseif(states(1, i) == 1)
        h = fill([clean_eye0_with_Ar(4, idx2(1)) clean_eye0_with_Ar(4, idx2(end))...
            clean_eye0_with_Ar(4, idx2(end)) clean_eye0_with_Ar(4, idx2(1))], ...
                    [Ysup Ysup Yinf Yinf], 'r', 'FaceAlpha',0.1, 'LineStyle',"none");  
    elseif(states(1, i) == 2)
        h = fill([clean_eye0_with_Ar(4, idx2(1)) clean_eye0_with_Ar(4, idx2(end))...
            clean_eye0_with_Ar(4, idx2(end)) clean_eye0_with_Ar(4, idx2(1))], ...
                    [Ysup Ysup Yinf Yinf], 'r', 'FaceAlpha',0.3, 'LineStyle',"none");
    elseif(states(1, i) == 3)
        
        h = fill([clean_eye0_with_Ar(4, idx2(1)) clean_eye0_with_Ar(4, idx2(end))...
            clean_eye0_with_Ar(4, idx2(end)) clean_eye0_with_Ar(4, idx2(1))], ...
                    [Ysup Ysup Yinf Yinf], 'r', 'FaceAlpha',0.5, 'LineStyle',"none");        
    elseif(states(1, i) == 5)
        h = fill([clean_eye0_with_Ar(4, idx2(1)) clean_eye0_with_Ar(4, idx2(end))...
            clean_eye0_with_Ar(4, idx2(end)) clean_eye0_with_Ar(4, idx2(1))], ...
                    [Ysup Ysup Yinf Yinf], 'g', 'FaceAlpha',0.3, 'LineStyle',"none");
    end
end

%

Yinf = 1000;
Ysup = -600;
for is = 1:length(arousal_dur)
    h = fill([arousal_start(is) arousal_start(is)+arousal_dur(is)...
            arousal_start(is)+arousal_dur(is) arousal_start(is)], ...
                    [Ysup Ysup Yinf Yinf], 'b', 'FaceAlpha',0.3, 'LineStyle',"none");
end

plot(clean_eye0_with_Ar(4,:),signal2*2.4+710,'r')
plot(clean_eye1_with_Ar(4,:),signal*2+500,'b')
plot(clean_eye0_with_Ar(4,:),soR(1,:)*1.2,'m')
plot(clean_eye0_with_Ar(4,:),soL(1,:)+180,'b')
plot(clean_eye0_with_Ar(4,:),soR(2,:)*1.2,'m')
plot(clean_eye0_with_Ar(4,:),soL(2,:)-50,'b')
plot(time, eog_filt/3,'k')
plot(time, f3_filt/2-200,'k')
plot(time, emg_filt*2-300,'k')
plot(time, ecg_filt/10-400,'k')
plot(time, br_filt/2000-500,'k')

title('24-7')
ylim([Ysup Yinf])
xlim([1650 3300])
xlim([5850 6350])

