function chunkOut = r35_chunkProcessor(chunkIn,config,procType,baseline)
% chunkOut = r35_chunkProcessor(chunkIn,config,procType,plot,baseline)
%
% Developed on: Matlab 2019a
% References: (paper)
%
switch procType
    case 'voltage' % Myoware to V conversion
        % raw = boardPower/boardGain * (data/analogResolution - 1/2)
        % chunkOut = 3.3/1*(chunkIn/2^12-1/2);
        chunkOut = chunkIn./2000000;
    case 'zeroMean'
        chunkOut = chunkIn-mean(baseline,2);
    case 'filter'
        for c = 1 : size(chunkIn,1)
            chunkOut(c,:) = filtfilt(config.filter,chunkIn(c,:));
        end
    case 'rectify'
        chunkOut = abs(chunkIn);
    case 'smooth'
        for c = 1 : size(chunkIn,1)
            chunkOut(c,:) = conv(chunkIn(c,:),hamming(config.hammingWindow)./sum(hamming(config.hammingWindow)),'same');
        end
    case 'peak'
        chunkOut = max(chunkIn,[],2);
    case 'integrate'
        chunkOut = sum(chunkIn,2);
    case 'mav'
        chunkOut = mean(chunkIn,2);
    case 'mmav1'
        w = ones(1,size(chunkIn,2));
        w(1:floor(size(chunkIn,2)/4)) = 0.5;
        w(round(3*size(chunkIn,2)/4):size(chunkIn,2)) = 0.5;
        chunkOut = chunkIn*w'/size(chunkIn,2);
    case 'mmav2'
        w = ones(1,size(chunkIn,2));
        w(1:floor(size(chunkIn,2)/4)) = 4/size(chunkIn,2);
        w(round(3*size(chunkIn,2)/4):size(chunkIn,2)) = 4/size(chunkIn,2);
        chunkOut = chunkIn*w'/size(chunkIn,2);
    case 'ssi'
        chunkOut = sum(chunkIn.^2,2);
    case 'var'
        chunkOut = sum(chunkIn.^2,2)/(size(chunkIn,2)-1);
    case 'rms'
        chunkOut = rms(chunkIn,2);
    case 'wl'
        chunkOut = sum(abs(chunkIn(:,2:end)-chunkIn(:,1:end-1)),2);
%     case 'zc'
%         chunkOut =;
%     case 'ssc'
%         chunkOut =;
    case 'wamp'
        chunkOut = sum(abs(chunkIn(:,2:end)-chunkIn(:,1:end-1))>config.WAMPthr,2);
    case 'hemg'
        for c = 1 : size(chunkIn,1)
            h = histogram(chunkIn);
            h.BinEdges = config.histEdges;
            chunkOut(c,:) = h.Values;
        end
%     case 'arc'
%         chunkOut =;
%     case 'mnf'
%         chunkOut =;
%     case 'mdf'
%         chunkOut =;
%     case 'mmnf'
%         chunkOut =;
%     case 'mmdf'
%         chunkOut =;
    
    case 'FFTamplitude'
        for c = 1 : size(chunkIn,1)
            L = size(chunkIn,2); % Length of signal
            f = config.sampleFrequency*(0:round(L/2))/L; % Frecuencies
            chunkOut.freqs = f;
            % FFT
            Y = fft(chunkIn(c,:));
            chunkOut.fft(c,:) = Y;
            % Single-sided amplitude spectrum
            P2 = abs(Y/L);
            P1 = P2(1:round(L/2)+1);
            P1(2:end-1) = 2*P1(2:end-1);
            chunkOut.amplitude(c,:) = P1;
            %plot(f,P1)
        end
    case 'coherence'
        for c = 1 : size(chunkIn,1)
            [chunkOut.coherence(c).coherence, chunkOut.coherence(c).freqs]=mscohere(chunkIn(c,:),...
                chunkIn(c+1,:),...
                rectwin(config.hammingWindow),...
                0,config.hammingWindow,config.sampleFrequency);
            taper = rectwin(config.hammingWindow);
            overlap = 0;
            siglen = size(chunkIn,2);
            sigPval = 0.05;
            winlen=length(taper);
            L1=floor(siglen./winlen);
            L2 = floor( (L1-1)./(1-overlap) )+1;
            k=round(overlap*winlen);
            k2=ceil((1-overlap)*winlen);
            wprime_numerator=sum(taper(1:k).*taper(k2+1:end));
            wprime_denominator= sum(taper.^2);
            wprime=(wprime_numerator/wprime_denominator)^2;
            chunkOut.coherence(c).w = 1/(1+2*wprime);
            chunkOut.coherence(c).signif = 1-sigPval^(1/(coherence(c).w*L2-1));
        end
    case 'psd'
        for c = 1 : size(chunkIn,1)
            % Obtain Welch's overlapped segment averaging PSD estimate of the preceding signal.
            % Use a segment length of 500 samples with 300 overlapped samples.
            % Use 500 DFT points so that 100 Hz falls directly on a DFT bin.
            % Input the sample rate to output a vector of frequencies in Hz.
            % Plot the result. plot(f,10*log10(pxx))
            % https://www.mathworks.com/help/signal/ref/pwelch.html?s_tid=doc_ta
            [chunkOut.pxx(c,:),chunkOut.freqs] = pwelch(chunkIn(c,:),500,300,500,config.sampleFrequency);
            %plot(f,10*log10(pxx))
        end
end
end