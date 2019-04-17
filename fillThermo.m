function fillThermo(wPtr,pressnum)
global screenWidth screenHeight

% construct dimensions of the outer part
OuterRectWidth=screenWidth/4;
OuterRectHeight=1.5*(screenHeight/3);

xCenter=screenWidth/2;
yTopThird=screenHeight/3;

OuterRectLeft=xCenter-OuterRectWidth/2;
OuterRectTop=yTopThird;
OuterRectRight=OuterRectLeft+OuterRectWidth;
OuterRectBottom=OuterRectTop+OuterRectHeight;


OuterRect=[OuterRectLeft, OuterRectTop, OuterRectRight, OuterRectBottom];

if pressnum==0
    Screen('FrameRect',wPtr,[255 255 255], OuterRect, 3);
else

    % draw the inside part
    fill=0.25*pressnum;
    InnerRectHeight=OuterRectHeight*fill;

    InnerRect=[OuterRectLeft+1, OuterRectBottom-InnerRectHeight, OuterRectRight-1, OuterRectBottom-1];
    Screen('FillRect',wPtr,[220 20 60],InnerRect);
    Screen('FrameRect',wPtr,[255 255 255], OuterRect, 3);
end
    
end