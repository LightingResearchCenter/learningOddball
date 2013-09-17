function epochs = pre_deconcatenateEpochs(epochs_concan, parameters, handles)

    debugMatFileName = 'tempDeconcenateEpochs.mat';
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
    epochs.RT_regular = epochs_concan.RT_regular;
    epochs.RT_irregular = epochs_concan.RT_irregular;
    
    % also the samples per epoch
    epochs.samplesPerEpoch = epochs_concan.samplesPerEpoch;
    
    % same for indices
    epochs.irregularIndices = epochs_concan.irregularIndices;
    epochs.regularIndices = epochs_concan.regularIndices;
            
    % DeCONCATENATE
        
        for i = 1 : length(epochs_concan.regularIndices)
            i1 = epochs_concan.regularIndices{i}(1);
            i2 = epochs_concan.regularIndices{i}(2);
            epochs.oddball_regular{i} = epochs_concan.oddball_regular(i1:i2,:);
        end        
        
        for i = 1 : length(epochs_concan.irregularIndices)
            i1 = epochs_concan.irregularIndices{i}(1);
            i2 = epochs_concan.irregularIndices{i}(2);
            epochs.oddball_irregular{i} = epochs_concan.oddball_irregular(i1:i2,:);
        end
        
    
    