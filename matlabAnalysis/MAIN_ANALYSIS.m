% MAIN FUNCTION for Learning Oddball EEG ANALYSIS
function MAIN_ANALYSIS()

    tic

    % Petteri Teikari, petteri.teikari@gmail.com, 2013
    % Lighting Research Center, Rensselaer Polytechnic Institute, Troy, NY
    close all
    clear all
    
    %% General Settings
    
        % i.e. like where the folders are, fonts to be used, colors, etc.
        handles = init_DefaultSettings(); % use a subfunction        

    %% Parameters for ANALYSIS
    
        % i.e. like artifact rejection thresholds, filter cutoffs,
        % numerical parameters for EEG analysis
        handles.parameters = init_DefaultParameters(handles); % use a subfunction        
    
    %% Define input
    
        %fileNameIn = 'ute1_6cycles_wECG.bdf';
        %fileNameIn = 'ute2_6cycles_wECG.bdf';
        %fileNameIn = 'petteri_4cycles_wECG.bdf';
        % fileNameIn = 'ellen2_6cycles_wECG.bdf';
        % fileNameIn = 'ute2_6cycles_wECG.bdf';
        
        filesIn = {'ute1_6cycles_wECG.bdf'; 'ute2_6cycles_wECG.bdf'; 'petteri_4cycles_wECG.bdf'; 'ellen2_6cycles_wECG.bdf'};
        filesIn = {'ute_eyesClosed_withLight.bdf'};
        fileNameIn = filesIn;
        
        handles.inputFile = fileNameIn;
        inputFiles = fullfile(handles.path.dataFolder, fileNameIn);
        if ~iscell(inputFiles) % for only one file
            numberOfFiles = 1;
        else
            numberOfFiles = length(inputFiles);
        end
           
        
    %% GO THROUGH THE FILES    
    
        % hiFreq = [10 12 14 16 20 24 28 32 36 40];
        % loFreq = [0.01 0.1 1];
        % cnvFreq = [1 2 3 4 5 6 7 8 9 10 12 14 16];
        % scales = 3:1:10;
    
        for i = 1 : 1 % length(filesIn)
            
            handles.inputFile = filesIn{i}; 
            inputFiles = fullfile(handles.path.dataFolder, filesIn{i});
            % disp(['cut-off high freq = ', num2str(hiFreq(i))])
            % handles.parameters.ep_den.scales_postStim = scales(i);
            % handles.parameters.filter.bandPass_CNV_hiFreq = cnvFreq(i);
            % handles.parameters.filter.bandPass_ERP_loFreq = loFreq(i);

            % IMPORT THE DATA
            % You could modify what is inside here if you have EEG recorded
            % with some other system than with BioSemi ActiveTwo
            [dataMatrix, triggers, info, handles.parameters.EEG.srate] = IMPORT_eegData(i, fileNameIn, inputFiles, handles);

            % PROCESS the ERP
            [ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_raw, ...
                epochs_raw, epochs_filt, epochs_CNV_filt, ...
                epochs_ep, epochs_ep_CNV, dataMatrix_filtGeneral, handles] = ...
                PROCESS_singleFile(inputFiles, fileNameIn, dataMatrix, triggers, handles);        
                % Check later what is coming out in handles and try to refer to
                % exact variables changed (like sampleRate)                    
            
                
            % PLOT        
            PLOT_singleFile(ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_raw, epochs_raw, epochs_filt, epochs_CNV_filt, epochs_ep, epochs_ep_CNV, info, handles)

        end
        
        toc