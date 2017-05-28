%% El Convolutor 

clear all;
%% create any stimulus function (e.g., delta/'stick' functions)
stimF=zeros(1,1000);
stimF([100:50:250  300 380 430 550 780])=1; %any onsets
figure;
subplot(2,2,1); plot(stimF); title('stimF')

%% create any 'basis' function
% e.g., a gaussian
basF = gausswin(100);

% % or a sine wave
% basF = sin(0:2*pi/180:2*pi); basF=basF(1:end-1)';
% % shift to model a post-stimulus response only
% basF = [zeros(length(basF),1); basF]; 

subplot(2,2,3);  plot(basF,'g'); title('basF');

%% convolve stimF with basF, using Matlab's conv.m
convF = conv(stimF, basF, 'same');
subplot(2,2,2); plot([stimF;convF]'); legend({'stimF';'convolved'}); title('conv.m');

%% or do it 'manually'
manconvF=zeros(size(stimF));
for i=1:length(stimF)-length(basF) % for each sample of stimF (for simplicity, omitting edges)
    currF=stimF(i:i+length(basF)-1); % get a stretch of stimF (same length as basF)
    currconv=currF.*fliplr(basF'); % multiply (element-wise) with *flipped* basF 
    currconv=sum(currconv); % sum the result (~correlate)
    manconvF(i+round(length(basF)/2)-1)=currconv; % yields one sample of the convolved stimF
end
subplot(2,2,4); plot([stimF;manconvF]'); legend({'stims';'convolved'}); title('DIY convolution');
