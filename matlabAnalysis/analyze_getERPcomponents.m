function [ERP_components, epochs_ERP, epochs_ERP_CNV, epochs_ERP_raw, epochs_ERP_filt, epochs_ERP_CNV_filt, timeVector] ...
        = analyze_getERPcomponents(epochs_ep, epochs_ep_CNV, epochs_raw, epochs_filt, epochs_CNV_filt, timeWindows, parameters, handles)

    debugMatFileName = 'tempERPAnalysis.mat';
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
    
    % INPUTS
    %{
    epochs_ep.RT_regular
    epochs_ep.RT_irregular
    epochs_ep.samplesPerEpoch        
    epochs_ep.irregularIndices
    epochs_ep.regularIndices
    %}       
    
    % Loop through the epochs (i.e. the ERPs for oddballs), the channels in
    % other words, as the epochs are concatenated into single vector    
        
        [rowsIn, colsIn] = size(epochs_ep.oddball_irregular);        
        
        % Irregulars
        for i = 1 : parameters.EEG.nrOfChannels
            chName = parameters.BioSemi.chName{i+parameters.BioSemi.chOffset};
            for j = 1 : length(epochs_ep.oddball_irregular)           
                
                [ERP_components.irregular.(chName){j}, timeVector] = analyze_perEpochFunction ('irreg', i, j, ...
                        epochs_ep.oddball_irregular{j}(:,i), epochs_ep.RT_irregular(j), ...
                        epochs_ep_CNV.oddball_irregular{j}(:,i), epochs_ep_CNV.RT_irregular(j), ...
                        timeWindows, parameters, parameters.EEG.srate, handles);
                    
                epochs_ERP.irregular.(chName){j}.epoch = epochs_ep.oddball_irregular{j}(:,i);
                epochs_ERP_CNV.irregular.(chName){j}.epoch = epochs_ep_CNV.oddball_irregular{j}(:,i);
                epochs_ERP_raw.irregular.(chName){j}.epoch = epochs_raw.oddball_irregular{j}(:,i);
                epochs_ERP_filt.irregular.(chName){j}.epoch = epochs_filt.oddball_irregular{j}(:,i);
                epochs_ERP_CNV_filt.irregular.(chName){j}.epoch = epochs_CNV_filt.oddball_irregular{j}(:,i);
                
                
                % plot(epochs_ERP.irregular.(chName){j}.epoch); title(['IRREGULAR i (ch) = ', num2str(i), ', j (trial) =', num2str(j)]); pause
            end
        end

        % Regulars
        for i = 1 : parameters.EEG.nrOfChannels
            chName = parameters.BioSemi.chName{i+parameters.BioSemi.chOffset};
            for j = 1 : length(epochs_ep.oddball_regular)     
                [ERP_components.regular.(chName){j}, timeVector] = analyze_perEpochFunction('reg', i, j, ...
                        epochs_ep.oddball_regular{j}(:,i), epochs_ep.RT_regular(j), ...
                        epochs_ep_CNV.oddball_regular{j}(:,i), epochs_ep_CNV.RT_regular(j), ...
                        timeWindows, parameters, parameters.EEG.srate, handles);    
                    
                epochs_ERP.regular.(chName){j}.epoch = epochs_ep.oddball_regular{j}(:,i);
                epochs_ERP_CNV.regular.(chName){j}.epoch = epochs_ep_CNV.oddball_regular{j}(:,i);
                epochs_ERP_raw.regular.(chName){j}.epoch = epochs_raw.oddball_regular{j}(:,i);
                epochs_ERP_filt.regular.(chName){j}.epoch = epochs_filt.oddball_regular{j}(:,i);
                epochs_ERP_CNV_filt.regular.(chName){j}.epoch = epochs_CNV_filt.oddball_regular{j}(:,i);
                
                % plot(epochs_ERP.irregular.(chName){j}.epoch); title(['REGULAR i (ch) = ', num2str(i), ', j (trial) =', num2str(j)]); pause
                
            end
        end
    
    function [components, timeVector] = analyze_perEpochFunction(condition, i, j, epoch, RT, epoch_CNV, RT_CNV, timeWindows, parameters, sampleRate, handles)
        
        % Time Windoes defined in "init_DefaultParameters.m" like other analysis parameters 
        %timeWindows
        %timeWindows.CNV
        %timeWindows.N2
        %timeWindows.P3
        
        numberOfSamplesPerEpoch = abs((-parameters.oddballTask.ERP_duration - parameters.oddballTask.ERP_baseline)) * sampleRate;
        timeVector = linspace(-parameters.oddballTask.ERP_baseline, parameters.oddballTask.ERP_duration, numberOfSamplesPerEpoch)';
        
        % plot(timeVector, epoch); title(['IR/REGULAR i (ch) = ', num2str(i), ', j (trial) =', num2str(j)]); pause
        
        %% Contingent Negative Variation (CNV)
        
            % e.g. Birbaumer et al. 1990. Slow potentials of the cerebral cortex and behavior. Physiol. Rev. 70:1–41. 
            %      http://www.ncbi.nlm.nih.gov/pubmed/2404287.
            %      Walter WG et al. 1964. Contingent Negative Variation : An Electric Sign of Sensori-Motor Association and Expectancy in the Human Brain. Nature 203:380–384. 
            %      http://dx.doi.org/10.1038/203380a0.

            % Fixed time window of -300 to 0 ms used in Jongsma et al.
            % (2006), http://dx.doi.org/10.1016/j.clinph.2006.05.012            
            components.CNV = analyze_perComponent(epoch_CNV, timeWindows.CNV, timeVector, sampleRate, condition, 'CNV', i, j, handles);
            
            
        %% N2 (or N2b)
        
            % Unexpected target stimuli give rise to a 'N2' component,
            % which is a centrally distributed negative wave appearing
            % before the P3, and considered intimately to be linked with P3
            % (e.g. Näätänen et al. (1981), http://dx.doi.org/10.1016/0301-0511(81)90034-X)
            
            % Fixed time window of 180 to 220 ms used in Jongsma et al.
            % (2006), http://dx.doi.org/10.1016/j.clinph.2006.05.012
            components.N2 = analyze_perComponent(epoch, timeWindows.N2, timeVector, sampleRate, condition, 'N2', i, j, handles);
        
        %% P3 
        
            % Fixed time window of 350 to 430 ms used in Jongsma et al.
            % (2006), http://dx.doi.org/10.1016/j.clinph.2006.05.012
            components.P3 = analyze_perComponent(epoch, timeWindows.P3, timeVector, sampleRate, condition, 'P3', i, j, handles);
        
        %% P3-N2
        
            % From Jongsma et al. (2006)
            % "In addition, since the N2 is considered to be intimately linked to the 
            % P3 (Daffner et al., 2000; Nuchpongsai et al., 1999; Näätänen et al., 1981), 
            % a P3–N2 component was constructed by subtracting the N2 amplitude from 
            % the P3 amplitude. This resulted in a more stable component, especially with regard
            %to the single-trial ERP analyses."
            components.P3_N2 = analyze_subtractN2fromP3(components.N2, components.P3, i, j, handles);

            
        %% RT (Reaction time)
        
            % Just take the previously computed reaction time and re-assign
            % to the output
            components.RT = RT;
        
        % whos
        % pause
    
        
%% SUBFUNCTIONS
        
    function component = analyze_perComponent(epoch, timeWindow, timeVector, sampleRate, condition, compString, i, j, handles)                       
            
            % Get indices for time points
            i1 = ceil(abs(((timeVector(1) - timeWindow(1)) * sampleRate) + 1));
            i2 = floor(abs(((timeVector(1) - timeWindow(2)) * sampleRate) + 1));
            
            % note that due to discrete sampling of the time it is
            % not always possible to get exact matches for the desired time
            % points (timeWindow), so that is why the start point is
            % "ceiling rounded", and the end point "floor rounded"
            if handles.flags.showDebugMessages == 1
                if i == 1 && j == 1 && strcmp(condition, 'irreg') == 1
                    %disp(' ')
                    %disp('From: analyze_getERPcomponents.m')
                    disp(['        ', compString])
                    disp(['         ..  Desired time window: ', num2str(timeWindow)])
                    disp(['         ..  Actual time window: ', num2str([timeVector(i1) timeVector(i2)])])            
                    % whos        
                end
            end
            
            timeOfInterest = timeVector(i1:i2);
            vectorOfInterest = epoch(i1:i2);
            
            % Mean amplitude the only parameter used in the paper of Jongsma et al.
            % (2006), http://dx.doi.org/10.1016/j.clinph.2006.05.012
            % and http://dx.doi.org/10.1016/j.clinph.2012.09.009            
            component.meanAmplit = nanmean(vectorOfInterest);
            
            if strcmp(compString, 'P3')
                % POSITIVE COMPONENTS
                [component.peakAmplit,I] = max(vectorOfInterest);
            elseif strcmp(compString, 'N2') || strcmp(compString, 'CNV')
                % NEGATIVE COMPONENTS
                [component.peakAmplit,I] = min(vectorOfInterest);
            end
            component.peakLatency = timeOfInterest(I);
            
                % in Jongsma et al. (2013) the component amplitude was
                % determined as the average of the time segment +- 10 ms
                % around the peak amplitude
                window_10msecInSamples = floor(0.010 * sampleRate);
                timePeakOfInterest = [I-window_10msecInSamples I+window_10msecInSamples];
                
                if timePeakOfInterest(1) < 1 
                    timePeakOfInterest(1) = 1; % no negative indices allowed
                end
                
                if timePeakOfInterest(2) > length(vectorOfInterest)
                    timePeakOfInterest(2) = length(vectorOfInterest); % can't be larger than the length of the vector
                end                
             
                component.peakMeanAmplit = nanmean(vectorOfInterest(timePeakOfInterest));
            
            % Mean latency could be calculated as the center-of-gravity of
            % the amplitude in similar fashion as gravity of individual
            % alpha frequency (IAF) done by Klimesch (1999)
                % "EEG alpha and theta oscillations reflect cognitive and memory performance: a review and analysis"
                % Brain Research Reviews 29:169–195. 
                % http://dx.doi.org/10.1016/S0165-0173(98)00056-3.
            
            % Just replace the frequency with time
            timeEstimates = vectorOfInterest .* timeOfInterest;
            sumOfTimeEstimates = nansum(timeEstimates);
            amplitudeSum = nansum(vectorOfInterest);

            % gravity now is the sum of spectral estimates divided by the power
            component.meanLatency = sumOfTimeEstimates / amplitudeSum;            
            
            % component
            % whos
            
    function P3_N2 = analyze_subtractN2fromP3(N2, P3, i, j, handles)
        
        componentNames = fieldnames(N2); % should be the same for P3
        
        for i = 1 : length(componentNames)
        
            % Note!
            % Now all the N2 components are subtracted from the P3
            % components whereas in the original publication of Jongsma et
            % al. (2006) only the amplitudes were subtracted, so one could
            % question whether the latency values have any value
            P3_N2.(componentNames{i}) = P3.(componentNames{i}) - N2.(componentNames{i});
            
        end
        
        
    