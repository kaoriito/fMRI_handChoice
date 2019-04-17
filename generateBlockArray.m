function blockarr = generateBlockArray ()


blockarr=zeros(1,16);

total1=0;
total2=0;

for m=1:16
    
    if total1<8 && total2<8
        blockarr(m)=randi([1,2],1,1);
        
        if total1==total2+3
            blockarr(m)=2;
        elseif total2==total1+3
            blockarr(m)=1;
        end
        
        if m>3
            % if 3 consecutive are the same, choose the other
            if blockarr(m-3)==blockarr(m-2) && blockarr(m-2)==blockarr(m-1)
                if blockarr(m-1)==1
                    blockarr(m)=2;
                else
                    blockarr(m)=1;
                end
            
            end
        
        end
        
        if blockarr(m)==1
            total1=total1+1;
        else
            total2=total2+1;
        end
        
    elseif total1==8 && total2<8
        blockarr(m)=2;
        total2=total2+1;
        
    elseif total1<8 && total2==8
        blockarr(m)=1;
        total1=total1+1;
    end
    
end


end