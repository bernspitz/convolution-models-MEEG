%% Example wrapper script (tailored to tutorial experiment)

%% Initialize and config
clear all;
fpath=['..' filesep 'analysis' filesep]; %analysis directory
addpath(genpath(['..' filesep 'scripts' filesep])); 
filetag='pil02'; %nametag of SPM datafile 

%% Load continuous EEG file and onsets/events

%% for time-domain analysis:
D=spm_eeg_load([fpath 'afMd' filetag '.mat']); %load EEG file
load(['..' filesep 'scripts' filesep 'stuff' filesep 'myevents.mat']); %load event vectors/matrices

%% for time-frequency (TF) analysis:
% D=spm_eeg_load([fpath 'rtf_afMd' filetag '.mat']); %load EEG (TF) file
% load(['..' filesep 'scripts' filesep 'stuff' filesep 'myevents_TF.mat']); %load event vectors/matrices

%% Wrapper 
% assembles design matrix (pre-convolution), in which each column codes one stimulus type / condition of interest:

%% Simple IR in each modality (collapsed across choices):
condmat=sum(pulsemat,3);
names={'visual';'auditory';'tactile'};

%% 'Choice-predictive signals' (CPS); here collapsed across modalities):
% condmat=squeeze(sum(pulsemat,2));
% names={'Fewer';'More'};

%% Simple IR in each modality (collapsed across choices) and pedal responss (left/right)
% condmat=[sum(pulsemat,3) pedmat];
% names={'visual';'auditory';'tactile';'leftPed';'rightPed'};

%% Here you can shift all onsets in the speficied condition by fixed amount
% %e.g.,for pedal responses, we may wish to look at pre-response activity
SHIFTconds=[]; 
SHIFT=-0.5; 

%% preview design (before convolution)
% plotbit=4000:10000; %samples to plot
% figure; plot(D.time(plotbit), condmat(plotbit,:)); legend(names);

%% optional: parametric modulators (of onset regressors; to modulate 'height' of stick functions)
modcs=[]; %none
pmodnames={}; % names of modulators
ppmod=[]; % (samples x modulator)


%%  general convolution specs
matlabbatch={};
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.D = {[fpath D.fname]}; %specify EEG data file
matlabbatch{1}.spm.meeg.modelling.convmodel.bases.fourier.order = 12; %order of Fourier-Basis (how many sine & cosine functions)
matlabbatch{1}.spm.meeg.modelling.convmodel.timing.timewin = [-300 700];
%matlabbatch{1}.spm.meeg.modelling.convmodel.channels{1}.type = 'EEG'; %all EEG channels (takes long)
matlabbatch{1}.spm.meeg.modelling.convmodel.channels{1}.chan = 'Cz'; %single channel (faster)

%%  script the above sppecified design to the convolution batch (quasi~automatic)
for c = 1:size(condmat,2);
    matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).name = names{c};
    ind=logical(condmat(:,c)); %obtain onset times (in samples) from above loaded D file:
    matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).define.manual.onset = D.time(ind); %onset times (in seconds)
    if ismember(c, SHIFTconds)
        matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).define.manual.onset = D.time(ind)+SHIFT; %shift onsets for pedal responses
    end
    matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).define.manual.duration = 0;
    matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).tmod = 0; % time modulations
    if ismember(c, modcs);   %if additionally parametric modulations of the stimulus ('stick') functions were specified, put them here:
        matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).pmod(1).name = pmodnames{c};
        matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).pmod(1).param = ppmod(ind,c);
        matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).pmod(1).poly = 1;
    else 
        matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).pmod=struct('name', {}, 'param', {}, 'poly', {});
    end
    matlabbatch{1}.spm.meeg.modelling.convmodel.sess.cond(c).orth = 0;
end
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.regress = struct('name', {}, 'val', {});

%% to add continuous (non-convolved) regressors, we can do so here, 
% % e.g. we might include eye-channel activity as a co-variate: 
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.regress(1).name=D.chanlabels{65}; % VEOG
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.regress(1).val=D(65,:,1);
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.regress(2).name=D.chanlabels{66}; % HEOG
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.regress(2).val=D(66,:,1);
% % could also add your own custom convolution here (cf. El convolutor)

%% alternatively, may even add continuous regressors and convolve them with the basis set 
% % e.g. we might try to model the 'IR' of eye-motion (in 'peri-motion' time)
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.convregress (1).name=D.chanlabels{65}; % VEOG
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.convregress (1).val=D(65,:,1);
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.convregress (2).name=D.chanlabels{66}; % HEOG
% matlabbatch{1}.spm.meeg.modelling.convmodel.sess.convregress (2).val=D(66,:,1);

%% unused specs (leave at default value)
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.hpf = 10; %high-pass filter (s)
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.multi = {''};
matlabbatch{1}.spm.meeg.modelling.convmodel.timing.units = 'secs';
matlabbatch{1}.spm.meeg.modelling.convmodel.timing.utime = 1;
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.multi_reg = {''};
matlabbatch{1}.spm.meeg.modelling.convmodel.volt = 1;
matlabbatch{1}.spm.meeg.modelling.convmodel.sess.savereg = 0; % 1: saves non-convolved regressors
matlabbatch{1}.spm.meeg.modelling.convmodel.prefix = 'modC';

save(['..' filesep 'scripts' filesep 'batch_convANYNAME.mat'],'matlabbatch'); % save batch (can be loaded and reviewed in SPM batch editor)

%% don't execute unless you have a powerful computer (and/or much time)
%spm_jobman('serial', matlabbatch);

