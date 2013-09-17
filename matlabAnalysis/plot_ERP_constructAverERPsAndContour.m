function [numberOfTrials, regMatrix, irregMatrix, regMatrix_CNV, irregMatrix_CNV, averRaw_reg, averFilt_reg, averRaw_irreg, averFilt_irreg, averFilt_CNV_reg, averFilt_CNV_irreg, averRaw_CNV_reg, averRaw_CNV_irreg] = ...
    plot_ERP_constructAverERPsAndContour(epochsRaw_reg, epochsRaw_irreg, ...
                                         epochsRaw_CNV_reg, epochsRaw_CNV_irreg, ...
                                         epochsFilt_reg, epochsFilt_irreg, ...
                                         epochsFilt_CNV_reg, epochsFilt_CNV_irreg, ...
                                         chForIndexERP, chForIndexCNV, cycle, trialLimits, contourMode, parameters, handles)
        
    numberOfTrials = (trialLimits(2) - trialLimits(1) + 1);
    
    % [rowsIN_reg, colsIN_reg] = size(epochsFilt_reg{1});
    % [rowsIN_irreg, colsIN_irreg] = size(epochsFilt_reg{1});

    % Aver
    averRaw_reg = zeros(length(epochsRaw_reg{1}),numberOfTrials);
    averFilt_reg = zeros(length(epochsFilt_reg{1}),numberOfTrials);
    averRaw_irreg = zeros(length(epochsRaw_irreg{1}),numberOfTrials);
    averFilt_irreg = zeros(length(epochsFilt_irreg{1}),numberOfTrials);
    
    averFilt_CNV_reg = zeros(length(epochsFilt_CNV_reg{1}),numberOfTrials);
    averFilt_CNV_irreg = zeros(length(epochsFilt_CNV_irreg{1}),numberOfTrials);
    averRaw_CNV_reg = zeros(length(epochsRaw_CNV_reg{1}),numberOfTrials);
    averRaw_CNV_irreg = zeros(length(epochsRaw_CNV_irreg{1}),numberOfTrials);
    
    % Single-trial MATRIX (only denoised), for contour plot    
    noOfSamples = length(epochsFilt_reg{1});
    regMatrix   = zeros(noOfSamples, numberOfTrials);
    irregMatrix = zeros(noOfSamples, numberOfTrials);
    regMatrix_CNV   = zeros(noOfSamples, numberOfTrials);
    irregMatrix_CNV = zeros(noOfSamples, numberOfTrials);

    % Single-trial ERPs
    offset = trialLimits(1) - 1;
    for i = trialLimits(1) : trialLimits(2)

        % single trial
        %a = epochsFilt_reg{i}(:,ch);
        % b = epochsFilt_irreg{i}(:,ch);      
        if strcmp(contourMode, 'denoised') == 1
            regMatrix(:,i-offset) = epochsFilt_reg{i}(:,chForIndexERP);
            irregMatrix(:,i-offset) = epochsFilt_irreg{i}(:,chForIndexERP);
            regMatrix_CNV(:,i-offset) = epochsFilt_CNV_reg{i}(:,chForIndexERP);
            irregMatrix_CNV(:,i-offset) = epochsFilt_CNV_irreg{i}(:,chForIndexERP);
        elseif strcmp(contourMode, 'raw') == 1
            regMatrix(:,i-offset) = epochsRaw_reg{i}(:,chForIndexERP);
            irregMatrix(:,i-offset) = epochsRaw_irreg{i}(:,chForIndexERP);
            regMatrix_CNV(:,i-offset) = epochsRaw_CNV_reg{i}(:,chForIndexERP);
            irregMatrix_CNV(:,i-offset) = epochsRaw_CNV_irreg{i}(:,chForIndexERP);
        else
            contourMode
            error('Error with the contourMode definition, typo maybe?')
        end

        % aver accumulator
        averRaw_reg(:,i-offset) = epochsRaw_reg{i}(:,chForIndexERP);
        averFilt_reg(:,i-offset) = epochsFilt_reg{i}(:,chForIndexERP);
        averRaw_irreg(:,i-offset) = epochsRaw_irreg{i}(:,chForIndexERP);
        averFilt_irreg(:,i-offset) = epochsFilt_irreg{i}(:,chForIndexERP);            
        averFilt_CNV_reg(:,i-offset) = epochsFilt_CNV_reg{i}(:,chForIndexCNV);
        averFilt_CNV_irreg(:,i-offset) = epochsFilt_CNV_irreg{i}(:,chForIndexCNV);        
        averRaw_CNV_reg(:,i-offset) = epochsRaw_CNV_reg{i}(:,chForIndexCNV);
        averRaw_CNV_irreg(:,i-offset) = epochsRaw_CNV_irreg{i}(:,chForIndexCNV);
    end

    % Average ERP
    averRaw_reg = nanmean(averRaw_reg,2); % 2 for average to have one row vector
    averFilt_reg = nanmean(averFilt_reg,2);
    averRaw_irreg = nanmean(averRaw_irreg,2);
    averFilt_irreg = nanmean(averFilt_irreg,2);
    averFilt_CNV_reg = nanmean(averFilt_CNV_reg,2);
    averFilt_CNV_irreg = nanmean(averFilt_CNV_irreg,2);
    averRaw_CNV_reg = nanmean(averRaw_CNV_reg,2);
    averRaw_CNV_irreg = nanmean(averRaw_CNV_irreg,2);
    
    