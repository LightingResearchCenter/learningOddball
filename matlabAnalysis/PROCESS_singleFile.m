function [ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, ...
        epochs_Jongsma_raw, epochs_raw, epochs_filt, epochs_CNV_filt, ...
        epochs_ep, epochs_ep_CNV, dataMatrix_filtGeneral, handles] = ...
                PROCESS_singleFile(inputFiles, fileNameIn, dataMatrixIn, triggers, handles)

    debugMatFileName = 'tempProcess.mat';
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
    
    disp(' ')                

    %% PRE-PROCESS THE DATA            

        % [rowsIn, colsIn] = size(dataMatrixIn); % e.g. a lot of rows x 8 channels
        offset = 2; % get rid of reference channels
    
        % remove the baseline (reference)
        dataMatrix = pre_removeReference(dataMatrixIn(:,1), dataMatrixIn(:,2), dataMatrixIn, offset, handles.parameters, handles);        
            
            
        %% GENERAL

            % General filtering if you need or want to compute something
            % general about the data which might be
            % * Power Analysis
            % * Detrended Fluctuation Analysis (DFA)
            % * Fractal Length analysis
            %   e.g. 
            dataType = 'General';
            matrixIn = dataMatrix;
            artifactIndices = []; % get them only once
            [rowsIn, colsIn] = size(matrixIn);
            rawMax = max(max(abs(matrixIn(:,1:handles.parameters.EEG.nrOfChannels))));
            
            % use subfunction wrapper
            [dataMatrix_filtGeneral, firstBandpassFilteredMatrix, artifactNaN_indices] ...
                = pre_componentArtifactFiltering(matrixIn, artifactIndices, rawMax, rowsIn, colsIn, ... % EEG matrix parameters
                handles.parameters.filter.bandPass_loFreq, handles.parameters.filter.bandPass_hiFreq, handles.parameters.filterOrder, handles.parameters.filterOrderSteep, ... % filter parameters
                dataType, handles.parameters, handles); % general settings                 
            
            
         %% ALPHA                   
         
            % Alpha-filtered ERP, as done by Barry et al. (2000) for
            % example, http://dx.doi.org/10.1016/S0167-8760(00)00114-8                   
            dataType = 'Alpha';
            matrixIn = firstBandpassFilteredMatrix;
            artifactIndices = artifactNaN_indices;
            [rowsIn, colsIn] = size(matrixIn);
            rawMax = max(max(abs(matrixIn(:,1:handles.parameters.EEG.nrOfChannels))));
            
            % use subfunction wrapper
            [dataMatrix_filtAlpha,~,~] = pre_componentArtifactFiltering(matrixIn, artifactIndices, rawMax, rowsIn, colsIn, ... % EEG matrix parameters
                handles.parameters.filter.bandPass_Alpha_loFreq, handles.parameters.filter.bandPass_Alpha_hiFreq, handles.parameters.filterOrder_Alpha, handles.parameters.filterOrderSteep, ... % filter parameters
                dataType, handles.parameters, handles); % general settings
            
            
        %% ERP
        
            % For ERP (P3, N2, P3-N2)
            dataType = 'ERP';
            matrixIn = firstBandpassFilteredMatrix;
            [rowsIn, colsIn] = size(matrixIn);
            rawMax = max(max(abs(matrixIn(:,1:handles.parameters.EEG.nrOfChannels))));
            
            % use subfunction wrapper
            [dataMatrix_filt,~,~] = pre_componentArtifactFiltering(matrixIn, artifactIndices, rawMax, rowsIn, colsIn, ... % EEG matrix parameters
                handles.parameters.filter.bandPass_ERP_loFreq, handles.parameters.filter.bandPass_ERP_hiFreq, handles.parameters.filterOrder, handles.parameters.filterOrderSteep, ... % filter parameters
                dataType, handles.parameters, handles); % general settings
            
            
        %% CNV
        
            % For CNV
            dataType = 'CNV';
            matrixIn = firstBandpassFilteredMatrix;
            [rowsIn, colsIn] = size(matrixIn);
            rawMax = max(max(abs(matrixIn(:,1:handles.parameters.EEG.nrOfChannels))));
            
            % use subfunction wrapper
            [dataMatrix_filt_CNV,~,~] = pre_componentArtifactFiltering(matrixIn, artifactIndices, rawMax, rowsIn, colsIn, ... % EEG matrix parameters
                handles.parameters.filter.bandPass_CNV_loFreq, handles.parameters.filter.bandPass_CNV_hiFreq, handles.parameters.filterOrder_CNV, handles.parameters.filterOrderSteep, ... % filter parameters
                dataType, handles.parameters, handles); % general settings
                                                                           
            
            % Debug plot for bandpass characteristics
            if handles.flags.showDebugPlots == 1
                plot_bandPassFilter(dataMatrix_filt_CNV(:,1:handles.parameters.EEG.nrOfChannels),...
                                    dataMatrix_filt(:,1:handles.parameters.EEG.nrOfChannels),...
                                    dataMatrix(:,1+offset:handles.parameters.EEG.nrOfChannels+offset), handles)
            end
            
            
        %% GENERAL Analysis
        disp(' ')
        disp('    Processing Time-series EEG')
    
            % PROCESS the "Time-Series EEG", i.e. al the channels without
            % ERP oddball epoching, artifacts removed and bandpass-filtered
           [alpha, amplitSpectrum, PSD] =  process_timeSeriesEEG(dataMatrix_filtGeneral(:,1:handles.parameters.EEG.nrOfChannels), ... % EEG
                                            dataMatrix_filtGeneral(:,handles.parameters.EEG.nrOfChannels+1:handles.parameters.EEG.nrOfChannels+1), ... % EOG
                                            dataMatrix_filtGeneral(:,handles.parameters.EEG.nrOfChannels+2:handles.parameters.EEG.nrOfChannels+2), ... % ECG
                                            triggers, handles.style, handles.parameters, handles);
                              

        %% Epoch the EEG
        % i.e. Split into Oddball and Standard Event-Related Potentials (ERPs)            
        disp('    Split recording to ERP epochs')  
            
            disp('     ERP FILTERED')  
            [epochs_filt, epochs_std_filt] = pre_epochToERPs(dataMatrix_filt(:,:), triggers, alpha, handles.parameters, 'filt', handles);              
            disp('     RAW')  
            [epochs_raw, epochs_std_raw] = pre_epochToERPs(dataMatrix_filtGeneral(:,:), triggers, alpha, handles.parameters, 'raw', handles);  
            disp('     CNV FILTERED')  
            [epochs_CNV_filt, epochs_CNV_std_filt] = pre_epochToERPs(dataMatrix_filt_CNV(:,:), triggers, alpha, handles.parameters, 'CNV', handles);
            disp('     ALPHA FILTERED')  
            [epochs_filtAlpha, epochs_std_filtAlpha] = pre_epochToERPs(dataMatrix_filtAlpha(:,:), triggers, alpha, handles.parameters, 'CNV', handles);
            

        % save EOG and ECG
        %{
        EOG = dataMatrix_filt(:,7-offset);
        EOG_CNV = dataMatrix_filt_CNV(:,7-offset);
        ECG = dataMatrix_filt(:,8-offset);
        ECG_CNV = dataMatrix_filt_CNV(:,8-offset);
        %}
        
            % release some memory
            clear dataMatrix    
            clear dataMatrix_filt
            clear ref
            clear triggersRaw
            clear triggers                 

            % Save into GDF?
            % http://en.wikipedia.org/wiki/General_Data_Format_for_Biomedical_Signals                       
            
    %% PRE-PROCESS the data for the DENOISING
    disp(' ')
    
        % We can do epoch by epoch correction, detrending epoch-by-epoch,
        % removing artifacts epoch-by-epoch if wanted
        if handles.parameters.artifacts.useICA == 1
            if handles.parameters.artifacts.epochByEpochRemoveBaseline == 1
                disp('    Epoch-by-epoch artifact/baseline correction to ERP epochs') 
                epochs_filt_corr = pre_correctEpochByEpoch(epochs_filt, 'ERP', handles.parameters, handles);
                epochs_CNV_filt_corr = pre_correctEpochByEpoch(epochs_CNV_filt, 'CNV', handles.parameters, handles);                    
            else
                disp('    Omitting Epoch-by-epoch artifact/baseline correction to ERP epochs') 
                epochs_filt_corr = epochs_filt;
                epochs_CNV_filt_corr = epochs_CNV_filt;
            end
        end
                        
        % EP_den auto requires all the epochs to be concatenated into a
        % single vector (single vector per channel)
        epochs_concan = pre_concatenateEpochs(epochs_filt, handles.parameters, handles);
        epochs_concan_CNV = pre_concatenateEpochs(epochs_CNV_filt, handles.parameters, handles);
        
        % ICA could be done here for the concatenated vector if needed, one
        % should be cautious though as the input vectors (channels) have
        % been already "artifact corrected" above in
        % "pre_artifactRemovalInputData" with the regress_eog method
        if handles.parameters.artifacts.useICA == 1
            epochs_concan_corr = pre_concatenateEpochs(epochs_filt_corr, handles.parameters, handles);
            epochs_concan_CNV_corr = pre_concatenateEpochs(epochs_CNV_filt_corr, handles.parameters, handles);
            disp('       Applying ICA ("runica" from EEGLAB) for artifact removal')
            epochs_concan = pre_artifactByICA(epochs_concan_corr, handles.parameters, handles);
            epochs_concan_CNV = pre_artifactByICA(epochs_concan_CNV_corr, handles.parameters, handles);
        else
            disp('       ICA not applied to the data')
        end

    %% DENOISE the EPOCHS to obtain single-trial ERPs without too much noise               

        % EP_den_auto 
        % ---------------------------------------------------------------------------------------
        % Ahmadi M, Quian Quiroga R. 2013. 
        % Automatic denoising of single-trial evoked potentials. 
        % NeuroImage 66:672–680. http://dx.doi.org/10.1016/j.neuroimage.2012.10.062.
        % Code: http://www2.le.ac.uk/centres/csn/software/ep_den
            disp('        Denoising the ERP epochs')

            % 1st to obtain the CNV            
            epochs_ep_CNV = denoise_ep_den_auto_Wrapper(epochs_concan_CNV, handles.parameters.ep_den.scales_preStim, handles.parameters, handles);

            % 2nd to obtain N2,P3 
            epochs_ep = denoise_ep_den_auto_Wrapper(epochs_concan, handles.parameters.ep_den.scales_postStim, handles.parameters, handles);

        % STEP / N1 measure, 
        % ----------------------------------------------------------------------------------------
        % Hu L, Mouraux A, Hu Y, Iannetti GD. 2010. 
        % A novel approach for enhancing the signal-to-noise ratio and detecting automatically event-related potentials (ERPs) in single trials. 
        % NeuroImage 50:99–111. http://dx.doi.org/10.1016/j.neuroimage.2009.12.010.
        % Code: http://iannettilab.webnode.com/n1measure/
        % epochs_N1 = denoise_n1measure_wrapper(epochs, handles.parameters, handles);

            % Might be hard to distinguish N1 from N2, and in the
            % papers of Jongsma et al., no N1 was analyzed so this
            % analysis is not done at the moment.

        % Additional post-smoothing (Jongsma et al. used 3-point moving
        % average if needed        

            % something if wanted

        % Deconcatenate back to cells of individual epochs
        epochs_ep = pre_deconcatenateEpochs(epochs_ep, handles.parameters, handles);
        epochs_ep_CNV = pre_deconcatenateEpochs(epochs_ep_CNV, handles.parameters, handles);

        % Trim the epochs so that the pre-onset baseline is removed,
        % input is now back in Cell (not concatenated)
            % epochs_ep = pre_removeBaseline(epochs_ep, handles.parameters, handles);
            % epochs_raw = pre_removeBaseline(epochs, handles.parameters, handles);

    %% Analyze the denoised epochs, i.e. get the ERP component amplitudes and latencies            

        % Get amplitudes, latencies, etc.
        disp('         Analyzing the ERP components')
        [ERP_components, epochs_ERP, epochs_ERP_CNV, epochs_ERP_raw, epochs_ERP_filt, epochs_ERP_CNV_filt, handles.parameters.oddballTask.timeVector] = ...
                analyze_getERPcomponents(epochs_ep, epochs_ep_CNV, epochs_raw, epochs_filt, epochs_CNV_filt, handles.parameters.oddballTask.timeWindows, handles.parameters, handles);
            
                    % ADD ALPHA

        % Group as in the papers of Jongsma et al. (2006,2013), fit the
        % sigmoids here as well
        disp('          Grouping the ERP components')
        [ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_raw, handles.parameters.oddballTask.numberOfCycles] = ...
                analyze_groupComponentsAsJongsma(ERP_components, epochs_ERP, epochs_ERP_CNV, epochs_ERP_raw, epochs_ERP_filt, epochs_ERP_CNV_filt, handles.parameters, handles);      
    
                    % ADD ALPHA
        
    
                              
        
                          
                          
    disp('       +++++         Processing of the file complete')
    disp(' ')