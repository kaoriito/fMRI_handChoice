function r35_featurer(studyPath,muscles)
% r35_featurer(studyPath)
%
% Developed on: Matlab 2019a

disp('> Feature calculator');

% Move to specified path
cd(studyPath);

% Get file names
files = ls('*.mat');
w = 1;
for q = 1:size(files,1)
    file(w,1) = {files(q,:)};
    w=w+1;
end

features = {'muscle','duration','peak','iemg','mean','ssi','var','rms',...
    'wl','mfa','pfa','mfp','pfp','theta','alpha','beta','gamma'};
% Which feature extraction was used (epochs come from 'epocher' or 'epocher2')
feat2 = false;

for c = 1:size(file,1) % Each .mat file in folder
    % Eliminate ' ' characters at the end of file name
    fileName = strip(file{c,:});
    disp(['feat > calculating: ',fileName]);
    
    % Baseline data
    if(contains(fileName,'baseline','IgnoreCase',false))
        % Read .mat
        load(fileName,'baseline');
        % Calculate features
        baseFeat = r35_fcalc(baseline.timeStamp,baseline.rectified(muscles,:));
        % Convert to Table
        baseT = array2table(baseFeat,'VariableNames',features);
        
        % MVC data
    elseif(contains(fileName,'mvc','IgnoreCase',false))
        % Read .mat
        load(fileName,'mvc');
        % Calculate features
        mvcTime = 0:1/2000:length(mvc{1,1}.rectified)/2000;
        mvcFeat = r35_fcalc(mvcTime,mvc{muscles(1),1}.rectified);
        for b = muscles(2:end)
            mvcFeat = cat(1,mvcFeat,r35_fcalc(mvcTime,mvc{b,1}.rectified));
        end
        mvcFeat(:,1) = muscles;
        % Convert to Table
        mvcT = array2table(mvcFeat,'VariableNames',features);
        
        % trial data
    elseif(contains(fileName,'marker_BASELINE','IgnoreCase',false))
        % Read .mat
        load(fileName,'sTrial');
        % Calculate features
        restFeat = r35_fcalc(sTrial{1,1}.timeStamp,...
            sTrial{1,1}.rectified(muscles,:));
        for b = 2:size(sTrial,1)
            restFeat = cat(1,restFeat,r35_fcalc(sTrial{b,1}.timeStamp,...
                sTrial{b,1}.rectified(muscles,:)));
        end
        % Convert to Table
        restT = array2table(restFeat,'VariableNames',features);
        
    elseif(contains(fileName,'marker_TARGET','IgnoreCase',false))
        % Read .mat
        load(fileName,'sTrial');
        % Calculate features
        activeFeat = r35_fcalc(sTrial{1,1}.timeStamp,...
            sTrial{1,1}.rectified(muscles,:));
        for b = 2:size(sTrial,1)
            activeFeat = cat(1,activeFeat,r35_fcalc(sTrial{b,1}.timeStamp,...
                sTrial{b,1}.rectified(muscles,:)));
        end
        % Convert to Table
        activeT = array2table(activeFeat,'VariableNames',features);
        
    elseif(contains(fileName,'trial','IgnoreCase',false))
        % Read .mat
        load(fileName,'sRest','sActive');
        % Calculate features
        restFeat = r35_fcalc(sRest{1,1}.timeStamp,...
            sRest{1,1}.rectified(muscles,:));
        activeFeat = r35_fcalc(sActive{1,1}.timeStamp,...
            sActive{1,1}.rectified(muscles,:));
        fprintf('%s',"Progress: ");
        for b = 2:size(sActive,1)
            if(mod(b,floor(size(sActive,1)/10))==0)
                fprintf('%c', '*');
            end
            restFeat = cat(1,restFeat,r35_fcalc(sRest{b,1}.timeStamp,...
                sRest{b,1}.rectified(muscles,:)));
            activeFeat = cat(1,activeFeat,r35_fcalc(sActive{b,1}.timeStamp,...
                sActive{b,1}.rectified(muscles,:)));
        end
        % Convert to Table
        restT = array2table(restFeat,'VariableNames',features);
        activeT = array2table(activeFeat,'VariableNames',features);
        
        feat2 = true;
    end
