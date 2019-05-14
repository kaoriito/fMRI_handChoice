function main()
%%
%
% KLI fMRI handChoice task paradigm: Mixed event/block related design
% 20190416
% 
% NOTES: 
%   this task has randomized blocks of choice/instruction blocks
%    where they can at most appear in consecutive order 3 times
%    and there is a total of 8 blocks of each type; and 16 blocks of 12s
%    rest
%
%   each of the trials are an event; there are 4 trials in a block (trials
%  34344  last 3 seconds each); trials are jittered at a random
%    interval such that they are within 1-4 seconds (at 0.5s intervals);
%    total time of inter-trial intervals = 8 seconds (20-12 seconds=8)


%% change this based on input keys from scanner/keyboard
global rightHandKey leftHandKey screenWidth screenHeight breakKey

KbName('UnifyKeyNames');

% these are set to the key names without KbName because we are using string
% compare to the keyname pressed later.
rightHandKey="4$";
leftHandKey="3#";


breakKey=KbName('Escape');
triggerCode=KbName('5%'); %set scanner trigger key here

%%

prompt={'Subject ID:','run:'};
dlgtitle='Input';
dims=[1 35];
definput={'c0024','run0'};
answer=inputdlg(prompt,dlgtitle,dims,definput);

subjectID=answer{1};
run=answer{2};

logDirectory='/Users/lilyito/Documents/Projects/stroke_compensation/pilot/mri/fmri_task/logs';


%% create structures for each condition type
choiceObj=cell(32,4);
instructObj=cell(32,4);
restObj=cell(16,1);

choiceBlockLogs=zeros(8,2);
instructBlockLogs=zeros(8,2);

%% set the screen
Screen('Preference', 'SkipSyncTests', 1); %remove this line if sync tests pass
Screen('Preference','VisualDebugLevel',0);

%5343[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')),[0 0 0],[0 0 400 280]); %open the screen
[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')), [0 0 0]);
screenWidth=rect(3);
screenHeight=rect(4);


%% generate pseudorandom blocks

conditions={'instruct','choice'};
blockarr=generateBlockArray();
instructBlockNum=1;
choiceBlockNum=1;

%% generate pseudorandom left/right trials for instruct block
% this will generate an array of 32, with 1 & 2 randomized (totalling 16
% times each and no more than 3 consecutive)

instructHands={'instruct-L','instruct-R'};
instructArr=generateInstructArray();
instructCount=1;
choiceCount=1;

% Set font options
defaultFont='Helvetica';
Screen('TextSize',wPtr,round(screenHeight/14));
Screen('TextFont',wPtr,defaultFont);

%% Present start screen = stays until key pressed
text='We will start shortly.';
Screen('FillRect',wPtr,[0 0 0]);
DrawFormattedText(wPtr,text,'center','center',[255 255 255]);
Screen('Flip',wPtr);

DisableKeysForKbCheck([]);
fprintf('Waiting for scanner trigger...');


while 1
    [ keyIsDown, timeSecs, keyCode] = KbCheck(-1);
    if keyIsDown
        index = find(keyCode);
        if(index==triggerCode)
            break;
        end
    end
end

triggerTime=timeSecs;
tic;
fprintf('Trigger received\n');

DisableKeysForKbCheck([triggerCode]);

%% designate block

%for i=1:2
for i=1:length(blockarr)
    
    block=conditions(blockarr(i));
    pressnum=0;
    
    delayArr=generateDelayArray();
    
    % show block cue, record onset of block
    if strcmp(block,'instruct')
        text='Instruct';
        Screen('FillRect',wPtr,[0 0 0]);
        DrawFormattedText(wPtr,text,'center','center',[255 255 255]);
        Screen('Flip',wPtr);
        instructTime=BreakableWait(1);
        
        blocknum=instructBlockNum;
        instructBlockLogs(blocknum,1)=instructTime-triggerTime;
    else
        text='Choose';
        Screen('FillRect',wPtr,[0 0 0]);
        DrawFormattedText(wPtr,text,'center','center',[255 255 255]);
        Screen('Flip',wPtr);
        choiceTime=BreakableWait(1);
        
        blocknum=choiceBlockNum;
        choiceBlockLogs(blocknum,1)=choiceTime-triggerTime;
    end
    
        
    %% designate trial within block
    for j=1:4
        
        if strcmp(block,'choice')
            % 0th second: designate block
            trialtype='choice';
            trialCount=choiceCount;
            
        elseif strcmp(block,'instruct')
             % 0th second: designate block
            disp(instructCount);
            trialtype=instructHands(instructArr(instructCount));
            trialCount=instructCount;
        end
        
        disp(trialtype);
        
        delay=delayArr(j);
       
        [pressnum,trialObj]=trial(pressnum, trialtype, delay, wPtr,trialCount,triggerTime);
        
        
        % put the trialObj into it's own row in its condition (choice/instruct) object
        if strcmp(block,'choice')
            % 4 columns, for each phase of a trial
            choiceObj{trialCount,1}=trialObj{1,1};
            choiceObj{trialCount,2}=trialObj{1,2};
            choiceObj{trialCount,3}=trialObj{1,3};
            choiceObj{trialCount,4}=trialObj{1,4};
            choiceCount=choiceCount+1;
        else
            instructObj{trialCount,1}=trialObj{1,1};
            instructObj{trialCount,2}=trialObj{1,2};
            instructObj{trialCount,3}=trialObj{1,3};
            instructObj{trialCount,4}=trialObj{1,4};
            instructCount=instructCount+1;
        end
        
    end
    
    if strcmp(block,'instruct')
        blocknum=instructBlockNum;
        instructBlockLogs(blocknum,2)=GetSecs-instructBlockLogs(blocknum,1)-triggerTime;
        instructBlockNum=instructBlockNum+1;
    else
        blocknum=choiceBlockNum;
        choiceBlockLogs(blocknum,2)=GetSecs-choiceBlockLogs(blocknum,1)-triggerTime;
        choiceBlockNum=choiceBlockNum+1;
    end

    %%
    %% rest block
    drawCross(wPtr);
    restTime=Screen('Flip',wPtr);
    restObj{i,1}.Onset=restTime-triggerTime;
    restObj{i,1}.trial=i;
    restObj{i,1}.type='rest'; 
    restObj{i,1}.response='';
    restObj{i,1}.responseTime='';
    
    restOff=BreakableWait(12);
    restObj{i,1}.Duration=restOff-restObj{i,1}.Onset-triggerTime;
    
    %
    
end

toc;
%%
clear Screen;

filename=strcat(subjectID,'_',run,'_logs.mat');
path2save=fullfile(logDirectory,filename);

save(path2save,'choiceObj','instructObj','restObj','choiceBlockLogs','instructBlockLogs')

end