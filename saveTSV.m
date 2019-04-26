function saveTSV()
% 2018a

% Get/set file name and path
[fileName,filePath] = uigetfile('*.mat');
% filePath = 'G:\Team Drives\NPNL\03_npnl_projects\02_current_studies\c0024_stroke_compensation\c0024_data\data_collection\Pilot\mri\sub-c0024g00s0006h\logs\';
% fileName = 'c0024g00s0006h_run02logs.mat';

% Set output name and path
outName = 'events.tsv';
outPath = [filePath,'bids\events\'];

% Load data
load([filePath,fileName],'choiceObj','instructObj');
% Add response times
[choiceObj,instructObj] = addResponse(choiceObj,instructObj);

T1 = parseStruct(instructObj);
T2 = parseStruct(choiceObj);

writetable([T1;T2],[outPath,outName,'.csv'],'Delimiter','tab');
end

function [choiceObj,instructObj] = addResponse(choiceObj,instructObj)
for i=1:32
    choiceObj{i,2}.response=choiceObj{i,3}.response;
    choiceObj{i,2}.responseTime=choiceObj{i,3}.responseTime;
    instructObj{i,2}.response=instructObj{i,3}.response;
    instructObj{i,2}.responseTime=instructObj{i,3}.responseTime;
end
end

function tabObj = parseStruct(stObj)
% Initialize table
tabObj = table('Size',[1 5],...
    'VariableNames',{'onset','duration','trial_type','response_time',...
    'response'},...
    'VariableTypes',{'double','double','categorical','double',...
    'categorical'});

trialNum = 1;
for a = 1:size(stObj,1) % Each trial
    for b = 2 % 1:size(stObj,2) % Each phase
        % Parse values to struct
        t.onset = round(stObj{a,b}.Onset,5);
        t.duration = round(stObj{a,b}.Duration,5);
        t.trial_type = stObj{a,b}.type;
        t.response_time = round(stObj{a,b}.responseTime,5);
        if(contains(stObj{a,b}.response,'3'))
            t.response = 'L';
        elseif(contains(stObj{a,b}.response,'4'))
            t.response = 'R';
        end
        
        % Parse to table
        tabObj(trialNum,:) = struct2table(t);
        trialNum = trialNum+1;
    end
end
end