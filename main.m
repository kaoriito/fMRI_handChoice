function main()
%%
%
% KLI fMRI handChoice task paradigm: Mixed event/block related design
% 20190416
% 
% NOTES: 
%   this task has randomized blocks of choice/instruction blocks
%    where they can at most appear in consecutive order 3 times
%    and there is a total of 8 blocks of each type
%
%   each of the trials are an event; there are 4 trials in a block (trials
%    last 3 seconds each); trials are jittered at a random
%    interval such that they are within 1-4 seconds (at 0.5s intervals);
%    total time of inter-trial intervals = 8 seconds (20-12 seconds=8)


%% change this based on input keys from scanner/keyboard
global rightHandKey leftHandKey screenWidth screenHeight breakKey

rightHandKey='RightArrow';
leftHandKey='LeftArrow';
breakKey=KbName('Escape');

%% create structures for each condition type
choiceObj=cell(32,4);
instructObj=cell(32,4);
restObj=cell(8,1);

%% set the screen
Screen('Preference', 'SkipSyncTests', 1); %remove this line if sync tests pass
Screen('Preference','VisualDebugLevel',0);

[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')),[0 0 0],[0 0 400 280]); %open the screen
%[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')), [0 0 0]);
screenWidth=rect(3);
screenHeight=rect(4);


%% generate pseudorandom blocks

conditions={'instruct','choice'};
blockarr=generateBlockArray();
disp(blockarr);

%% generate pseudorandom left/right trials for instruct block
% this will generate an array of 32, with 1 & 2 randomized (totalling 16
% times each and no more than 3 consecutive)

instructHands={'instruct-L','instruct-R'};
instructArr=generateInstructArray();
instructCount=1;
choiceCount=1;

% Set font options
defaultFont='Helvetica';
Screen('TextSize',wPtr,24);
Screen('TextFont',wPtr,defaultFont);

%% Present start screen = stays until key pressed
text='We will start shortly.';
Screen('FillRect',wPtr,[0 0 0]);
DrawFormattedText(wPtr,text,'center','center',[255 255 255]);
Screen('Flip',wPtr);

fprintf('Waiting for scanner trigger...');
triggerCode=KbName('5%'); %set scanner trigger key here

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
fprintf('Trigger received\n');

%% designate block

for i=1:16
    
    block=conditions(blockarr(i));
    disp(block);
    pressnum=0;
    
    delayArr=generateDelayArray();
    
    %% designate trial within block
    for j=1:4
        
        if strcmp(block,'choice')
            % 0th second: designate block
            trialtype='choice';
            choiceCount=choiceCount+1;
            
        elseif strcmp(block,'instruct')
             % 0th second: designate block
            disp(instructCount);
            trialtype=instructHands(instructArr(instructCount));
            instructCount=instructCount+1;
 
        end
        
        disp(trialtype);
        
        delay=delayArr(j);
       
        [pressnum,trialObj]=trial(pressnum, trialtype, delay, wPtr);
        
    end

    %%
    %% rest block
    drawCross(wPtr);
    Screen('Flip',wPtr);

    WaitSecs(20);
    %
    
end
%%
clear Screen;


end