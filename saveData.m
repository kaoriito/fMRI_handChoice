%% Pop-up window to ask for the <group>, <subject> and <session>
prompt = {'Group:','Subject:','Session:'};
dlgtitle = 'Session data';
dims = [1 30];
definput = {'1','1','1'};
sessionID = inputdlg(prompt,dlgtitle,dims,definput);

%% Initialize variables
% Conditions per experiment
condition = {'choice', 'instruction', 'rest'};
% Blocks per condition
block = 1:8;
% Trials per block
blockTrial = 1:4;
% Phases per trial
phase = {'ready', 'go', 'fb', 'delay'};
% Cues
cue = {'choose','left','right'};
% Responses (button/key pressed)
response = {'left','right'};

numTrials = size(condition, 2) * length(block) * length(blockTrial);

S = cell(numTrials,size(phase,2));

T = table('Size',[numTrials*size(phase, 2) 7],...
    'VariableTypes',{'categorical','int32','categorical','categorical',...
        'double','categorical','double'},...
    'VariableNames',{'Condition','Trial','Cue','Phase',...
        'Onset','Response','ResponseTime'});

%% Build structures and table
for a = 1:size(condition, 2) % each condition
    for b = block % each block
        for c = blockTrial % each trial
            for d = 1:size(phase, 2) % each phase
                % Get values for each trial
                t.condition = condition{1,a};
                t.trial = (b-1)*length(blockTrial) + c ;
                t.cue = cue{1,a};
                t.phase = phase{1,d};
                t.onset = 10*rand(1); % Change this to the <onsetTime> 
                if(d==2) % Record response and time only for the 'go' phase
                    % Change <int32(rand(1)>0.5)+1> to <key pressed>
                    t.response = response{1,int32(rand(1)>0.5)+1};
                    % Change this to <time> of key pressed
                    t.responseTime = 10*rand(1)+5*rand(1);
                else
                    t.response = 'NA';
                    t.responseTime = NaN;
                end
                
                % Parse to cell array
                overallTrial = (a-1)*(length(block)*length(blockTrial)) + t.trial;
                S{overallTrial,d} = t;
                % Parse to table
                T((overallTrial-1)*size(phase,2)+d,:) = struct2table(t);
            end
        end
    end
end

%% Save data
sPath = 'C:\Users\NPNL\Documents\GitHub\fMRI_handChoice\';
sDate = date;
sFile = SetFileName(str2num(sessionID{1,1}),...
    str2num(sessionID{2,1}),str2num(sessionID{3,1}));
save([sPath,sFile,'.mat'],'S','sDate','sFile');
writetable(T,[sPath,sFile,'.csv']);

%% Functions
function dataName = SetFileName(group, subject, session)
projectID = 24;
projectName = 'stroke_compensation';
project = ['c',num2str(projectID,'%04.f')];
% Group
group = [project,'g',num2str(group,'%02.f')];
% Subject
subject = [group,'s',num2str(subject,'%04.f')];
% Session
dataName = [subject,'t',num2str(session,'%02.f')];
end