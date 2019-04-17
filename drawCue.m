function drawCue(wPtr, phase)
global screenHeight screenWidth
switch(phase)
    case 'choose'
        
        color=[252 244 24];
        
    case 'go'
        
        color=[0 255 0];
        
    case 'fb'
        
        color=[0 0 0];

    case 'instruct-L'
        
        text='<<';
        textCenterX=screenWidth/2 - (screenWidth/8)/4;
        textCenterY=screenHeight/3 - (screenHeight/8);
        Screen('TextSize',wPtr,round(screenHeight/14));
        DrawFormattedText(wPtr,text,textCenterX,textCenterY,[255 255 255]);

        return;
        
    case 'instruct-R'
        
        text='>>';
        textCenterX=screenWidth/2 - (screenWidth/8)/4;
        textCenterY=screenHeight/3 - (screenHeight/8);
        Screen('TextSize',wPtr,round(screenHeight/14));
        DrawFormattedText(wPtr,text,textCenterX,textCenterY,[255 255 255]);
        
        return;
        
    otherwise
        
        color=[0 0 0];
end

circLeft=screenWidth/2 - (screenWidth/8)/2;
circTop=screenHeight/3 - (screenWidth/8)/2 - (screenHeight/6);
circRight=circLeft+ (screenWidth/8);
circBottom=screenHeight/3 + (screenWidth/8)/2 - (screenHeight/6);

circPlacement=[circLeft, circTop,circRight,circBottom];

Screen('FillOval',wPtr,color, circPlacement);
Screen('FrameOval',wPtr,[255 255 255], circPlacement,3);

end