function [ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_raw, numberOfCycles] = ...
            analyze_groupComponentsAsJongsma(ERP_components, epochs_ERP, epochs_ERP_CNV, epochs_ERP_raw, epochs_ERP_filt, epochs_ERP_CNV_filt, parameters, handles)

    debugMatFileName = 'tempJongsmaGrouping.mat';
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

    chNames = fieldnames(ERP_components.irregular);
    x = (1:1:16);
    
    % Number of cycles should be the same, just to check here that nothing
    % weird / unexpected has happened to the data
    numberOfCycles_irr = length(ERP_components.irregular.(chNames{1})) / parameters.oddballTask.numberOfIrrTrialsPerCycle;
    numberOfCycles_reg = length(ERP_components.irregular.(chNames{1})) / parameters.oddballTask.numberOfRegTrialsPerCycle;
    
        if numberOfCycles_irr ~= numberOfCycles_reg
            error('Number of trials in irregular condition is not the same as for regular!')
        else
            % In the original paper of Jongsma et al. (2006,2013) there were 6
            % cycles
            numberOfCycles = numberOfCycles_reg; 
        end
    
    % To plot the data as in Fig. 3 of Jongsma et al. (2013)
    % http://dx.doi.org/10.1016/j.clinph.2012.09.009, 
    % or Fig. 5 of Jongsma et al. (2006), http://dx.doi.org/10.1016/j.clinph.2006.05.012
    
    % In other words take the first 8 trials from irregular and then
    % combine them with first 8 trials of regular condition, and then
    % repeat this for the number of cycles
    componentNames = fieldnames(ERP_components.irregular.(chNames{1}){1});
    fieldNames = fieldnames(ERP_components.irregular.(chNames{1}){1}.(componentNames{1}));
    
    for i = 1 : numberOfCycles
        
        i1 = parameters.oddballTask.numberOfIrrTrialsPerCycle;
        i2 = parameters.oddballTask.numberOfRegTrialsPerCycle;
        ind = (i-1)*i1 + 1;
        
        for j = 1 : length(componentNames) % CNV, N2, P3, RT
            
            for k = 1 : length(chNames) % Fz, Cz, Pz, Oz
                
                % irregular
                l_aux = 0;
                for l = ind : (ind + i1 - 1)
                    l_aux = l_aux + 1;
                    for m = 1 : length(fieldNames) % meanAmplit, peakAmplit, etc.   
                        
                        if j <= 4                            
                            a = ERP_components.irregular.(chNames{k}){l}.(componentNames{j}).(fieldNames{m});
                            ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).trials(l_aux) = a;
                        else % RT
                            try
                                a = 1000*ERP_components.irregular.(chNames{k}){l}.(componentNames{j}); % 1000 - to ms from sec
                            catch
                                error('Did you add some ERP components? Increase the quickndirty check j threshold couple of lines above this, and do the same below, as RT is a bit different than the other components')
                                
                            end
                            ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).trials(l_aux) = a;
                        end                            
                        
                    end    
                    
                    if j == 1                        
                        epochs_Jongsma{i}.(chNames{k}){l_aux} = epochs_ERP.irregular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_CNV{i}.(chNames{k}){l_aux} = epochs_ERP_CNV.irregular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_filt{i}.(chNames{k}){l_aux} = epochs_ERP_filt.irregular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_raw{i}.(chNames{k}){l_aux} = epochs_ERP_raw.irregular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_CNV_filt{i}.(chNames{k}){l_aux} = epochs_ERP_CNV_filt.irregular.(chNames{k}){l_aux}.epoch;

                        % DEBUG
                        % plot(epochs_Jongsma{i}.(chNames{k}){l_aux}); 
                        % title(['REGULAR i (cycle) = ', num2str(i), ', k (channel) =', num2str(k), ', l (trial) =', num2str(l_aux)]); 
                        % pause(1.0)
                    end
                    
                end
                
                % regular
                l_aux = 0;
                for l = ind : (ind + i2 - 1)
                    l_aux = l_aux + 1;
                    
                    for m = 1 : length(fieldNames) % meanAmplit, peakAmplit, etc.        
                        if j <= 4
                            b =  ERP_components.regular.(chNames{k}){l}.(componentNames{j}).(fieldNames{m});
                            ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).trials(l_aux+i1) = b;
                        else % RT
                            b =  1000*ERP_components.regular.(chNames{k}){l}.(componentNames{j}); % 1000 - to ms from sec
                            ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).trials(l_aux+i1) = b;
                        end
                        % [i j k l m]
                    end
                    
                    if j == 1
                        epochs_Jongsma{i}.(chNames{k}){l_aux+i1} = epochs_ERP.regular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_CNV{i}.(chNames{k}){l_aux+i1} = epochs_ERP_CNV.regular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_filt{i}.(chNames{k}){l_aux+i1} = epochs_ERP_filt.regular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_raw{i}.(chNames{k}){l_aux+i1} = epochs_ERP_raw.regular.(chNames{k}){l_aux}.epoch;
                        epochs_Jongsma_CNV_filt{i}.(chNames{k}){l_aux+i1} = epochs_ERP_CNV_filt.regular.(chNames{k}){l_aux}.epoch;
                    end
                    
                end                
                
                warning off
                for m = 1 : length(fieldNames) % meanAmplit, peakAmplit, etc.                            
                    y = ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).trials;
                    ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m}).sigmoidParameters = analyze_fitSigmoids(x, y, i, j, k, m, parameters, handles);                        
                end
                warning on
                
                
                % DEBUG
                %{
                bbb = ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m});
                if isstruct(bbb)
                    [i j k l m]
                    bbb
                    fieldNames{m}                    
                end
                %}
                
            end            
        end       
    end
    
    % b = ERP_Jongsma{i}.(chNames{k}).(componentNames{j}).(fieldNames{m})
    % whos
            