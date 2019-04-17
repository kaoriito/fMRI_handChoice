function instructarr = generateInstructArray ()


instructarr=zeros(1,32);

total1=0;
total2=0;

for m=1:32
    
    if total1<16 && total2<16
        instructarr(m)=randi([1,2],1,1);
        
        if total1==total2+3
            instructarr(m)=2;
        elseif total2==total1+3
            instructarr(m)=1;
        end
        
        if m>3
            % if 3 consecutive are the same, choose the other
            if instructarr(m-3)==instructarr(m-2) && instructarr(m-2)==instructarr(m-1)
                if instructarr(m-1)==1
                    instructarr(m)=2;
                else
                    instructarr(m)=1;
                end
            
            end
        
        end
        
        if instructarr(m)==1
            total1=total1+1;
        else
            total2=total2+1;
        end
        
    elseif total1==16 && total2< 16
        instructarr(m)=2;
        total2=total2+1;
        
    elseif total1<16 && total2==16
        instructarr(m)=1;
        total1=total1+1;
    end
    
end


end