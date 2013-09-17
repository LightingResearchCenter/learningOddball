function epochOut = pre_removeBaseline_epochByEpoch(epochIn, j, parameters, handles)
       
    % From ERPLAB:
    % http://erpinfo.org/erplab/erplab-documentation/documentation-archive-for-previous-versions/v1.x-documentation/erplab-manual/Epoching_Bins.htm
    % However, it does no harm to perform baseline correction at the epoching stage, 
    % and it may eliminate confusion if the epoched data are later exported to another system.  
    % Thus, we recommend that you perform baseline correction during the 
    % epoching process unless you have a good reason not to. 

    [rows,cols] = size(epochIn);
    x_in = (linspace(1,rows,rows))';
    epochOut_detr = zeros(rows,cols);
    epochOut_meanRemoved = zeros(rows,cols);

    % baseline period indices, detrend based on the pre-stimulus EEG only:
    basIndex1 = parameters.oddballTask.baselineRemove_index1; 
    basIndex2 = parameters.oddballTask.baselineRemove_index2 * parameters.EEG.srate;
    baseline_x = (linspace(1,basIndex2,basIndex2))';
    
    % REMOVE BASELINE, CHANNEL BY CHANNEL
    for i = 1 : cols
        
        % JUST REMOVE THE MEAN OF PRE-STIMULUS (or any other time period
        % specified above)
        meanOfBaselinePeriod = nanmean(epochIn(basIndex1:basIndex2,i));
        
        % if epoch contains NaNs in baseline, then the whole epoch is an
        % artifact
        if isnan(meanOfBaselinePeriod)
            epochIn(:,i) = NaN;
        else
            epochOut_meanRemoved(:,i) = epochIn(:,i) - meanOfBaselinePeriod;
        end
        
        %{
        plot(x_in, epochIn(:,i), 'r', x_in, epochOut_meanRemoved(:,i), 'k')
        pause(2.0)
        %}
        
        % DETREND
        
        %{
        % get the trend
        trendRemoved = detrend(epochIn(basIndex1:basIndex2,i), 'linear');
            % you could use 1st order polyfit as well, could be waster with
            % an analytic expression and no need to interpolate
        
        % subtract the removeTrend from input to get the actual trend as
        % the detrend cannot return it directly
        trend = epochIn(basIndex1:basIndex2,i) - trendRemoved;
        
        % now the trend has only a fraction (half to be exact if you use
        % the baseline before stimulus) of the original epoch datapoints so
        % we interpolate to the final length
        linearTrend = interp1(baseline_x, trend, x_in, 'linear', 'extrap');
                        
        epochOut_detr(:,i) = epochIn(:,i) - linearTrend;
        
            %{
            whos
            plot(x_in, epochIn(:,i), 'r', baseline_x, trend, 'y', x_in, linearTrend, 'b', baseline_x, trendRemoved, 'g', x_in, epochOut_detr(:,i), 'k')
            pause(2.0)
            %}
        %}
        
    end
    
    % RETURN
    epochOut = epochOut_meanRemoved;
    % epochOut = epochOut_detr;
    
    
    % FROM ERPLAB:
    % ------------
    % http://erpinfo.org/erplab/erplab-documentation/documentation-archive-for-previous-versions/v1.x-documentation/erplab-manual/Epoching_Bins.htm
    
        % The Baseline correction option allows you to enable or disable baseline correction.  
        % If enabled, you can select the period that will be used for baseline correction. 
        % If you select Pre, the prestimulus baseline period will be used (this is the default).  
        % You could instead select Post to use the poststimulus period or Whole to select the entire epoch.  
        % Finally, you could select Custom and then provide two numbers that specify the beginning 
        % and end of the baseline period (e.g., -50 50 to use the interval from -50 ms to +50 ms).  
        % The baseline period must be entirely within the period of the epoch.  
        % For whatever period you select, the mean voltage over this period will be subtracted 
        % from the waveform for a each epoch (separately for each channel).
    
    %{    
    
    epochOut_bp = zeros(rows,cols);
    
    epochOut_rmbas = zeros(rows,cols);
    epochOut_mean = zeros(rows,cols);

        % Use short variable names for detrending filtering
        loFreq = 0.01; % parameters.epochERP.detrendingLowCut;
        hiFreq = 300; % parameters.epochERP.detrendingHighCut;
        N = 4; % parameters.epochERP.detrendingOrder;

        % Bandpass filter
        for i = 1 : cols
            epochOut_bp(:,i) = pre_bandbassFilter(epochIn(:,i), parameters.EEG.srate, [hiFreq, loFreq], N, N*10, handles);   
        end

    % Detrending
    for i = 1 : cols
        epochOut_detr(:,i) = detrend(epochIn(:,i), 'linear');   
    end
        
    % Remove Bassline
    for i = 1 : cols
        [epochOut_rmbas(:,i), epochOut_mean(:,i)] = rmbase(epochIn(:,i));        
    end   
    
    % Debug
    cla
    hold on
    
    plot(epochOut_bp(:,1:1), 'g')
    plot(epochOut_detr(:,1:1), 'b')
    plot(epochOut_rmbas(:,1:1), 'k')
    plot(epochOut_mean(:,1:1), 'm') 
    
    plot(epochIn(:,1:1), 'r')
    
    hold off
    
        title(num2str(j))
        legend('BandPass', 'Detrend', 'rmbase', 'mean', 'In')
            legend('boxoff')
    
    pause(1.5)
    %}
    
    % Return 
    
    