function r35_filter(studyPath,configuration,type)
% r35_filter(studyPath,configuration)
%
% Developed on: Matlab 2019a

disp('> Filter');

% Create output folder
mkdir([studyPath,upper(type),'filt']);
% Move to specified path
cd([studyPath,upper(type),'raw\']);

% Get file names
files = ls('*.mat');
w = 1;
for q = 1:size(files,1)
    file(w,1) = {files(q,:)};
    w=w+1;
end

for c = 1:size(file,1) % Each .mat file in folder
    close all;
    clear data;
    % Eliminate ' ' characters at the end of the name
    fileName = strip(file{c,:});
    disp(['filt > filtering: ',fileName]);
    
    % Read .mat
    cd([studyPath,upper(type),'raw\']);
    %     if(contains(fileName,'baseline','IgnoreCase',true) || contains(fileName,'mvc','IgnoreCase',true))
    %         load(fileName,'emg');
    %     else
    %         load(fileName,'emg','markers');
    %     end
    load(fileName,'data');
    % Move back to function path
    cd("C:\Users\NPNL\Documents\GitHub\REINVENT_ModularGUI\Matlab\OfflineProcessing\");
    
    %     % DC-offset correction
    %     emg.zeroMean = r35_chunkProcessor(emg.raw,configuration,'zeroMean',emg.raw(:,1:2000));
    %     % 5-500 Filter
    %     emg.filtered = r35_chunkProcessor(emg.zeroMean,configuration,'filter',[]);
    %     % Rectification
    %     emg.rectified = r35_chunkProcessor(emg.zeroMean,configuration,'rectify',[]);
    switch(type)
        case 'emg'
            configuration = setBandFilter(configuration,5,10,450,500,2000);
            data = filterEMG(data,configuration,type);
        case 'eeg'
            data = filterEEG(data,configuration,type);
        case 'leap'
            configuration = setLowFilter(configuration,5,...
                floor(data.(type).sampleRate/2),data.(type).sampleRate);
            data = filterLEAP(data,configuration,type);
        case 'kinect'
            configuration = setLowFilter(configuration,5,...
                floor(data.(type).sampleRate/2),data.(type).sampleRate);
            data = filterKINECT(data,configuration,type);
    end
    
    % Visual inspection
    fNames = fieldnames(data.(type));
    plot(data.(type).timeStamp,data.(type).raw,...
        data.(type).timeStamp,data.(type).(strip(fNames{size(fNames,1),1})))
    
    if(isfield(data,'markers') && ~isempty(data.markers))%exist('markers','var'))
        if(size(data.markers.marker,2)>20)%~isempty(markers)&&size(markers.marker,2)>20)
            hold on
            text(data.markers.timeStamp,...
                1e-5*ones(1,length(data.markers.timeStamp)),...
                data.markers.marker,'FontWeight','bold')
            hold off
        end
        %         % Save figure
        %         saveas(gcf,[studyPath,upper(type),'filt\',fileName(1:end-4),'.png'])
        %         % Save data
        %         save([studyPath,upper(type),'filt\',fileName(1:end-4),'.mat'],'emg','markers')%,'-v7.3')
    else
        % Save data
        %         save([studyPath,upper(type),'filt\',fileName(1:end-4),'.mat'],'emg')%,'-v7.3')
    end
    % Save figure
    saveas(gcf,[studyPath,upper(type),'filt\',fileName(1:end-4),'.png'])
    % Save data
    save([studyPath,upper(type),'filt\',fileName(1:end-4),'.mat'],'data')%,'-v7.3')
end

disp('filt > done!');
end

function data = filterEMG(data,configuration,type)
% DC-offset correction
data.(type).zeroMean = r35_chunkProcessor(data.(type).raw,configuration,'zeroMean',data.(type).raw(:,1:2000));
% 5-500 Filter
data.(type).filtered = r35_chunkProcessor(data.(type).zeroMean,configuration,'filter',[]);
% Rectification
data.(type).rectified = r35_chunkProcessor(data.(type).zeroMean,configuration,'rectify',[]);
end

function data = filterKINECT(data,configuration,type)
% DC-offset correction
% data.(type).zeroMean = r35_chunkProcessor(data.(type).raw,configuration,'zeroMean',data.(type).raw(:,1:20));
% 5-500 Filter
data.(type).filtered = r35_chunkProcessor(data.(type).raw,configuration,'filter',[]);
% Rectification
% data.(type).rectified = r35_chunkProcessor(data.(type).zeroMean,configuration,'rectify',[]);
end

function data = filterLEAP(data,configuration,type)
% DC-offset correction
% data.(type).zeroMean = r35_chunkProcessor(data.(type).raw,configuration,'zeroMean',data.(type).raw(:,1:20));
% 5-500 Filter
data.(type).filtered = r35_chunkProcessor(data.(type).raw,configuration,'filter',[]);
% Rectification
% data.(type).rectified = r35_chunkProcessor(data.(type).zeroMean,configuration,'rectify',[]);
end

function configuration = setBandFilter(configuration,f1,f2,f3,f4,sr)
% EMG: f1 = 5; f2 = 10; f3 = 450; f4 = 500;
configuration.filter = designfilt('bandpassfir',...
    'SampleRate',sr,...
    'DesignMethod','kaiserwin',...
    'StopbandFrequency1',f1,...
    'PassbandFrequency1',f2,...
    'PassbandFrequency2',f3,...
    'StopbandFrequency2',f4);
end

function configuration = setLowFilter(configuration,f1,f2,sr)
% EMG: f1 = 5; f2 = 10; f3 = 450; f4 = 500;
configuration.filter = designfilt('lowpassfir',...
    'PassbandFrequency',f1, ...     % Frequency constraints
    'StopbandFrequency',f2, ...
    'DesignMethod','equiripple', ...         % Design method
    'SampleRate',sr);
%     'FilterOrder',25, ...            % Filter order
%        'PassbandWeight',1, ...          % Design method options
%        'StopbandWeight',2, ...
end