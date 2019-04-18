function endTime=BreakableWait(secs)
    global breakKey
    
    startTime=GetSecs;
    

    while(GetSecs-startTime<secs)
        [keyIsDown, timeSecs,keyCode]=KbCheck(-1);
        if keyIsDown
            if(find(keyCode)==breakKey)
                sca;
                error('Exiting: user pressed escape.');
            end
        end
    end
    
    endTime=GetSecs;
end