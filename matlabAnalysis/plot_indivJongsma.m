function plot_indivJongsma(ERP_Jongsma, chName, fieldName, parameters, style, oddballTask, handles)

    debugMatFileName = 'tempIndivJongsma.mat';
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
    
    % Layout
    componentNames = fieldnames(ERP_Jongsma{1}.(chName{1}));
    fieldNames = fieldnames(ERP_Jongsma{1}.(chName{1}).(componentNames{1}));
    rows = oddballTask.numberOfCycles;
    cols = length(componentNames);
    
    x = (1:1:(parameters.oddballTask.numberOfIrrTrialsPerCycle+parameters.oddballTask.numberOfRegTrialsPerCycle))';    
    
    % Plot
    scrsz = handles.style.scrsz;
    fig = figure('Color', 'w');
        set(fig, 'Position', [0.1*scrsz(3) 0.1*scrsz(4) 0.85*scrsz(3) 0.85*scrsz(4)])
    
        % Go through the data, e.g. Fig 5 of Jongsma et al. (2006)
        for i = 1 : rows
            
            for j = 1 : cols
                
                ind = (((i-1) * cols) + j);
                
                    sp(ind) = subplot(rows, cols, ind);
                    
                    if j <= 4 % ERP components
                        
                        sigm = ERP_Jongsma{i}.(chName{j}).(componentNames{j}).(fieldName).sigmoidParameters;  
                        y = ERP_Jongsma{i}.(chName{j}).(componentNames{j}).(fieldName).trials;
                        
                        p(ind) = plot(x, y, 'ko');
                        
                        hold on
                        xLoc = parameters.oddballTask.numberOfIrrTrialsPerCycle + 0.5;
                        yLoc = get(gca, 'YLim');
                        l(ind) = line([xLoc xLoc], yLoc);
                        pSigm(ind) = plot_drawSigmoid(x, y, sigm, parameters, handles);
                        hold off
                        % axis off
                        box off
                        
                        if i == 1
                            tit(j) = title([strrep(componentNames{j}, '_', '-'), ' at ', (chName{j})]);
                        end 
                        
                        if j == 1
                            ylab(i) = ylabel(['Cycle ', num2str(i)]);
                        end
                                                
                        
                        yLimits(i,j,:) = [min(y) max(y)];
                        
                    else % reaction time
                        
                        sigm = ERP_Jongsma{i}.(chName{1}).(componentNames{j}).(fieldName).sigmoidParameters;  
                        y = ERP_Jongsma{i}.(chName{1}).(componentNames{j}).(fieldName).trials;
                        
                        p(ind) = plot(x, y, 'ko');
                        
                        hold on
                        xLoc = parameters.oddballTask.numberOfIrrTrialsPerCycle + 0.5;
                        yLoc = get(gca, 'YLim');
                        l(ind) = line([xLoc xLoc], yLoc);
                        pSigm(ind) = plot_drawSigmoid(x, y, sigm, parameters, handles);
                        hold off
                        % axis off
                        box off
                        
                        if i == 1
                            tit(j) = title(componentNames{j});
                        end
                        
                        yLimits(i,j,:) = [min(y) max(y)];
                        
                    end
                    
                    if i == rows
                        xlab(j) = xlabel('Trial #');
                    end
                
                    
                
            end
            
        end
        
        yLimits = [min(min(yLimits(:,1:4,1))) max(max(yLimits(:,1:4,2)))];
        if yLimits(1) > 0
            yLimits(1) = 0;
        end
        
        % General styling
        set(sp, 'XLim', [1 oddballTask.numberOfIrrTrialsPerCycle+oddballTask.numberOfRegTrialsPerCycle])
        set(sp, 'XTick', 1:16, 'XTickLabel', [])
        
        set(sp, 'YLim', yLimits)
            if rows == 4
                set(sp([5 10 15 20]), 'YLim', style.RT_limits)
            elseif rows == 6
                set(sp([5 10 15 20 25 30]), 'YLim', style.RT_limits)
            end
            
        set(l, 'YData', yLimits)
            if rows == 4
                set(l([5 10 15 20]), 'YData', style.RT_limits)
            elseif rows == 6
                set(l([5 10 15 20 25 30]), 'YData', style.RT_limits)
            end
            
        set(sp, 'FontName', style.fontName, 'FontSize', style.fontSizeBase)
               
        set(p, 'MarkerSize', style.markerSize, 'MarkerFaceColor', style.markerFaceColor, 'MarkerEdgeColor', style.markerEdgeColor)
        set(l, 'Color', [.4 .4 .4])
        set(pSigm, 'Color', [1 0.40 0.60])
        
        set(tit, 'FontName', style.fontName, 'FontSize', style.fontSizeBase+1, 'FontWeight', 'bold')
        set(ylab, 'FontName', style.fontName, 'FontSize', style.fontSizeBase+1, 'FontWeight', 'bold')
        set(xlab, 'FontName', style.fontName, 'FontSize', style.fontSizeBase, 'FontWeight', 'bold')
       
        % Auto-SAVE
        try
            if handles.figureOut.ON == 1      
                drawnow
                dateStr = plot_getDateString(); % get current date as string          
                fileNameOut = sprintf('%s%s', 'plot_indivJongsma_', strrep(handles.inputFile, '.bdf', ''), '.png');
                export_fig(fullfile(handles.path.figuresOut, fileNameOut), handles.figureOut.resolution, handles.figureOut.antialiasLevel, fig)
                %cd(path.code)
            end
        catch err
            err
            str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                          'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "File -> Set Path -> Add Folder"');
            error(str)
        end
