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
global rightHandKey leftHandKey screenWidth screenHeight
rightHandKey='RightArrow';
leftHandKey='LeftArrow';

%% set the screen
Screen('Preference', 'SkipSyncTests', 1); %remove this line if sync tests pass


%[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')),[0 0 0],[0 0 400 280]); %open the screen
[wPtr, rect]=Screen('OpenWindow',max(Screen('Screens')), [0 0 0]);
screenWidth=rect(3);
screenHeight=rect(4);


%% generate pseudorandom blocks

conditions={'instruct','choice'};
blockarr=generateBlockArray();
disp(blockarr);

%%
% instructArr=[]; [instruct-L, instruct-R randomized 32 times, 16 times
% each
instructHands={'instruct-L','instruct-R'};
%instructArr=[1 2 1 1 2 2 1 1 2 2 1 1 2 2 1 2 1 2 1 1 2 2 1 1 2 2 1 1 2 2 1 2];

%% designate block

for i=1:16
    
    block=conditions(blockarr(i));
    pressnum=0;
    
    delayArr=generateDelayArray();
    
    %% designate trial within block
    for j=1:4
        
        if strcmp(block,'choice')
            % 0th second: designate block
            trialtype='choice';
        elseif strcmp(block,'instruct')
             % 0th second: designate block
            trialtype=instructHands(instructArr((i-1)*4+j));
        end
        
        delay=delayArr(j);
       
        pressnum=trial(pressnum, trialtype, delay, wPtr);
        
    end

    %%
    %% rest block
    % SOME CODE HERE: 20 seconds crosshair, + log
    %
    
end
%%
clear Screen;


end