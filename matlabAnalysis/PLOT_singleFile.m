function PLOT_singleFile(ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_raw, ...
                        epochs_raw, epochs_filt, epochs_CNV_filt, epochs_ep, epochs_ep_CNV, info, handles)

    debugMatFileName = 'tempPlotSingleFile.mat';
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
    
    % INPUT EPOCHS
    % epochs_Jongsma
    % epochs_Jongsma_CNV
    % epochs_Jongsma_filt
    % epochs_Jongsma_raw
    % epochs_raw          - 1) Raw EEG without bandpass filtering, artifact rejection
    % epochs_filt         - 2) Bandbass and artifact rejected epochs
    % epochs_ep           - 3) EP Denoised epochs after _filt 

    disp(['  Plotting the data'])
    numberOfSamplesPerEpoch = abs((-handles.parameters.oddballTask.ERP_duration - handles.parameters.oddballTask.ERP_baseline)) * handles.parameters.EEG.srate;
    handles.parameters.oddballTask.timeVector = linspace(-handles.parameters.oddballTask.ERP_baseline, handles.parameters.oddballTask.ERP_duration, numberOfSamplesPerEpoch)';

    % Simple plot
    contourMode = 'raw'; % 'denoised' or 'raw', i.e. what ERP to display on the continuous contour plot
    % plot_indivSubject(handles.parameters.oddballTask.timeVector, epochs_ep, epochs_filt, contourMode, handles.parameters, handles.style, handles)

    contourMode = 'denoised'; % 'denoised' or 'raw', i.e. what ERP to display on the continuous contour plot
    % plot_indivSubject(handles.parameters.oddballTask.timeVector, epochs_ep, epochs_filt, contourMode, handles.parameters, handles.style, handles)

    %% Jongsma PLOTS

        % "Jongsma individual plot", Fig. 5 of Jongsma et al. (2006)
        chName = {'Fz'; 'Cz'; 'Cz'; 'Cz'}; % CNV / N2 / P3 / P3-N2
        fieldName = 'peakMeanAmplit';
        plot_indivJongsma(ERP_Jongsma, chName, fieldName, handles.parameters, handles.style, handles.parameters.oddballTask, handles)

        % "Jongsma individual cycle plot", Fig. 3 of Jongsma et al. (2013)
        chName = {'Fz'; 'Cz'; 'Cz'; 'Cz'}; % CNV / N2 / P3 / P3-N2
        chForIndexERP = 2; % 2 (Cz) for the ERP
        chForIndexCNV = 1; % 1 (Fz) for the CNV
        fieldName = 'peakMeanAmplit';
        cycle = 1;
        erpOrCNV = 'ERP';
                
        for cycle = 1 : 6
            plot_indivCycleJongsma(ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, ...
                                    epochs_raw, epochs_filt, epochs_CNV_filt, epochs_ep, epochs_ep_CNV, ...
                                    chName, fieldName, cycle, chForIndexERP, chForIndexCNV, ...
                                    contourMode, erpOrCNV, handles.parameters, handles.style, handles.parameters.oddballTask, handles)
                                
            % NOTE, the first ERP plot is not updated as a function of
            % cycle, check out why is that!?
            
        end        

        % ~"Fig. 2 of Jongsma et al. (2006): The Hypothesis plot
        chName = {'Fz'; 'Cz'; 'Cz'; 'Cz'}; % CNV / N2 / P3
        chForIndex = 2; % 2 (Cz) for the ERP                
        fieldName = 'peakMeanAmplit';

        compInd = 3; % P300
        % plot_cyclePerCycleBehavior(ERP_Jongsma, epochs_Jongsma, compInd, chName, fieldName, chForIndex, handles.parameters, handles.style, handles.parameters.oddballTask, handles)

        compInd = 4; % P3-N2
        % plot_cyclePerCycleBehavior(ERP_Jongsma, epochs_Jongsma, compInd, chName, fieldName, chForIndex, handles.parameters, handles.style, handles.parameters.oddballTask, handles)

