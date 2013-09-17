function [alpha, amplit, PSD] = process_timeSeriesEEG(EEG, EOG, ECG, triggers, style, parameters, handles)
    
    debugMatFileName = 'tempTimeSeries.mat';
    if nargin == 0
        load('debugPath.mat')
        load(fullfile(path.debugMATs, debugMatFileName))
        close all
    else
        if handles.flags.saveDebugMATs == 1
            path = handles.path;
            save('debugPath.mat', 'path')
            save(fullfile(path.debugMATs, debugMatFileName))            
        end
    end
        
    % Channel-wise processing
    [samples,channels] = size(EEG);
    
    % Variable to be varied
    sL = parameters.powerAnalysis.segmentLength;
    
    
    for i = 1 : length(sL)
        
        parameters.powerAnalysis.segmentLength = sL(i);
        close all
    
        % Go through the channels
        for ch = 1 : channels
            disp(['       .. channel ', num2str(ch)])
            [f, amplit{ch}, PSD{ch}, amplit_matrix{ch}, PSD_matrix{ch}] = analyze_timeSeriesPerChannel(EEG(:,ch), parameters, handles); % subfunction           
            
        end
    
        %% Get Individual Alpha Peak
        
            % from Pz and Oz, create "alpha power spectrum
            alphaPowerSpectrum.amplit = (amplit{parameters.powerAnalysis.alphaCh(1)}.mean + amplit{parameters.powerAnalysis.alphaCh(2)}.mean) / 2;
            alphaPowerSpectrum.amplit_SD = sqrt(amplit{parameters.powerAnalysis.alphaCh(1)}.mean.^2 + amplit{parameters.powerAnalysis.alphaCh(2)}.mean.^2);
            alphaPowerSpectrum.PSD = (PSD{parameters.powerAnalysis.alphaCh(1)}.mean + PSD{parameters.powerAnalysis.alphaCh(2)}.mean) / 2;
            alphaPowerSpectrum.PSD_SD = sqrt(PSD{parameters.powerAnalysis.alphaCh(1)}.mean.^2 + PSD{parameters.powerAnalysis.alphaCh(2)}.mean.^2);         
            
            % Use subfunction to calculate the peak
            [alpha.amplit_peak, alpha.amplit_gravity] = analyze_findIndividualAlphaPeak(f, alphaPowerSpectrum.amplit, parameters.powerAnalysis.alphaRange);
            [alpha.PSD_peak, alpha.PSD_gravity] = analyze_findIndividualAlphaPeak(f, alphaPowerSpectrum.PSD, parameters.powerAnalysis.alphaRange);

            % Debug for command window
            disp(['    .. Amplitude Spectrum Alpha IAF peak = ', num2str(alpha.amplit_peak), ' Hz'])
            disp(['    .. .. Amplitude Spectrum Alpha IAF gravity = ', num2str(alpha.amplit_gravity), ' Hz'])
            %disp(['     PSD peak = ', num2str(alpha.PSD_peak), ' Hz'])
            %disp(['     PSD gravity = ', num2str(alpha.PSD_gravity), ' Hz'])
            
        
        % Debug plot
        if handles.flags.showDebugPlots == 1
            plot_powerSpectrumAnalysis(f, amplit, PSD, amplit_matrix, PSD_matrix, channels, style, parameters, handles)
        end
        
    end
    disp(' ')
        
        
        
    
    function [f, amplit, PSD, amplit_matrix, PSD_matrix, alpha] = analyze_timeSeriesPerChannel(EEGchannel, parameters, handles)        
        
        % General parameters
        Fs = parameters.EEG.srate; % sampling rate                                              
        
        %% Compute Power Spectrum        
        
            segmentLength = parameters.powerAnalysis.segmentLength * Fs;
            % segmentLength = segmentLength / 10;
            nfft = segmentLength;
            nOverlap = parameters.powerAnalysis.nOverlap; % in %
            nOverlap = 50;
            r = parameters.powerAnalysis.tukeyWindowR;       
            windowType = 'Tukey';
            freqRange = 0 : 0.1 : parameters.filter.bandPass_hiFreq;

            % trim the channel data to be an integer of sampling frequency
            P = nextpow2(length(EEGchannel));
            numberOfSegmentLengths = floor(length(EEGchannel) / segmentLength);
            EEGchannel = EEGchannel(1:(numberOfSegmentLengths*segmentLength));

            % Analyze POWER SPECTRUM with subfunction
            [f, amplit, PSD, amplit_matrix, PSD_matrix] = analyze_powerSpectrum(EEGchannel, Fs, windowType, r, segmentLength, nfft, freqRange, nOverlap, 'eegTimeSeries');
            
        