function [epochs, oddballON] = pre_findOddballERP(data, triggers, alpha, baselineCorr, endOfEpochCorr, epochs, parameters, handles)

    j = 1;
        initCount = 0;
    irr = 1;
    reg = 1;
    
    % whos
    % length(data)
    % length(triggers.oddTone)
    
    fprintf('      .. ODDBALLS: ')   
    
    for i = 2 : (length(data) - 1)            
        
        if initCount == 0 || initCount ~= j
            oddballON(j,:) = [0 0]; % initialize
            initCount = j;
        end
        
        if triggers.oddTone(i) == 1 && triggers.oddTone(i-1) == 0

            oddballON(j,1) = i; % start               

            % add the preOnset baseline needed for ep_den
            oddballON(j,1) = oddballON(j,1) - baselineCorr;

        elseif triggers.oddTone(i) == 1 && triggers.oddTone(i+1) == 0 && oddballON(j,1) ~= 0

            oddballON(j,2) = i; % end
            durationOfOddballWithJitter(j) = oddballON(j,2) - (oddballON(j,1) + baselineCorr); % duration of oddball in samples            

            % correct the end to be exactly the same for all the epoch as
            % there is small jitter in the trigger durations, redundancy
            % here as now number of samples just added to start point, but
            % this part of the code kept here to quantify the actual jitter
            % if needed/wanted
            oddballON(j,2) = oddballON(j,1) + endOfEpochCorr -1;

            durationOfOddball(j) = oddballON(j,2) - oddballON(j,1);
            epochsRAW.oddball{j} = data(oddballON(j,1):oddballON(j,2), :); % time domain EEG of the oddball                          
            
            % remove the DC offset / drift / trend from the epoch
            epochsRAW.oddball{j} = pre_removeBaseline_epochByEpoch(epochsRAW.oddball{j}, j, parameters, handles);
            
            % Do power analysis of the baseline period before the
            % stimulus as done by Barry et al. (2000)
            [RMS_alphaFixed, RMS_alphaIAF] = pre_baselinePowerAnalysis(epochsRAW.oddball{j}, baselineCorr, alpha, parameters, handles);

            % vectors of time and button presses, if you need to output,
            % index these
            reactionRaw.timeVec = (-durationOfOddball(j):1:durationOfOddball(j))';
            reactionRaw.button  = triggers.button(oddballON(j,1) : (oddballON(j,2)+durationOfOddball(j)) );

            % Get the reaction time in seconds, note that the reaction time
            % could be negative as the SOA is fixed and most likely some
            % people start anticipating the following std tone
            ind = find(reactionRaw.button == 1, 1, 'first');
            if ~isempty(ind)
                epochsRaw.RT(j) = reactionRaw.timeVec(ind) / parameters.EEG.srate;
            else
                epochsRaw.RT(j) = NaN; % lapse, no reaction time found during the following std tone
            end

            % separate to irregular and regular
            if triggers.irrCycle(i) == 1                
                epochs.oddball_irregular{irr} = epochsRAW.oddball{j};
                epochs.RT_irregular(irr) = epochsRaw.RT(j);
                epochs.alphaFixed_irregular(irr) = RMS_alphaFixed;
                epochs.alphaIAF_irregular(irr) = RMS_alphaIAF;                    
                irr = irr + 1;
                irregularOn(j,1) = 1;
            else
                epochs.oddball_regular{reg} = epochsRAW.oddball{j};
                epochs.RT_regular(reg) = epochsRaw.RT(j);
                epochs.alphaFixed_regular(reg) = RMS_alphaFixed;
                epochs.alphaIAF_regular(reg) = RMS_alphaIAF;
                reg = reg + 1;
                irregularOn(j,1) = 0;
            end

            j = j + 1; % increment the accumulator index
            
            if rem(j,8) == 0
                fprintf('%s%s', num2str(j), ' ')
            end
        else
            % do nothing
        end             
        
    end
    fprintf('%s\n', ' ') % line change    
    epochs.meanOddballDuration = nanmean(durationOfOddballWithJitter);
    epochs.meanOddballDurationStd = nanstd(durationOfOddballWithJitter);
    epochs.meanOddballDurationMilliSec = 1000*epochs.meanOddballDuration/parameters.EEG.srate;
    epochs.meanOddballDurationMilliSecStd = 1000*epochs.meanOddballDurationStd/parameters.EEG.srate;