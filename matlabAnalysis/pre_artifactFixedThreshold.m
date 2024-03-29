function [dataOut, NaN_indices, numberOfNaNs] = pre_artifactFixedThreshold(dataIn, EOG, parameters, handles)
    
    [dataSamples, dataChannels] = size(dataIn);
    
    % Use short variable names for detrending filtering
    loFreq = parameters.artifacts.fixedDetrendingLowCut;
    hiFreq = parameters.artifacts.fixedDetrendingHighCut;
    N = parameters.artifacts.fixedDetrendingOrder;
    dataIn_detrended = zeros(dataSamples, dataChannels);

    %% Use fixed threshold        
    
        if parameters.artifacts.applyFixedThrRemoval == 1     

            %{
            for i = 1 : dataChannels
                dataIn_DCoff(:,i) = (removedc(dataIn(:,i)', round(parameters.EEG.srate/2)))'; % remove DC offset first, function from ERPLAB
                dataIn_detrended(:,i) = detrend(dataIn_DCoff(:,i),'linear'); % detrend
            end
            %}
            % The above not really sufficient, better maybe to apply a
            % band-pass filter with a high cutoff frequency            

            for j = 1 : dataChannels                       
                dataIn_detrended(:,j) = pre_bandbassFilter(dataIn(:,j), parameters.EEG.srate, [hiFreq, loFreq], N, N*10, handles);   
                
                % check if output is valid
                nanIndices = isnan(dataIn_detrended(:,j));
                if length(dataIn_detrended(nanIndices,j)) == length(dataIn_detrended(:,j))
                    warning('NaN vector returned from bandpass filter, you probably used too high order, try to reduce and what happens, auto-reduce the order by 2 now')                    
                    N = N - 2; % reduce order, and try again
                    dataIn_detrended(:,j) = pre_bandbassFilter(dataIn(:,j), parameters.EEG.srate, [hiFreq, loFreq], N, N*10, handles);
                    nanIndices = isnan(dataIn_detrended(:,j));
                    if length(dataIn_detrended(nanIndices,j)) == length(dataIn_detrended(:,j))
                       error('NaN vector still returned, check what is the problem!') 
                    end                    
                end
            end

            % define indices
            NaN_indices_fixed = abs(dataIn_detrended) > parameters.artifacts.fixedThr; 

            % status on command window of how many artifacts were found
            numberOfNaNs = length(NaN_indices_fixed(NaN_indices_fixed == 1));
            NaNPercentage = (numberOfNaNs / (dataSamples*dataChannels)) * 100;
            disp(['     .. Fixed threshold - ',  'Number of NaNs: ', num2str(numberOfNaNs), ', percentage: ', num2str(NaNPercentage), '%'])

        else
            NaN_indices_fixed = zeros(length(dataIn(:,1)),1);
            disp(['     .. Artifacts not removed with fixed threshold'])                       
        end
    
    %% Find excessive eye movements 
    
        if parameters.artifacts.applyFixedThrEOGRemoval == 1
    
            % Detrend EOG first        
            EOG = pre_bandbassFilter(EOG, parameters.EEG.srate, [hiFreq, loFreq], N, N*10, handles);                

            % Find indices of threshold exceeding voltages
            NaN_indices_EOG = abs(EOG) > parameters.artifacts.fixedThrEOG;

            % status on command window of how many artifacts were found
            numberOfNaNs_EOG = length(NaN_indices_EOG(NaN_indices_EOG == 1));
            NaNPercentage = (numberOfNaNs_EOG / dataSamples) * 100;
            disp(['     .. .. EOG threshold - ',  'Number of NaNs: ', num2str(numberOfNaNs), ', percentage: ', num2str(NaNPercentage), '%'])
            
        else
            
            NaN_indices_EOG = zeros(length(dataIn(:,1)),1);
            disp(['     .. Artifacts not removed with EOG threshold'])  
            
        end

    %% Combine the indices
    
        % Now the _fixed indices have 4 columns (or the number of different
        % EEG channels that you have), whereas the EOG indices vector only
        % have one column so we need to replicate the EOG to match the
        % channels. We could do the vice versa as well
        [chRows, chCols] = size(NaN_indices_fixed);
        [eogRows, eogCols] = size(NaN_indices_EOG);
        repCount = chCols / eogCols;
        
        % replicate the rows
        NaN_indices_EOG = repmat(NaN_indices_EOG, 1, 4);
        
        NaN_indices = logical(NaN_indices_fixed + NaN_indices_EOG);
        dataOut = dataIn_detrended;
        dataOut(NaN_indices) = NaN;
        
        
    % DEBUG
    %{
    subplot(3,1,1)
        plot(dataIn)
    subplot(3,1,2)
        plot(dataIn_detrended)
        ylim([-200 200])
    subplot(3,1,3)
        plot(dataOut)
        ylim([-200 200])
        
    drawnow
    pause
    %}