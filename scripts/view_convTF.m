%% Initialize and config
clear all;
fpath=['..' filesep 'results' filesep 'convTF' filesep]; %results subdirectory
addpath(genpath(['..' filesep 'scripts' filesep])); 
filetag='pil02'; %nametag of SPM datafile 
%%
D=spm_eeg_load([fpath 'Crtf_afMd' filetag '.mat']);

contrasts=[1 -0.5 -0.5 0 0]; name='visual vs other';
% contrasts=[-0.5 1 -0.5 0 0]; name='auditory vs other';
% contrasts=[-0.5 -0.5 1 0 0]; name='tactile vs other';
% contrasts=[0 0 0 -1 1]; name='Pedal (right-left) shifted -0.5s';


%% FT-based viewer
dat=D(:,:,:,:); 
dat=squeeze(dat);
ncontrasts=size(contrasts,1)
condat=zeros(D.nchannels,D.nfrequencies,D.nsamples,ncontrasts);
for c=1:ncontrasts
    disp(['computing contrast... ' num2str(c)])
    con=[];
    con(1,1,1,:,1)=contrasts(c,:);
    con=repmat(con,[size(dat(:,:,:,1))]); 
    con=con.*dat;
    condat(:,:,:,c)=sum(con,4);
end

dat=[];
dat.powspctrm=condat(:,:,:,1);
dat.time=D.time;
dat.freq=D.frequencies;
dat.label=D.chanlabels(1:64);
[X,Y]=getcoords(dat.label');
dat.dimord='chan_freq_time';
cfg.layout='ordered';
lay = ft_prepare_layout(cfg, dat);
[X,Y]=getcoords(D.chanlabels(1:64)');
lay.pos(1:64,:)=[X;Y]';
scaler=0.6; %workaround for a nicely scaled topoplot
lay.pos(1:length(D.chanlabels(1:64)),:)=[X;Y]'.*scaler;
lay.width=lay.width*scaler;
lay.height=lay.height*scaler;
cfg.layout= lay;
cfg.interactive='yes';
cfg.showlabels    = 'no';
%cfg.colormap='jet';
cfg.style='straight';
figure;
ft_multiplotTFR(cfg, dat); title(name);

    