end

% Save data
if(feat2) 
    % Create output folder
    mkdir([studyPath,'EMGfeat2']);
    outDir = 'EMGfeat2';
else
    % Create output folder
    mkdir([studyPath,'EMGfeat']);
    outDir = 'EMGfeat';
end
save([studyPath,outDir,'\features','.mat'],...
    'baseFeat','baseT','mvcFeat','mvcT',...
    'restFeat','restT','activeFeat','activeT');
writetable(baseT,[studyPath,outDir,'\baseline','.csv']);
writetable(mvcT,[studyPath,outDir,'\mvc','.csv']);
writetable(restT,[studyPath,outDir,'\rest','.csv']);
writetable(activeT,[studyPath,outDir,'\active','.csv'])

disp('feat > done!')
end

function out = r35_fcalc(time,in)
if(length(time)>500)
    out = zeros(size(in,1),17);
    for a = 1:size(in,1) % each muscle
        out(a,1) = a; % muscle
        out(a,2) = time(end) - time(1); % time duration
        out(a,3) = r35_chunkProcessor(in(a,:),[],'peak',[]); % peak
        out(a,4) = r35_chunkProcessor(in(a,:),[],'integrate',[]); % iemg
        out(a,5) = r35_chunkProcessor(in(a,:),[],'mav',[]); % mean
        out(a,6) = r35_chunkProcessor(in(a,:),[],'ssi',[]); % squared intergral
        out(a,7) = r35_chunkProcessor(in(a,:),[],'var',[]); % variance
        out(a,8) = r35_chunkProcessor(in(a,:),[],'rms',[]); % rms
        out(a,9) = r35_chunkProcessor(in(a,:),[],'wl',[]); % wavelength
        cfg.sampleFrequency = 2000;
        inFFT = r35_chunkProcessor(in(a,:),cfg,'FFTamplitude',[]); % fourier
        inPSD = r35_chunkProcessor(in(a,:),cfg,'psd',[]); % power spectrum
        fftlim = find(inFFT.freqs>=5,1,'first'):find(inFFT.freqs>=200,1,'first'); % 5:200 Hz
        psdlim = find(inPSD.freqs>=5,1,'first'):find(inPSD.freqs>=200,1,'first'); % 5:200 Hz
        out(a,10) = meanfreq(inFFT.amplitude(fftlim),inFFT.freqs(fftlim)); % mean freqnecy amplitude
        out(a,11) = inFFT.freqs(find(inFFT.amplitude(fftlim)==max(inFFT.amplitude(fftlim)),1)); % peak freqnecy amplitude
        out(a,12) = meanfreq(inPSD.pxx(psdlim),inPSD.freqs(psdlim)); % mean frequency power
        out(a,13) = inPSD.freqs(find(inPSD.pxx(psdlim)==max(inPSD.pxx(psdlim)),1)); % peak frequency power
        out(a,14) = sum(inPSD.pxx(find(inPSD.freqs>=4,1,'first'):find(inPSD.freqs>=7,1,'first'))); % theta power
        out(a,15) = sum(inPSD.pxx(find(inPSD.freqs>=8,1,'first'):find(inPSD.freqs>=15,1,'first'))); % alpha power
        out(a,16) = sum(inPSD.pxx(find(inPSD.freqs>=16,1,'first'):find(inPSD.freqs>=30,1,'first'))); % beta power
        out(a,17) = sum(inPSD.pxx(find(inPSD.freqs>=31,1,'first'):find(inPSD.freqs>=100,1,'first'))); % gamma power
    end
else
    out = nan(size(in,1),17);
end
end