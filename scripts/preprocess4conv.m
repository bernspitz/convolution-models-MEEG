%% Initialize and config
clear all;
fpath=['..' filesep 'analysis' filesep];  %analysis directory
filetag='pil02'; %name for imported SPM datafile 

%% Previously...

% % Import to SPM (read as is)
% 
% S = [];
% S.dataset = [fpath '02_xdisc.bdf'];
% S.outfile = filetag;
% D = spm_eeg_convert(S);

% % Downsample (2084 to 128 Hz)
% 
% S = [];
% S.D = [fpath filetag '.mat'];
% S.fsample_new=128;
% S.prefix='d';
% D = spm_eeg_downsample(S)
% delete([S.D(1:end-3),'mat']);
% delete([S.D(1:end-3),'dat']);


%% Montage - Re-reference EEG and EOG channels
D=spm_eeg_load([fpath 'd' filetag '.mat']);
S = [];
S.D = [fpath D.fname];
tra=zeros(66,D.nchannels);
tra(1:64,1:64)=eye(64)-1/64; %average reference of 64 EEG channels:
tra(65,67:68)=[1 -1]; %turn eye channels 67&68 into bipolar VEOG channel (65);
tra(66,65:66)=[1 -1]; %turn eye channels 65&66 into bipolar HEOG channel (66);
% % plot montage transformation matrix
% figure; imagesc(tra); title('montage matrix'); xlabel('old channels'); ylabel('new channels'); colorbar
S.montage.tra=tra;
S.montage.labelnew=[D.chanlabels(1:64) 'VEOG' 'HEOG'];
S.montage.labelorg=D.chanlabels;
S.keepothers=0; 
[D, montage] = spm_eeg_montage(S);
% delete([S.D(1:end-3),'mat']);
% delete([S.D(1:end-3),'dat']);


%% Filter

% Filtering may also be done via convolution modelling
% here we filter mostly to allow for quick and dirty
% (automatic) artefact thresholding 

S = [];
S.D = [fpath D.fname];
S.type = 'butterworth';
S.band = 'high';
S.freq = 0.5;
D = spm_eeg_filter(S);
delete([S.D(1:end-3),'mat']); % remove unused files
delete([S.D(1:end-3),'dat']);

% % plot EOG channels 
% eyesplot=D([65 66],:,:); 
% figure; plot(D.time, eyesplot);

%% Mark Artefacts (quick & dirty)

S = [];
S.D = [fpath D.fname];
S.mode = 'mark';
S.badchanthresh = 0.2;
S.methods.channels = {'all'};
S.methods.fun = 'threshchan';
S.methods.settings.threshold = 80;
S.methods.settings.excwin = 300;
S.append = 0;
D = spm_eeg_artefact(S);
delete([S.D(1:end-3),'mat']);
delete([S.D(1:end-3),'dat']);

D=spm_eeg_load([fpath 'afMd' filetag '.mat']);
D=D.badchannels(D.indchannel('T8'), 1); %set channel T8 to bad
D=save(D);

% % plot artefact marking (cf. SPM manual)
% figure;
% imagesc(D.time, [], badsamples(D, D.indchantype('EEG'), ':', 1));
% colormap grey

