function pressnum = trial (pressnum, trialtype, delay, wPtr)
global rightHandKey leftHandKey

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
    
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    Screen('Flip',wPtr);
    WaitSecs(1);
%%
    phase='go';
    phaseStartTime=GetSecs();
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    
    stimTime=Screen('Flip',wPtr); % get the time at which the 'Go' is displayed
    stimDuration=1.5;
    
    
    
    while GetSecs() <= stimTime + stimDuration
        [keyIsDown, pressedSecs, keyCode] = KbCheck(-1);
        
        if keyIsDown
           responseKey=KbName(find(keyCode));
           responseTime=pressedSecs-phaseStartTime;
        end
        
    end

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
        end

    end
    
    
%%
    phase='fb';
        
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    Screen('Flip',wPtr);
    WaitSecs(0.5);
    
%%
    phase='stop';
    drawCue(wPtr,phase);
    fillThermo(wPtr,pressnum);
    Screen('Flip',wPtr);
    WaitSecs(delay);
    
end