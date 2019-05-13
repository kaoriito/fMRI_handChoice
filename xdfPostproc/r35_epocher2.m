function r35_epocher2(studyPath,labelS,labelE)
% r35_epocher(studyPath,labelS,labelE)
%
% Developed on: Matlab 2019a

disp('> Epoch divider');

% Create output folder
mkdir([studyPath,'EMGepoch2']);
% Move to specified path
cd([studyPath,'EMGfilt\']);

% Get file names
files = ls('*.mat');
w = 1;
for q = 1:size(files,1)
    file(w,1) = {files(q,:)};
    w=w+1;
end

% Initialize session trial
st = 1;
for c = 1:size(file,1) % Each .mat file in folder
    close all;
    clear emg markers;
    
    % Eliminate ' ' characters at the end of file name
    fileName = strip(file{c,:});
    disp(['epoch > dividing: ',fileName]);
    
    % Trial data
    if(~contains(fileName,'baseline','IgnoreCase',true) &&...
            ~contains(fileName,'mvc','IgnoreCase',true) &&...
            ~contains(fileName,'weight','IgnoreCase',true) &&...
            ~contains(fileName,'movement','IgnoreCase',true) &&...
            ~contains(fileName,'myoware','IgnoreCase',true) &&...
            ~contains(fileName,'leap','IgnoreCase',true))
        
        if(contains(fileName,'thermo','IgnoreCase',true))
            labelE = 'BASELINE';
        end
        
        % Read .mat
        load(fileName,'emg','markers');
        
        % Initialize file trial
        t=1;
        % Divide in epochs
        for mark = 1:size(markers.marker,2)
            
            % Look for marker 'labelS'
            if(contains(markers.marker{1,mark},labelS,'IgnoreCase',true))
                active{t,1}.timeBound(1) = markers.timeStamp(1,mark);
                
                % Look for marker 'labelE'
            elseif(contains(markers.marker{1,mark},labelE,'IgnoreCase',true))
                active{t,1}.timeBound(2) = markers.timeStamp(1,mark);
                
                % Look for matching indeces of 'markers' in 'emg'
                ind1 = find(emg.timeStamp>=active{t,1}.timeBound(1),1);
                ind2 = find(emg.timeStamp>=active{t,1}.timeBound(2),1);
                
                % Rest time
                rest{t,1}.timeBound(1) = active{t,1}.timeBound(1) - 5*2000;
                rest{t,1}.timeBound(2) = active{t,1}.timeBound(1);
                % Rest index
                indR = find(emg.timeStamp>=rest{t,1}.timeBound(1),1);
                
                % Copy data to 'trial' and 'sTrial' arrays
                fn = fieldnames(emg);
                for f = 1:size(fn,1)
                    rest{t,1}.(fn{f,1}) = emg.(fn{f,1})(:,indR:ind1);
                    active{t,1}.(fn{f,1}) = emg.(fn{f,1})(:,ind1:ind2);
                    
                    sRest{st,1}.(fn{f,1}) = emg.(fn{f,1})(:,indR:ind1);
                    sActive{st,1}.(fn{f,1}) = emg.(fn{f,1})(:,ind1:ind2);
                end
                
                % Visual inspection
                try
                    subplot(4,5,t),
                    plot(active{t,1}.timeStamp, active{t,1}.rectified(1,:))
                catch
                    warning(['Could not plot trial ',num2str(t)])
                end
                t = t+1;
                st = st+1;
            end
        end
        % Save figure
        saveas(gcf,[studyPath,'EMGepoch2\',fileName(1:end-4),'_',labelS,'-',labelE,'.png'])
        % Save record data
        save([studyPath,'EMGepoch2\',fileName(1:end-4),'_',labelS,'-',labelE,'.mat'],'active','rest')%,'-v7.3')
    end
end

% Save session data
save([studyPath,'trial','.mat'],'sRest','sActive','-v7.3')

disp('epoch > done!')
end