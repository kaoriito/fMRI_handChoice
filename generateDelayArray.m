function delayArray = generateDelayArray()
    
    delayArray=zeros(1,4);
    
    randnum1= 1+(4-1).*rand(1,1); % generates a rand numb between 1 & 4
    delayArray(1)=round(randnum1*2)/2; % rounds the num to nearest 0.5s
    
    randmin=max(4-delayArray(1),1);
    randmax=min(7-delayArray(1),4);
    randnum2=randmin + (randmax-randmin) .* rand(1,1);
    
    delayArray(2)=round(randnum2*2)/2; % round to nearest 0.5s
    
    ISIused=delayArray(1)+delayArray(2);
    
    delayArray(3)=8-ISIused;
    
    delayArray(4)=0;
    
end