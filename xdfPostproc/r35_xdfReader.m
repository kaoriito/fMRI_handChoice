function r35_xdfReader(studyPath,type)
% r35_xdfReader(studyPath)
%
% Developed on: Matlab 2019a

disp('> xdfReader');

% Create output folder
mkdir([studyPath,upper(type),'raw']);
% Move to specified path
cd([studyPath,'xdf\']);

% Get file names
files = ls('*.xdf');
w = 1;
for q = 1:size(files,1)
    file(w,1) = {files(q,:)};
    w=w+1;
end

% % Initialize arrays for data
% streamRecord = cell(size(file,1),1);
% markers = cell(size(file,1),1);

for c = 1:size(file,1) % Each xdf file in folder
    % Eliminate ' ' characters at the end of the name
    fileName = strip(file{c,:});
    disp(['xdf > extracting ',fileName]);
    
    % read xdf
    streamRecord = load_xdf(fileName);
    
    for b = 1:size(streamRecord,2) % Each recorded stream
        %         clear emg markers;
        %         % If EMG stream, extract
        %         if (contains(streamRecord{1,b}.info.type,'EMG','IgnoreCase',true)&&...
        %                 ~contains(streamRecord{1,b}.info.type,"acc",'IgnoreCase',true)&&...
        %                 ~contains(streamRecord{1,b}.info.type,"proc",'IgnoreCase',true)&&...
        %                 ~contains(string(streamRecord{1,b}.info.name),"trigger",'IgnoreCase',true))
        %             disp(['xdf > Processing stream: ',streamRecord{1,b}.info.name]);
        %             emg.timeStamp = streamRecord{1,b}.time_stamps;
        %             emg.raw = streamRecord{1,b}.time_series;
        %         end
        %         % If Marker stream, extract
        %         if (contains(streamRecord{1,b}.info.name,'Markers','IgnoreCase',true)&&...
        %                 (~isempty(streamRecord{1,b}.time_series)))
        %             markers.timeStamp = streamRecord{1,b}.time_stamps;
        %             markers.marker = streamRecord{1,b}.time_series;
        %         end
        switch(type)
            case 'emg'
                if(~exist('data','var')||isempty(data.(type)))
                    data.(type) = parseEMG(streamRecord,b);
                end
            case 'eeg'
                if(~exist('data','var')||isempty(data.(type)))
                    data.(type) = parseEEG(streamRecord,b);
                end
            case 'leap'
                if(~exist('data','var')||isempty(data.(type)))
                    data.(type) = parseLEAP(streamRecord,b);
                end
            case 'kinect'
                if(~exist('data','var')||isempty(data.(type)))
                    data.(type) = parseKINECT(streamRecord,b);
                end
        end
        if(contains(streamRecord{1,b}.info.type,'Markers','IgnoreCase',true))
            data.markers = parseMarkers(streamRecord,b);
        end
    end
    
    % Save to new file
    %     if(exist('emg','var'))
    %         if(exist('markers','var'))
    %             save([studyPath,upper(type),'raw\',fileName(1:end-4),'.mat'],'emg','markers');
    %         else
    %             save([studyPath,'EMGraw\',fileName(1:end-4),'.mat'],'emg');
    %         end
    %     else
    %         warning('No EMG data in this record!');
    %     end
    if(~isempty(data.(type)))
        save([studyPath,upper(type),'raw\',fileName(1:end-4),'.mat'],'data');
    else
        warning(['No ',upper(type),' data in this record!']);
    end
end

disp('xdf > done!');
end

function emg = parseEMG(streamRecord,b)
clear emg;
% If EMG stream, extract
if (contains(streamRecord{1,b}.info.type,'EMG','IgnoreCase',true)&&...
        ~contains(streamRecord{1,b}.info.type,"acc",'IgnoreCase',true)&&...
        ~contains(streamRecord{1,b}.info.type,"proc",'IgnoreCase',true)&&...
        ~contains(string(streamRecord{1,b}.info.name),"trigger",'IgnoreCase',true))
    disp(['xdf > Processing stream: ',streamRecord{1,b}.info.name]);
    emg.sampleRate = streamRecord{1,b}.info.effective_srate;
    emg.timeStamp = streamRecord{1,b}.time_stamps;
    emg.raw = streamRecord{1,b}.time_series;
else
    emg = [];
end
end

function markers = parseMarkers(streamRecord,b)
clear markers;
% If Marker stream, extract
if (contains(streamRecord{1,b}.info.name,'Markers','IgnoreCase',true)&&...
        (~isempty(streamRecord{1,b}.time_series)) || ...
        contains(streamRecord{1,b}.info.type,'Markers','IgnoreCase',true)&&...
        ~contains(streamRecord{1,b}.info.name,'STARSTIM','IgnoreCase',true))
    markers.timeStamp = streamRecord{1,b}.time_stamps;
    markers.marker = streamRecord{1,b}.time_series;
else
    markers = [];
end
end

function eeg = parseEEG(streamRecord,b)
clear eeg;
% If EMG stream, extract
if (contains(streamRecord{1,b}.info.type,'EMG','IgnoreCase',true)&&...
        ~contains(streamRecord{1,b}.info.type,"acc",'IgnoreCase',true)&&...
        ~contains(streamRecord{1,b}.info.type,"proc",'IgnoreCase',true)&&...
        ~contains(string(streamRecord{1,b}.info.name),"trigger",'IgnoreCase',true))
    disp(['xdf > Processing stream: ',streamRecord{1,b}.info.name]);
    eeg.sampleRate = streamRecord{1,b}.info.effective_srate;
    eeg.timeStamp = streamRecord{1,b}.time_stamps;
    eeg.raw = streamRecord{1,b}.time_series;
else
    eeg = [];
end
end

function leap = parseLEAP(streamRecord,b)
clear leap;
% If EMG stream, extract
if (contains(streamRecord{1,b}.info.type,'HandTracking','IgnoreCase',true))
    disp(['xdf > Processing stream: ',streamRecord{1,b}.info.name]);
    leap.sampleRate = streamRecord{1,b}.info.effective_srate;
    leap.timeStamp = streamRecord{1,b}.time_stamps;
    leap.raw = streamRecord{1,b}.time_series;
else
    leap = [];
end
end

function kin = parseKINECT(streamRecord,b)
clear kin;
% If EMG stream, extract
if (contains(streamRecord{1,b}.info.name,'KINECT','IgnoreCase',true))
    disp(['xdf > Processing stream: ',streamRecord{1,b}.info.name]);
    kin.sampleRate = streamRecord{1,b}.info.effective_srate;
    kin.timeStamp = streamRecord{1,b}.time_stamps;
    kin.raw = streamRecord{1,b}.time_series;
else
    kin = [];
end
end