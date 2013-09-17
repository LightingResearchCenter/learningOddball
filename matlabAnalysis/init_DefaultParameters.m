function parameters = init_DefaultParameters(handles)

    %% BIOSEMI Channel Definitions
    
        parameters.BioSemi.chName{1} = 'Ref_RightEar'; 
        parameters.BioSemi.chName{2} = 'Ref_LeftEar'; 
        parameters.BioSemi.chName{3} = 'Fz'; % ch3 - EX3: Fz
        parameters.BioSemi.chName{4} = 'Cz'; % ch4 - EX4: Cz
        parameters.BioSemi.chName{5} = 'Pz'; % ch5 - EX5: Pz
        parameters.BioSemi.chName{6} = 'Oz'; % ch6 - EX6: Oz
        parameters.BioSemi.chName{7} = 'EOG'; % ch7 - EX7: EOG (was put below the right eye)
        parameters.BioSemi.chName{8} = 'HR'; % ch8 - EX8: Heart Rate (was put on the chest)   
        parameters.BioSemi.chOffset = 2; % number of channels to omit (i.e. the reference channels)

            % The input trigger signals are saved in an extra channel (the status channel), with the same sample rate as the electrode channels.
            % http://www.biosemi.com/faq/trigger_signals.htm
            parameters.BioSemi.chName{9} = 'Status/Trigger';            

        % Inverse polarity (if P300 is negative and N2 is positive)
        parameters.EEG.invertPolarity = 0;

        % Defines the signals to be read from the BDF file    
        parameters.SignalsToRead = [1 2 3 4 5 6 7 8 9]; % Channels 1-8 and 9 is the Trigger (17)

        % Define triggers

            % Button 1 & 2
            % Standard Tone
            % Oddball Tone
            % Irregular Cycle
            % Recording start 

            % http://www.biosemi.com/faq/trigger_signals.htm
            parameters.triggerSignals.buttons = [1 2];
            parameters.triggerSignals.stdTone = 10;
            parameters.triggerSignals.oddTone = 9;
            parameters.triggerSignals.irrCycle = 11;
            parameters.triggerSignals.recON = 12;            

            parameters.triggerPrecision = 24; % 24 bits, http://www.biosemi.com/faq/trigger_signals.htm

        % General EEG Parameters
        % parameters.EEG.srate - read automatically during import of individual BDF file
        parameters.EEG.nrOfChannels = 4; % number of EEG channels
            
    %% Band-pass filter parameters
    
        % for discussion of the filter limits, you can see for example:
        
            % Acunzo DJ, MacKenzie G, van Rossum MCW. 2012. 
            % Systematic biases in early ERP and ERF components as a result of high-pass filtering. 
            % Journal of Neuroscience Methods 209:212–218. 
            % http://dx.doi.org/10.1016/j.jneumeth.2012.06.011.
            
            % Widmann A, Schröger E. 2012. 
            % Filter effects and filter artifacts in the analysis of electrophysiological data. 
            % Frontiers in Perception Science:233. 
            % http://dx.doi.org/10.3389/fpsyg.2012.00233.
    
        % GENERAL
        parameters.filter.bandPass_loFreq = 0.01;
        parameters.filter.bandPass_hiFreq = 40;
        parameters.filterOrder = 6; % filter order   
        parameters.filterOrderSteep = 100; % additional pass of filtering with steeper cut
        parameters.applySteepBandPass = 1;
        
            % 0.01 Hz recommended as low-cut off frequency for ERP by:
            % * Acunzo et al. (2012), http://dx.doi.org/10.1016/j.jneumeth.2012.06.011
            % * Luck SJ. 2005. An introduction to the event-related potential technique. Cambridge, Mass.: MIT Press.
        
        % ALPHA, see Barry et al. (2000), http://dx.doi.org/10.1016/S0167-8760(00)00114-8        
        parameters.filter.bandPass_Alpha_loFreq = 8;
        parameters.filter.bandPass_Alpha_hiFreq = 13;
        parameters.filterOrder_Alpha = 10; % filter order   
    
        % ERP
        parameters.filter.bandPass_ERP_loFreq = parameters.filter.bandPass_loFreq;
        parameters.filter.bandPass_ERP_hiFreq = 20;
        parameters.filterOrder_ERP = parameters.filterOrder; % filter order   
    
        % parameters for re-bandbass filtering for extracting the CNV
        parameters.filter.bandPass_CNV_loFreq = parameters.filter.bandPass_loFreq;
        parameters.filter.bandPass_CNV_hiFreq = 6;
        parameters.filterOrder_CNV = parameters.filterOrder; % filter order   
        
    
    %% Artifact rejection parameters    
    
        % Fixed thresholds
        parameters.artifacts.fixedThr = 100; % fixed threshold (uV) of artifacts    
                                             % 100 uV in Molnar et al. (2008), http://dx.doi.org/10.1111/j.1469-8986.2008.00648.x
        parameters.artifacts.fixedThrEOG = 70; % fixed threshold (uV) of EOG artifacts
                                               % 70 uV in e.g. Acunzo et al. (2012), http://dx.doi.org/10.1016/j.jneumeth.2012.06.011
        parameters.artifacts.applyFixedThrRemoval = 1; % convert values above threshold to NaN
        parameters.artifacts.applyFixedThrEOGRemoval = 1; % convert values above threshold to NaN
                        
            % fixed threshold "detrending parameters"
            % not that crucial if some distortion is introduced by too
            % aggressive low cut of 1 Hz for example, but without
            % detrending, finding threshold exceeding samples would be
            % rather impossible due to possible DC drifts and trends
            parameters.artifacts.fixedDetrendingLowCut = parameters.filter.bandPass_loFreq;
            parameters.artifacts.fixedDetrendingHighCut = 300;
            parameters.artifacts.fixedDetrendingOrder = parameters.filterOrder;
        
        % "Advanced artifact removal"
        parameters.artifacts.applyRegressEOG = 1; % apply regress_eog from BioSig to eliminate EOG/ECG-based artifacts
        parameters.artifacts.epochByEpochRemoveBaseline = 1; % use rmbase() to remove baseline before ICA
        parameters.artifacts.useICA = 0; % otherwise use the regress_eog
        parameters.artifacts.show_ICA_verbose = 1;
    
    %% Power spectrum analysis parameters
    
        parameters.powerAnalysis.tukeyWindowR = 0.10; % 0.10 equals to 10% cosine window
        parameters.powerAnalysis.segmentLength = 4.0; % xx second segment lengths for PWELCH
        parameters.powerAnalysis.nOverlap = 50; % overlap [%] between successive segments
        parameters.powerAnalysis.alphaRange = [parameters.filter.bandPass_Alpha_loFreq parameters.filter.bandPass_Alpha_hiFreq];
        parameters.powerAnalysis.alphaCh = [5 6] - 2; % Pz and Oz (-2 for ref channels)
            % for more details see: http://www.mathworks.com/help/signal/ref/pwelch.html
    
    %% Learning Oddball parameters
    
        parameters.oddballTask.numberOfIrrTrialsPerCycle = 8;
        parameters.oddballTask.numberOfRegTrialsPerCycle = 8;
        parameters.oddballTask.SOA_duration = 0.8; % [s], 
        parameters.oddballTask.ERP_duration = 0.50; % [s]
        parameters.oddballTask.ERP_baseline = 0.50; % [s], needed e.g. for ep_den
            % in seconds, note that the trigger is for the whole 800 ms, from
            % which we can trim some of the end away
            
            % DC Offset / Detrend correction (pre_epochToERPs --> )
            %{
            parameters.epochERP.detrendingLowCut = parameters.artifacts.fixedDetrendingLowCut;
            parameters.epochERP.detrendingHighCut = parameters.artifacts.fixedDetrendingHighCut;
            parameters.epochERP.detrendingOrder = 4;
            %}
            
            % Epoch baseline removel (remove the mean of the pre-stimulus
            % baseline period for example)
            parameters.oddballTask.baselineRemove_index1 = 1;
            parameters.oddballTask.baselineRemove_index2 = 0 - (-parameters.oddballTask.ERP_baseline); % 500 ms

            % for pre-stimulus power analysis
            % see e.g. Barry et al. (2000), http://dx.doi.org/10.1016/S0167-8760(00)00114-8
            parameters.oddballTask.preERP_power_segmentLength = parameters.oddballTask.ERP_baseline; % [s]
            parameters.oddballTask.preERP_power_tukeyWindowR = parameters.powerAnalysis.tukeyWindowR;
            parameters.oddballTask.preERP_power_nOverlap = parameters.powerAnalysis.nOverlap;
            parameters.oddballTask.preERP_IAF_range = [-4 1.5]; % from Klimesch 1999, or more tight [-3.5 1.0]

        % Fixed time windows for the ERP components (see. Jongsma 2006,
        % 2013), http://dx.doi.org/10.1016/j.clinph.2006.05.012 and
        % http://dx.doi.org/10.1016/j.clinph.2012.09.009

            % -300 to 0 ms both in Jongsma 2006 and 2013
            parameters.oddballTask.timeWindows.CNV = [-0.3 0];
                    % [-110 -10] ms in Molnar et al. (2008), http://dx.doi.org/10.1111/j.1469-8986.2008.00648.x

            % 180 ms to 220 ms in Jongsma 2006, 180ms to 280 ms in Jongsma 2013
            parameters.oddballTask.timeWindows.N2 = [0.180 0.270]; 

            % 350 ms to 430 ms in Jongsma 2006, 280 to 480 ms in Jongsma 2013
            parameters.oddballTask.timeWindows.P3 = [0.280 0.480];

    %% EP_DEN Parameters
    
        % parameters.ep_den.sr = 512; % sampling rate
        % parameters.ep_den.stim = 513; % stim
        % parameters.ep_den.samples = 1024; % number of samples

        % Jongsma et al. denoised the epoch twice, first for extracting the CNV
        % with a different scale setting, and then second time for the
        % remaining components    
        parameters.ep_den.scales_postStim = 8; % number of scales
        parameters.ep_den.scales_preStim = 10; % number of scales


        parameters.ep_den.plot_type ='coeff';  % 'coeff', 'bands', 'single', 'contour'
        parameters.ep_den.den_type = 'do_den'; %' do_den' or 'load_den_coeff' 
        parameters.ep_den.auto_den_type = 'NZT';  % 'Neigh' or 'NZT'

        % Sigmoid fit parameters
        parameters.sigmoid.sigmoidFunc = ''; % 'param4'


