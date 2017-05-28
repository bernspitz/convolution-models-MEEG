%% Initialize and config
clear all;
fpath=['..' filesep 'analysis' filesep]; %analysis directory
filetag='pil02'; %nametag of SPM datafile 

D=spm_eeg_load([fpath 'afMd' filetag '.mat']); %load EEG data file 

%% empty event onset matrices
pulsemat=zeros(D.nsamples,3,2);  %Main Pulse Matrix:  modality  x chosen
diffmat=zeros(D.nsamples,3); % momentary difference parameter matrix
intmat=zeros(D.nsamples,2); % on/offset of 2 sec interval (visual fixation cued) 
pedmat=zeros(D.nsamples,2); % left/right response

%% isolate experiment triggers from artefact markers
tmp=D.events; 
evt=[]; evtim=[]; trg=0;
for i=1:length(tmp)
    if strmatch(tmp(i).type, 'STATUS', 'exact') & isnumeric(tmp(i).value)
        trg=trg+1;
        evt(trg)=tmp(i).value;
        evtim(trg)=tmp(i).time;%/1000;
    end
end

%% happy coding..

%1: Visual   2: Auditory   3: Tactile; 
modtrigs=[12 21 13 31 23 32];  %interval onset (codes pairwise combi of modalities and response mapping)
basevec=[40 50 130];  %single pulses (vis/aud/tac, each +1 for each repetition) - 
fbtrigs=[70 100 60 80 110 90];  % feedback triggers; +1 for correct (will be used only to verify that trials were completed)
 
evtlog=[]; lapses=0; goodtrials=0;
for i=1:length(evt)  
    
    if ismember(evt(i),modtrigs) %step into trial
        cnt=zeros(1,3);
        for nj=1:15  %count all pulses in the trial 
            if evt(i+nj) == 1 
                break 
            end
        end
        
        %%  there are all just checks for incomplete trials, omitted responses, and/or trigger port errors
        lapse=0; 
        if ~ismember(evt(i+nj+1),[2 3])  | ~ismember(evt(i+nj+2),[fbtrigs fbtrigs+1]) %check if trial is complete, else skip trial
            lapse=1;
        end
        for n=1:nj
            for mod=1:3
                if ismember(evt(i+n),[basevec(mod)+1:basevec(mod)+7])
                    cnt(mod)=cnt(mod)+1;
                    if evt(i+n)~=basevec(mod)+cnt(mod) % if anything does not fit, log lapse
                        lapse=1;
                    end
                end
            end
        end
        chk=cnt(cnt~=0);
        difficulty=abs(diff(chk)); % further checks 
        if diff(chk)==0 | min(chk)<2 
            lapse=1;
        end
        perf= rem(evt(i+nj+2),10);
        resp=evt(i+nj+1)-1;
        if resp>2 % further checks 
            lapse=1 ; 
        end
        
        if lapse==1 %if any of the checks failed, skip trial, and log lapses
            lapses=lapses+1;
            continue
        end
            
        %% if all checks passed, go on readin those event onsets
        goodtrials=goodtrials+1
        trset=num2str(evt(i)); % interval onset trigger with trial setting info
        modrig=str2num(trset(1)); % response mapped "left"/ mapped "right" modality 
        modlef=str2num(trset(2));
      
        cntrig=cnt(modrig); % Number of pulses  per right/left response mapping 
        cntlef=cnt(modlef);            
        
        expvecrig=[basevec(modrig)+1:basevec(modrig)+cntrig]; % to-be-expected trigger values in this trial (left/right)
        expveclef=[basevec(modlef)+1:basevec(modlef)+cntlef];
        respind=i+cntrig+cntlef+2; % this should be the pedal press trigger (if trial was complete)

        %check (again) if trial is complete:
        if ismember(cntrig,[2:7]) & ismember(cntlef,[2:7]) & evt(respind-1)==1 & evt(respind)-1==resp
            %disp('ok')
            trevt=evt(i:respind); %list all events in the trial
            tim=evtim(i:respind); %list all times in the trial
            trtim=tim-tim(1); %set trial time to zero;
            differ=zeros(length(trevt),1); difrig=differ;  diflef=differ; %empty difference calc vectors;

            indrig=find(ismember(trevt,expvecrig)); % compute momentary cumulative difference between sequences...
            indlef=find(ismember(trevt,expveclef));

            %pulses in modality 1 (mapped onto right pedal)
            timrig=tim(indrig);
            for n=1:length(timrig)
                ind=find(abs(D.time-timrig(n))==min(abs(D.time-timrig(n))));
                if length(ind)>1
                    ind=ind(1);
                end
                pulsemat(ind,modrig,resp)=1;
            end

            %pulses in modality 2 (mapped onto left  pedal)
            timlef=tim(indlef);
            for n=1:length(timlef)
                ind=find(abs(D.time-timlef(n))==min(abs(D.time-timlef(n))));
                if length(ind)>1
                    ind=ind(1);
                end
                pulsemat(ind,modlef,-resp+3)=1;  % Note: inverted response, i.e. it is coded whether sequence was chosen or not                   
            end

            %start of interval (visual) cue
            onpos=1;
            ind=find(abs(D.time-tim(1))==min(abs(D.time-tim(1))));
            if length(ind)>1
                ind=ind(1);
            end
            offmat(ind,resp)=1;
            
            %end of interval (visual) cue
            offpos=length(timlef)+length(timrig)+2;
            if  offpos<=length(trevt) & trevt(offpos)==1
                ind=find(abs(D.time-tim(offpos))==min(abs(D.time-tim(offpos))));
                if length(ind)>1
                    ind=ind(1);
                end
                offmat(ind,resp)=1;
            else
                disp(['warning: no off trigger within epoch, trial' num2str(k)]);
            end

            %pedal press
            pedpos=length(timlef)+length(timrig)+3; 
            if  pedpos<=length(trevt) & ismember(trevt(pedpos),[2 3])
                ind=find(abs(D.time-tim(pedpos))==min(abs(D.time-tim(pedpos))));
                if length(ind)>1
                    ind=ind(1);
                end
                pedlr=trevt(pedpos)-1; % now 1 is left, 2 is right
                if pedlr~=resp
                    error('pedal l/r error')
                end
                pedmat(ind,pedlr)=1;
            else
                disp(['warning: no pedal trigger within epoch, trial' num2str(k)]);
            end

        else % if trial was not complete:
            mistrial(sub)=mistrial(sub)+1;
            warning(['mistrial:' num2str(mistrial(sub)) 'sub' subjects{sub}]);
        end
    end
end

save('myevents.mat', 'pulsemat', 'pedmat'); %save onset files to disk
howmanypulses=sum(sum(pulsemat),3) %visual auditory tactile;
