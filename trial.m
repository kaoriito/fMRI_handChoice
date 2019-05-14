function [pressnum,trialObj] = trial (pressnum, trialtype, delay, wPtr,trialCount,triggerTime)
global rightHandKey leftHandKey breakKey

% create trial object

    trialObj{1,1}.phase='ready';
    trialObj{1,2}.phase='go';
    trialObj{1,3}.phase='feedback';
    trialObj{1,4}.phase='delay';

    trialObj{1,1}.trial=trialCount;
    trialObj{1,2}.trial=trialCount;
    trialObj{1,3}.trial=trialCount;
    trialObj{1,4}.trial=trialCount;
    
    trialObj{1,1}.response='';
    trialObj{1,3}.response='';
    trialObj{1,4}.response='';
    
    trialObj{1,1}.responseTime='';
    trialObj{1,3}.responseTime='';
    trialObj{1,4}.responseTime='';
%%  
    if strcmp(trialtype,'choice')
        phase='choose';
    
    else
        if strcmp(trialtype,'instruct-L')
            phase='instruct-L';
        elseif strcmp(trialtype,'instruct-R')
            phase='instruct-R';
        end  
    end
    
    trialObj{1,1}.type=phase;
    trialObj{1,2}.type=phase;
    trialObj{1,3}.type=phase;
    trialObj{1,4}.type=phase;
    
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    
    readyTime=Screen('Flip',wPtr);
    trialObj{1,1}.Onset=readyTime-triggerTime;
    
    offsetTime=BreakableWait(1);
    trialObj{1,1}.Duration=offsetTime-trialObj{1,1}.Onset-triggerTime;
%%
    phase='go';
    %beep500=MakeBeep(500,0.15,48000);
    %sound(beep500,48000);
    phaseStartTime=GetSecs();
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    
    stimGoTime=Screen('Flip',wPtr); % get the time at which the 'Go' is displayed
    trialObj{1,2}.Onset=stimGoTime-triggerTime;
    stimDuration=1.5;
    
    
    while GetSecs() <= stimGoTime + stimDuration
        [keyIsDown, pressedSecs, keyCode] = KbCheck(-1);
        
        if keyIsDown
           if (find(keyCode)==breakKey)
               sca;
               error('Exiting: user pressed escape.');
           else
               responseKey=KbName(find(keyCode));
               responseTime=pressedSecs-phaseStartTime;
           end
        end
        
    end
    
    offsetTime=GetSecs;
    trialObj{1,2}.Duration=offsetTime-trialObj{1,2}.Onset-triggerTime;
    
    if exist('responseKey','var')
        
        % correct trials
       if strcmp(trialtype,'choice') && ((strcmp(responseKey,rightHandKey)) || (strcmp(responseKey,leftHandKey)))
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
            pressnum=pressnum+1; 
        elseif strcmp(trialtype,'instruct-L') && (strcmp(responseKey,leftHandKey))
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
            pressnum=pressnum+1;
        elseif strcmp(trialtype,'instruct-R') && (strcmp(responseKey,rightHandKey))
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
            pressnum=pressnum+1;
       
            % incorrect instruct trials (wrong one pressed --> still log but don't update the bar)
        elseif strcmp(trialtype,'instruct-L') && (strcmp(responseKey,rightHandKey))
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
        elseif strcmp(trialtype,'instruct-R') && (strcmp(responseKey,leftHandKey))
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
        else 
            fprintf('\nKey %s was pressed at %.4f seconds\n\n', responseKey, responseTime);
        end

        
        trialObj{1,2}.response=responseKey;
        trialObj{1,2}.responseTime=responseTime;
    end
    
    
%%
    phase='fb';
        
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    feedbackTime=Screen('Flip',wPtr);
    trialObj{1,3}.Onset=feedbackTime-triggerTime;
    
    offsetTime=BreakableWait(0.5);
    trialObj{1,3}.Duration=offsetTime-trialObj{1,3}.Onset-triggerTime;
    
%%
    phase='stop';
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    delayTime=Screen('Flip',wPtr);
    trialObj{1,4}.Onset=delayTime-triggerTime;
    
    offsetTime=BreakableWait(delay);
    trialObj{1,4}.Duration=offsetTime-trialObj{1,4}.Onset-triggerTime;
    
end