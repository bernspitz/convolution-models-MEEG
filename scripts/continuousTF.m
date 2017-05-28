%% Initialize and config
clear all;
fpath=['..' filesep 'analysis' filesep];  %analysis directory
filetag='pil02'; %name for imported SPM datafile 

%% Continuous Time-frequency Power 
% depending on your computer, this may take several minutes to hours

D=spm_eeg_load([fpath 'afMd' filetag '.mat']); % input: continuous (non-epoched) data
S = [];
S.D =  [fpath  D.fname];
S.channels = {'EEG'};
S.frequencies = [4:2:30];
S.timewin = [-Inf Inf];
S.method = 'morlet';
S.settings.ncycles = 7;
S.settings.subsample = 4;
S.prefix = '';
Dtf = spm_eeg_tf(S); % output: continuous TF power

% %convert power to amplitude 
% D=spm_eeg_load([fpath 'tf_affM' filetag '.mat']);
S = [];
S.D =  [fpath  Dtf.fname];
S.method='Sqrt'; %square-root transform
Dtf=spm_eeg_tf_rescale(S);
delete([S.D(1:end-3),'mat']); %clean up previous files
delete([S.D(1:end-3),'dat']);

% %convert power to amplitude - alternative procedure 
% Dtf(:,:,:,:)=sqrt(Dtf(:,:,:,:));
% Dtf=save(Dtf);
