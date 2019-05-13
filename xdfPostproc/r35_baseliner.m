function r35_baseliner(studyPath)
% r35_baseliner(studyPath)
%
% Developed on: Matlab 2019a

disp('> Baseline initializer');

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
    clear emg;
    
    % Eliminate ' ' characters at the end of file name
    fileName = strip(file{c,:});
    disp(['baseIni > dividing: ',fileName]);
    
    % Baseline data
    if(contains(fileName,'baseline','IgnoreCase',true))
        
        % Read .mat
%         load(fileName,'emg');
        data = load(fileName,'data');
        
        % Plot file
%         plot(emg.rectified')
        plot(data.emg.rectified')
        
        % Select clean baseline
        [x,y] = ginput(2);
        ind1 = int32(x(1));
        ind2 = int32(x(2));
        
        % Copy data to 'baseline' array
%         fn = fieldnames(emg);
fn = fieldnames(data.emg);
        for f = 1:size(fn,1)
%             baseline.(fn{f,1}) = emg.(fn{f,1})(:,ind1:ind2);
            baseline.(fn{f,1}) = data.emg.(fn{f,1})(:,ind1:ind2);
        end
        disp('baseIni > baseline acquired');
        
        % Plot baseline
        plot(baseline.rectified')
        
        % Save figure
        saveas(gcf,[studyPath,'baseline','.png'])
        % Save record data
        save([studyPath,'baseline','.mat'],'baseline')%,'-v7.3')
        
        % MVC data
    elseif(contains(fileName,'mvc','IgnoreCase',true))
        % Read .mat
        data = load(fileName,'data');
        % Initialize figures
        f1 = figure('Name','Chunk selector');
        f2 = figure('Name','Saver');
        
        mvc = cell(size(data.emg.rectified,1),1);
        for a = 1:size(data.emg.rectified,1) % each muscle
            % Plot file
            figure(f1);
            plot(data.emg.rectified(a,:));
            title([fileName,'_muscle',num2str(a)]);
            
            % Select clean baseline
            [x,y] = ginput(6);
            
            % Copy data to 'mvc' array
            fn = fieldnames(data.emg);
            for b = 1:(length(x)/2) % each data point
                ind1 = int32(x(2*b-1));
                ind2 = int32(x(2*b));
                
                for f = 2:size(fn,1) % each fieldName. Exclude timeStamp
                    if(b==1)
                        mvc{a,1}.(fn{f,1}) = data.emg.(fn{f,1})(a,ind1:ind2);
                    else
                        mvc{a,1}.(fn{f,1}) = cat(2,mvc{a,1}.(fn{f,1}),data.emg.(fn{f,1})(a,ind1:ind2));
                    end
                end
            end
            
            % Plot mvc
            figure(f2);
            subplot(1,size(data.emg.rectified,1),a), plot(mvc{a,1}.rectified)
        end
        disp('baseIni > mvc acquired');
        
        % Save figure
        saveas(gcf,[studyPath,'mvc','.png'])
        % Save record data
        save([studyPath,'mvc','.mat'],'mvc')%,'-v7.3')
    end
    close all;
end

disp('baseIni > done!')
end