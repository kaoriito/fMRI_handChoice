%% EMG LSL Preprocessor
% Reads CSV files, extracts emg streams and calculates features for each
% session
%
% Developed on: Matlab 2019a
%
%%
clear;
close all;
clc;

s = [5,7]; t = 1;
preProc(0,s,t,'xdf','leap');
preProc(0,s,t,'filt','leap');
% preProc(0,s,t,'base');
% preProc(0,s,t,'epoch');
% preProc(0,s,t,'feat')


%[fileName,pathName] = uigetfile('*.mat');

%%
s = 1:2; t = 1:9;
% preProc(0,s,t,'xdf');
% preProc(0,s,t,'filt');
% preProc(0,s,t,'base');
% preProc(0,s,t,'epoch');
preProc(0,s,t,'feat')


%% Preprocessing Functions

% Raw xdf PreProcessing
function preProc(group,subjects,sessions,procType,dataType)
% xdfPreProcess(group#,subject#,sessionsArray)

disp('> R35preroc')
for grp = group
    disp(['R35preproc group: ',num2str(grp)]);
    for sub = subjects
        disp(['R35prepro subject: ',num2str(sub)]);
        for ses = sessions
            disp(['R35preproc session: ',num2str(ses)]);
            rPath = SetPaths4(grp,sub,ses);
            cd(rPath.func);
            switch procType
                case 'xdf'
                    disp('R35preproc > xdf reader');
                    r35_xdfReader(rPath.session,dataType)
                case 'filt'
                    disp('R35preproc > filter');
                    configuration = GetConfig(rPath.session);
                    r35_filter(rPath.session,configuration,dataType)
                case 'epoch'
                    disp('R35preproc > epocher');
%                     r35_epocher(rPath.session,'TARGET_ONSET','BASELINE')
%                     r35_epocher(rPath.session,'BASELINE','TARGET_ONSET')
                    r35_epocher2(rPath.session,'TARGET_ONSET','END_OF_TRIAL')
                case 'base'
                    disp('R35preproc > baseline & MVC');
                    r35_baseliner(rPath.session)
                case 'feat'
                    disp('R35preproc > feature calculator');
                    rPath = SetPaths3(grp,sub,ses);
                    r35_featurer(rPath.session,1:4)
            end
        end
    end
end
disp('Preprocessing done!');
end

% Set paths for files and functions, compliant with NPNL naming convention
function rPath = SetPaths(group, subject, session)
% Path for matlab functions
rPath.func = 'C:\Users\NPNL\Documents\GitHub\REINVENT_ModularGUI\Matlab\OfflineProcessing\';
% Path for study root
rPath.root = 'G:\Team Drives\NPNL\03_npnl_projects\02_current_studies\';
% Project
rPath.projectID = 28;
rPath.projectName = 'reinvent_emg';
rPath.project = [rPath.root,...
    'c',num2str(rPath.projectID,'%04.f'),'_',rPath.projectName,'\',...
    'c',num2str(rPath.projectID,'%04.f'),'_data\'];
% Group
rPath.groupID = group;
rPath.group = [rPath.project,...
    'g',num2str(rPath.groupID,'%02.f'),'\'];
% Subject
rPath.subjectID = subject;
rPath.subject = [rPath.group,...
    's',num2str(rPath.subjectID,'%04.f'),'\'];
% Session
rPath.sessionID = session;
rPath.session = [rPath.subject,...
    't',num2str(rPath.sessionID,'%02.f'),'\'];
end
function rPath = SetPaths2(group, subject, session)
% Path for matlab functions
rPath.func = 'C:\Users\NPNL\Documents\GitHub\REINVENT_ModularGUI\Matlab\OfflineProcessing\';
% Path for study root
rPath.root = 'G:\Team Drives\NPNL\03_npnl_projects\02_current_studies\';
% Project
rPath.projectID = 20;
rPath.projectName = 'reinvent_stroke_multiple_visits';
rPath.project = [rPath.root,...
    'c',num2str(rPath.projectID,'%04.f'),'_',rPath.projectName,'\',...
    'c',num2str(rPath.projectID,'%04.f'),'_data\'];
% Group
rPath.groupID = group;
rPath.group = [rPath.project,...
    'g',num2str(rPath.groupID,'%02.f'),'\'];
% Subject
rPath.subjectID = subject;
rPath.subject = [rPath.group,...
    's',num2str(rPath.subjectID,'%04.f'),'\'];
% Session
rPath.sessionID = session;
rPath.session = [rPath.subject,...
    't',num2str(rPath.sessionID,'%02.f'),'\'];
end
function rPath = SetPaths3(group, subject, session)
% Path for matlab functions
rPath.func = 'C:\Users\NPNL\Documents\GitHub\REINVENT_ModularGUI\Matlab\OfflineProcessing\';
% Path for study root
rPath.root = 'C:\Users\NPNL\Desktop\';
% Project
rPath.projectID = 28;
rPath.projectName = 'reinvent_emg';
rPath.project = [rPath.root,...
    'c',num2str(rPath.projectID,'%04.f'),'_data\'];
% Group
rPath.groupID = group;
rPath.group = [rPath.project,...
    'g',num2str(rPath.groupID,'%02.f'),'\'];
% Subject
rPath.subjectID = subject;
rPath.subject = [rPath.group,...
    's',num2str(rPath.subjectID,'%04.f'),'\'];
% Session
rPath.sessionID = session;
rPath.session = [rPath.subject,...
    't',num2str(rPath.sessionID,'%02.f'),'\'];
end
function rPath = SetPaths4(group, subject, session)
% Path for matlab functions
rPath.func = 'C:\Users\NPNL\Documents\GitHub\REINVENT_ModularGUI\Matlab\OfflineProcessing\';
% Path for study root
rPath.root = 'C:\Users\NPNL\Desktop\';
% Project
rPath.projectID = 24;
rPath.projectName = 'reinvent_emg';
rPath.project = [rPath.root,...
    'c',num2str(rPath.projectID,'%04.f'),'\'];
% Group
rPath.groupID = group;
rPath.group = [rPath.project,...
    'g',num2str(rPath.groupID,'%02.f'),'\'];
% Subject
rPath.subjectID = subject;
rPath.subject = [rPath.group,...
    's',num2str(rPath.subjectID,'%04.f'),'\'];
% Session
rPath.sessionID = session;
% rPath.session = [rPath.subject,...
%     't',num2str(rPath.sessionID,'%02.f'),'\'];
rPath.session = rPath.subject;
end


% Load configuration file, recorded from session
function configuration = GetConfig(configPath)
try % If session directory contains 'emg' folder
    cd(configPath);
    file = ls('*configuration*');
    if(~isempty(file))
        load([configPath,file],'configuration');
        disp('Configuration file loaded.');
    else
        disp('No configuration file found!');
        configuration = [];
    end
catch
    disp('No emg directory! Check if behavioral/TMS/MRI data.');
end
end

function score = getScores(type)
[~,sheets] = xlsfinfo(['gameScores.xlsx']);
num = cell(size(sheets,2),1);
score = num;
for a = 1:size(sheets,2)
    [num{a,1},~,~] = xlsread(['gameScores.xlsx'],a);
    
    if(a==1)
        d = 9;
    else
        d = 1;
    end
    
    if(strcmp(type,'score'))
        score{a,1} = num{a,1}(1:4,d:end);
    elseif(strcmp(type,'perceived'))
        score{a,1} = num{a,1}(7:10,d:end);
    end
end
end