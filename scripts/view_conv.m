%% Initialize and config
clear all;
fpath=['..' filesep 'results' filesep 'convTime' filesep]; %results subdirectory
addpath(genpath(['..' filesep 'scripts' filesep])); 
filetag='pil02'; %nametag of SPM datafile 

%% IR in each modality:
D=spm_eeg_load([fpath 'modCafMd' filetag '.mat']);
disp(D.conditions);
contrasts=[0 0 1
           1 0 0 
           0 1 0
           1/3 1/3 1/3];
names={'tac';'vis';'aud';'mean'};


%% "choice predictive signals" (CPS)
% D=spm_eeg_load([fpath 'cpsCafMd' filetag '.mat']);
% disp(D.conditions);
% contrasts=[-1 1]; 
% names={'cps'};
% cfg.vlim=[-0.5 0.5];


%% With EOG regressors:?
% D=spm_eeg_load([fpath 'cps_eogCafMd' filetag '.mat']);
% disp(D.conditions);
% contrasts=[-1 1]; 
% names={'cps-eogreg'};


%% FT-based viewer
dat=D(:,:,:); 
dat=squeeze(dat);
ncontrasts=size(contrasts,1)
condat=zeros(D.nchannels,D.nsamples,ncontrasts);
for c=1:ncontrasts
    disp(['computing contrast... ' num2str(c)])
    con=[];
    con(1,1,:,1)=contrasts(c,:);
    con=repmat(con,[size(dat(:,:,1))]); 
    con=con.*dat;
    condat(:,:,c)=sum(con,3);
end

dat=[];
pre.label=D.chanlabels(1:64)';
pre.dimord='chan_time';
pre.time=D.time.*1000;
for k=1:ncontrasts
    lab=char(strcat('k', num2str(k)));
    dat.(lab)=pre;
    dat.(lab).avg=condat(:,:,k);
end
cfg.layout='ordered';
lay = ft_prepare_layout(cfg, dat.k1);
[X,Y]=getcoords(D.chanlabels(1:64)');
lay.pos(1:64,:)=[X;Y]';
scaler=0.6; %workaround for a nicely scaled topoplot
lay.pos(1:length(D.chanlabels(1:64)),:)=[X;Y]'.*scaler;
lay.width=lay.width*scaler;
lay.height=lay.height*scaler;
cfg.layout= lay;
cfg.interactive='yes';
cfg.style='straight';
figure;
if ncontrasts==1
    ft_multiplotER(cfg, dat.k1);
elseif ncontrasts==2
    ft_multiplotER(cfg, dat.k1, dat.k2);
elseif ncontrasts==3
    ft_multiplotER(cfg, dat.k1, dat.k2, dat.k3);
elseif ncontrasts==4
    ft_multiplotER(cfg, dat.k1, dat.k2, dat.k3, dat.k4);
end
legend(names)






    
