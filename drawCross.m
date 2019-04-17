function drawCross(wPtr)
global screenWidth screenHeight

% define cross characteristics
crossLength=round(screenWidth/14);
crossColor=[255 255 255];
crossWidth=3;

%set start/end points of lines
crossLines=[-crossLength,0; crossLength,0; 0, -crossLength; 0,crossLength];
crossLines=crossLines';

xCenter=screenWidth/2;
yCenter=screenHeight/2;

%draw the lines 
Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[xCenter,yCenter]);


end