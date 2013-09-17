function plot_indivCycleJongsma(ERP_Jongsma, epochs_Jongsma, epochs_Jongsma_CNV, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, ...
                                epochs_raw, epochs_filt,  epochs_CNV_filt, epochs_ep, epochs_ep_CNV,...
                                chName, fieldName, cycle, chForIndexERP, chForIndexCNV, ...
                                contourMode, erpOrCNV, parameters, style, oddballTask, handles)

    debugMatFileName = 'tempIndivJongsmaCycle.mat';
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
    
    x = (1:1:(parameters.oddballTask.numberOfIrrTrialsPerCycle+parameters.oddballTask.numberOfRegTrialsPerCycle))';
    t = 1000 * parameters.oddballTask.timeVector;
            
    componentNames = fieldnames(ERP_Jongsma{1}.(chName{1}));
    fieldNames = fieldnames(ERP_Jongsma{1}.(chName{1}).(componentNames{1}));
    
    % show only the current cycle in question
    trials = parameters.oddballTask.numberOfIrrTrialsPerCycle;
    trialLims = [(((cycle-1) * trials) + 1) (((cycle-1) * trials) + trials)];
    
    % Subplot layout
    rows = 5;
    cols = 8;
    
    % Plot
    scrsz = handles.style.scrsz;
    fig = figure('Color', 'w');
        set(fig, 'Position', [0.01*scrsz(3) 0.08*scrsz(4) 0.975*scrsz(3) 0.77*scrsz(4)])
    
        %% ERPs  per trial            
        
            sp(1) = subplot(rows, cols, [1 2 3 9 10 11 17 18 19 25 26 27 33 34 35]);
                        
                yOffset = 2.5 * style.ERP_yLimits(2); % vertical separation, [uV]
            
                % use subfunction
                [l, p1_filt, p1_CNV_filt, p1_CNV, p1, leg, xlab(1), ylab(1), tit1, yTickPos] = ...
                    plot_ERP_perTrial(t, epochs_Jongsma, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_CNV, ...
                    chName, cycle, chForIndexERP, chForIndexCNV, yOffset, style, parameters, handles);            
    
        
        %% COMPONENT SCATTER PLOT
        
            % Go through the data, e.g. Fig. 3 of Jongsma et al. (2013)
            for i = 1 : rows            

                ind = ((i-1) * cols) + (cols-5) + 1;
                    sp(i+1) = subplot(rows, cols, ind);                                                                    
                    
                    % use subfunction
                    [p2(i), pSigm(i), xlab(i+1), ylab(i+1), tit2(i), l2(i), compAnnot, yLimits(i,:)] = ...
                        plot_ERP_componentPlot(i, rows, cols, x, ERP_Jongsma, cycle, chName, chForIndexERP, componentNames, fieldName, style, parameters, handles);


            end
            i = i + 1;
                        
            % Get Y Limits
            componentLimits = [min(yLimits(1:4,1)) max(yLimits(1:4,2))];
            if componentLimits(1) == 0 && componentLimits(2) == 0
                componentLimits(2) = 1;
            end
              
            
            
        %% CONTOUR PLOT
                    
            i = i + 1;
            n = 64; % number of contours in contourPlot       
            colorBarLimits = [-15 25]; % [uV]
        
            % Re-Construct the data needed to plot the contour and the
            % average ERP
            [noTrials, regMatrix, irregMatrix, regMatrix_CNV, irregMatrix_CNV, ...
            averRaw_reg, averFilt_reg, averRaw_irreg, averFilt_irreg, ...
            averFilt_CNV_reg, averFilt_CNV_irreg, averRaw_CNV_reg, averRaw_CNV_irreg] = ...
                plot_ERP_constructAverERPsAndContour(epochs_filt.oddball_regular, epochs_filt.oddball_irregular, ...
                                                    epochs_CNV_filt.oddball_regular, epochs_CNV_filt.oddball_irregular, ...
                                                    epochs_ep.oddball_regular, epochs_ep.oddball_irregular, ...
                                                    epochs_ep_CNV.oddball_regular, epochs_ep_CNV.oddball_irregular, ...
                                                    chForIndexERP, chForIndexCNV, cycle, trialLims, contourMode, parameters, handles);
         
            sp(i) = subplot(rows, cols, [5 6 13 14 21 22]);
                j = 1;       
                if strcmp(erpOrCNV, 'ERP')
                    [c,h(j),tit3(j),xlab3(j),ylab3(j),zlab3(j)] = plot_ERP_asContours(t, noTrials, regMatrix, n, chName{chForIndexERP}, contourMode, 'Regular', erpOrCNV, colorBarLimits, style, parameters, handles);
                else
                    [c,h(j),tit3(j),xlab3(j),ylab3(j),zlab3(j)] = plot_ERP_asContours(t, noTrials, regMatrix_CNV, n, chName{chForIndexCNV}, contourMode, 'Regular', erpOrCNV, colorBarLimits, style, parameters, handles);
                end
        
            i = i + 1;
            sp(i) = subplot(rows, cols, [7 8 15 16 23 24]);
                j = 2;                
                if strcmp(erpOrCNV, 'ERP')
                    [c,h(j),tit3(j),xlab3(j),ylab3(j),zlab3(j)] = plot_ERP_asContours(t, noTrials, irregMatrix, n, chName{chForIndexERP}, contourMode, 'Irregular', erpOrCNV, colorBarLimits, style, parameters, handles);
                else
                    [c,h(j),tit3(j),xlab3(j),ylab3(j),zlab3(j)] = plot_ERP_asContours(t, noTrials, irregMatrix_CNV, n, chName{chForIndexCNV}, contourMode, 'Irregular', erpOrCNV, colorBarLimits, style, parameters, handles);
                end
            
            
        
        %% AVERAGE PLOTs
        
            i = i + 1;
            j = 1;
            sp(i) = subplot(rows,cols,[29 30]);        
                [p4(j, 1:2), xlab4(j), ylab4(j), leg4(j), tit4(j)] = plot_ERP_averageWaveform(t, averRaw_reg, averFilt_reg, 'Regular', 'ERP');                      

            i = i + 1;
            j = 2;
            sp(i) = subplot(rows,cols,[31 32]);        
                [p4(j, 1:2), xlab4(j), ylab4(j), leg4(j), tit4(j)] = plot_ERP_averageWaveform(t, averRaw_irreg, averFilt_irreg, 'Irregular', 'ERP');
        
            i = i + 1;
            j = 3;
            sp(i) = subplot(rows,cols,[37 38]);        
                [p4(j, 1:2), xlab4(j), ylab4(j), leg4(j), tit4(j)] = plot_ERP_averageWaveform(t, averRaw_CNV_reg, averFilt_CNV_reg, 'Regular', 'CNV');
                
            i = i + 1;
            j = 4;
            sp(i) = subplot(rows,cols,[39 40]);        
                [p4(j, 1:2), xlab4(j), ylab4(j), leg4(j), tit4(j)] = plot_ERP_averageWaveform(t, averRaw_CNV_irreg, averFilt_CNV_irreg, 'Irregular', 'CNV');

     
        %% General styling
        
            set(sp, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase)
                    
            % ERP Waveform
            set(sp(1), 'YTick', yTickPos, 'YTickLabel', num2str(x), 'YLim', [0 (oddballTask.numberOfIrrTrialsPerCycle+oddballTask.numberOfRegTrialsPerCycle+1)*yOffset])              
            set(p1, 'Color', [0.20 0.80 1], 'LineWidth', 2)      
                for i = 1 : 2 : length(p1)
                    %set(p1(i), 'Color', [0 .3 1]) % every other line other color
                end
            set(p1_CNV, 'Color', [0 0 0], 'LineWidth', 2)      
                for i = 1 : 2 : length(p1)
                    %set(p1_CNV(i), 'Color', [.4 .4 .4]) % every other line other color
                end

            set(p1_CNV_filt, 'Color', [1 0 0.2], 'LineWidth', 1)      
                for i = 1 : 2 : length(p1)
                    %set(p1_CNV_filt(i), 'Color', [1 0.34 0.47]) % every other line other color
                end

            set(p1_filt, 'Color', [0.2 0.8 0], 'LineWidth', 1)      
                for i = 1 : 2 : length(p1)
                    %set(p1_filt(i), 'Color', [0.463 0.878 0.322]) % every other line other color
                end

            % Components 
            set(sp(2:6), 'XLim', [1 oddballTask.numberOfIrrTrialsPerCycle+oddballTask.numberOfRegTrialsPerCycle], 'YLim', componentLimits)
                set(l2(1:4), 'YData', componentLimits) % fixed limits, style.ERP_yLimits
            set(sp(6), 'YLim', style.RT_limits)
                set(l2(5), 'YData', style.RT_limits)            
                set(sp(2:6), 'XTick', 1:16, 'XTickLabel', [])
                
            set(sp(7:end), 'XLim', [min(t) max(t)])            
                
            % Contour Plot
            set(h,'Edgecolor','none') 
            spacing = 1;
            yTicks = min(trialLims):spacing:max(trialLims);
            set(sp(7:8), 'YTick', yTicks, 'ZLim', colorBarLimits)            
                
                set(sp(7:8), 'YLim', [1 oddballTask.numberOfIrrTrialsPerCycle])
            
            % Average ERPs
            set(p4(:, 1), 'Color', [0.871 0.490 0]); % filtered
            set(p4(:, 2), 'Color', [0.122 0.463 1]); % denoised
            set(sp(9:end), 'YLim', [-10 10])
                
            set(l, 'Color', [0.871 0.921 0.980])
            set(l2, 'Color', [.4 .4 .4])
            set(p2, 'MarkerSize', handles.style.markerSize, 'MarkerFaceColor', handles.style.markerFaceColor, 'MarkerEdgeColor', 'none')
            set(pSigm, 'Color', [1 0.40 0.60])

            set(tit1, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+2, 'FontWeight', 'bold')
            set(tit2, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
            set(tit3, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
            set(tit4, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                set(tit4(3:4), 'String', '')
            
            set(leg4, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase-1, 'Location', 'Best')

            set(ylab, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                set(ylab3, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                set(ylab4, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
            set(xlab, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                    set(xlab(end), 'String', 'target #')
                    set(xlab(4), 'FontWeight', 'normal', 'FontAngle', 'italic')
                set(xlab3, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                set(xlab4, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
                    set(xlab4(1:2), 'String', '')
        
            
    %% Auto-SAVE
    
        try
            if handles.figureOut.ON == 1    
                drawnow
                dateStr = plot_getDateString(); % get current date as string
                %cd(path.outputFigures)            
                fileNameOut = sprintf('%s%s%s%s', 'plot_indivCycleJongsma_cycle', num2str(cycle), '_cnvScale', num2str(parameters.ep_den.scales_preStim), ...
                    '_erpScale', num2str(parameters.ep_den.scales_postStim), ...
                    '_f0Lo-', num2str(parameters.filter.bandPass_ERP_loFreq), 'Hz', ...
                    '_f0Hi-', num2str(parameters.filter.bandPass_ERP_hiFreq), 'Hz', ...
                    '_fCnvHi-', num2str(parameters.filter.bandPass_CNV_hiFreq), 'Hz', ...
                    '_', strrep(handles.inputFile, '.bdf', ''), '.png');
                export_fig(fullfile(handles.path.figuresOut, fileNameOut), handles.figureOut.resolution, handles.figureOut.antialiasLevel, fig)
                %cd(path.code)
            end
        catch err            
            if strcmp(err.identifier, '????')
                str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                              'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "File -> Set Path -> Add Folder"');
                error(str)
            else
                err
                err.identifier
            end
        end
        
        % At the moment, GIF animations are done manually from Terminal
        % (Ubuntu currently, MAC also, maybe works in Windows as well?)
        % using ImageMagick (http://www.imagemagick.org/Usage/anim_basics/), the output is slightly more aesthetic
        % install e.g. sudo apt-get install imagemagick
        % compared to the direct Matlab GIF animation output:
        % http://www.mathworks.com/support/solutions/en/data/1-48KECO/
        
            % e.g. 
            % convert -delay 150 *.png -loop 0 animation.gif
                % delay of 150 cs, i.e. 1500 ms, 1.5 sec
                % loop 0 : infinite number of repeats
            