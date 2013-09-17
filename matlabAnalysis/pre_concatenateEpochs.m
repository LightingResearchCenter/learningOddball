function epochs_concan = pre_concatenateEpochs(epochs, parameters, handles)

    debugMatFileName = 'tempConcatenate.mat';
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
    
    % assign RTs directly to output
    epochs_concan.RT_regular = epochs.RT_regular;
    epochs_concan.RT_irregular = epochs.RT_irregular;
    
    % also the samples per epoch
    epochs_concan.samplesPerEpoch = epochs.samplesPerEpoch;
    
    
    %% PRE-ALLOCATE

        totalLengthRegular = 0;
        [rowsIn, colsIn] = size(epochs.oddball_regular{1});
        for i = 1 : length(epochs.oddball_regular)
            epochs_concan.regularIndices{i}(1) = totalLengthRegular + 1; % start
            totalLengthRegular = totalLengthRegular + length(epochs.oddball_regular{i});
            epochs_concan.regularIndices{i}(2) = totalLengthRegular; % end
        end
        epochs_concan.oddball_regular = zeros(totalLengthRegular,colsIn);

        totalLengthIrregular = 0;
        [rowsIn, colsIn] = size(epochs.oddball_regular{1});
        for i = 1 : length(epochs.oddball_irregular)
            epochs_concan.irregularIndices{i}(1) = totalLengthIrregular + 1; % start
            totalLengthIrregular = totalLengthIrregular + length(epochs.oddball_irregular{i});
            epochs_concan.irregularIndices{i}(2) = totalLengthIrregular; % end
        end       
        epochs_concan.oddball_irregular = zeros(totalLengthIrregular,colsIn);
        
    %% ACTUALLY CONCATENATE
        
        for i = 1 : length(epochs.oddball_regular)
            i1 = epochs_concan.regularIndices{i}(1);
            i2 = epochs_concan.regularIndices{i}(2);
            % disp([i1 i2])
            % size(epochs.oddball_regular{i})
            epochs_concan.oddball_regular(i1:i2,:) = epochs.oddball_regular{i};
        end        
        
        for i = 1 : length(epochs.oddball_irregular)
            i1 = epochs_concan.irregularIndices{i}(1);
            i2 = epochs_concan.irregularIndices{i}(2);
            epochs_concan.oddball_irregular(i1:i2,:) = epochs.oddball_irregular{i};
        end
        
    
        