function addspm

addpath('C:\work\spm12\'); % path to your spm12 folder

if exist('spm_eeg_firstlevel.m', 'file') == 2
    disp('ok');
end

spm('defaults', 'eeg'); %set default to M/EEG