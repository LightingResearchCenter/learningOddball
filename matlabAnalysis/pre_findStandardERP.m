function [epochs, stdON] = pre_findStandardERP(data, triggers, alpha, oddballON, baselineCorr, endOfEpochCorr, epochsIn, parameters, handles)

    debugMatFileName = 'tempFindStdERP.mat';
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

    % Note that now the standard trigger maybe on for like 7 consecutive
    % standard tones and we don't have a trigger for the stimulus OFF
  
    j = 1;
    irr = 1;
    reg = 1;
    fprintf('      .. STANDARDS: ') 
    
    % triggers.stdTone
    for i = 2 : (length(data) - 1)
        
        if triggers.stdTone(i) == 1 && triggers.stdTone(i-1) == 0

            stdON(j,1) = i; % start               

            % add the preOnset baseline needed for ep_den
            stdON(j,1) = stdON(j,1) - baselineCorr;            

        elseif triggers.stdTone(i) == 1 && triggers.stdTone(i+1) == 0
            
            stdON(j,2) = i; % end
            durationOfStdWithJitter(j) = stdON(j,2) - stdON(j,1); % duration of std in samples  
            
            SOA_durationInSamples = parameters.oddballTask.SOA_duration * parameters.EEG.srate;
            numberOfStandards(j) = durationOfStdWithJitter(j) / SOA_durationInSamples;
            numberOfStandards(j) = floor(numberOfStandards(j));
            
                % some inaccuracy to match the standard without stimulus
                % offset triggers or triggers indicating the actual ON time
                % of the audio stimulus (put sinusoidal output to digital
                % inputs via amplifier for example)
            
            % Quick'n'dirty separation to individual
            numberOfSamplesPerStandard(j) = floor(durationOfStdWithJitter(j) / numberOfStandards(j));
            %indivStandards{j} = zeros(endOfEpochCorr, numberOfStandards(j));
            
                % correct later with WAV input? or correct the trigger!            
                        
                for ij = 1 : numberOfStandards(j)
                    ind1 = stdON(j,1) + (ij-1)*numberOfSamplesPerStandard(j) + 1;
                    if ind1 ~= 1 % not for the first standard tones of the file, otherwise index will be negative
                        ind1 = ind1 - baselineCorr; % add the preOnset baseline needed for ep_den
                    end
                    ind2 = ind1 + endOfEpochCorr -1;
                    stdToneEpoch = (data(ind1:ind2))';
                    indivStandards{j}(:,ij) = stdToneEpoch;
                end
            
            % We take the average of these standard tones to reduce data a
            % bit and make easier the comparison to oddball trials
            stdTone{j} = nanmean(indivStandards{j},2);
            
                % DEBUG
                %{
                subplot(2,1,1)
                    a = indivStandards{j};
                    plot(a); title('Average ERP')
                    
                subplot(2,1,2)
                    plot(stdTone{j}); title('Average STD ERP')
                %}
                    
            
            % Do power analysis of the baseline period before the
            % stimulus as done by Barry et al. (2000)
            [RMS_alphaFixed, RMS_alphaIAF] = pre_baselinePowerAnalysis(stdTone{j}, baselineCorr, alpha, parameters, handles);
            
            % separate to irregular and regular
            if triggers.irrCycle(i) == 1                
                epochs.stdTone_irregular{irr} = stdTone{j};                
                epochs.alphaFixed_irregular(irr) = RMS_alphaFixed;
                epochs.alphaIAF_irregular(irr) = RMS_alphaIAF;                    
                irr = irr + 1;
                irregularOn(j,1) = 1;
            else
                epochs.stdTone_regular{reg} = stdTone{j};                
                epochs.alphaFixed_regular(reg) = RMS_alphaFixed;
                epochs.alphaIAF_regular(reg) = RMS_alphaIAF;
                reg = reg + 1;
                irregularOn(j,1) = 0;
            end
            
            j = j + 1; % increment the accumulator index            
            if rem(j,8) == 0
                fprintf('%s%s', num2str(j), ' ')
            end         
            
        end
    end
    fprintf('%s\n', ' ') % line change