function plot_cyclePerCycleBehavior(ERP_Jongsma, epochs_Jongsma, compInd, chName, fieldName, chForIndex, parameters, style, oddballTask, handles)

    debugMatFileName = 'tempPlotCyclePerCycle.mat';
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
    nrOfCycles = length(epochs_Jongsma);
    
    % Subplot layout
    rows = 4;
    cols = 6;
    
    % Plot
    scrsz = handles.style.scrsz;
    fig = figure('Color', 'w');
        set(fig, 'Position', [0.15*scrsz(3) 0.08*scrsz(4) 0.8*scrsz(3) 0.91*scrsz(4)])
                
        %% 1st ROW
        chForIndex = 1; % Fz
        for i = 1 : nrOfCycles
            
            sp(i) = subplot(rows, cols, i);              
            
                % re-assign data
                y = ERP_Jongsma{i}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).trials;
                sigm = ERP_Jongsma{i}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).sigmoidParameters;  
                
                % plot
                [p1(i),tit1(i),xlab(i),ylab(i),pSigm(i), yLimits(i,:)] = plot_trialPointsSub(i,x,y,sigm,compInd, chForIndex,componentNames,chName,parameters,handles);                
            
        end
        
        
        %% 2nd ROW
        
        chForIndex = 2; % Pz
        for i = i+1 : (nrOfCycles*2)
            
            sp(i) = subplot(rows, cols, i);              
            
                % re-assign data
                y = ERP_Jongsma{i-nrOfCycles}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).trials;
                sigm = ERP_Jongsma{i-nrOfCycles}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).sigmoidParameters;  
                
                % plot
                [p1(i),tit1(i),xlab(i),ylab(i),pSigm(i), yLimits(i,:)] = plot_trialPointsSub(i-nrOfCycles,x,y,sigm,compInd,chForIndex,componentNames,chName,parameters,handles);                
            
        end
        
        %% TRIAL DATA POINTS        
        
            i = i+1;
            chForIndex = 1; % Fz
            sp(i) = subplot(rows, cols, [i i+cols]);
                j = 1;
                [p2(j,:) ,tit2(j),xlab2(j),ylab2(j)] = plot_trialDataPointsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles);
        
            i = i+1;
            chForIndex = 2; % Pz
            sp(i) = subplot(rows, cols, [i i+cols]);
                j = j + 1;
                [p2(j,:) ,tit2(j),xlab2(j),ylab2(j)] = plot_trialDataPointsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles);
        
        %% TRIAL SIGMOID FITS
        
            i = i+1;
            chForIndex = 1; % Fz
            sp(i) = subplot(rows, cols, [i i+1 i+cols i+cols+1]);
                j = j + 1;
                [pSigm2(1,:),tit2(j),xlab2(j),ylab2(j)] = plot_trialSigmoidFitsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles);
                
            i = i+1;
            chForIndex = 2; % Pz
            sp(i) = subplot(rows, cols, [i+1 i+1 i+1+cols i+1+cols+1]);
                j = j + 1;
                [pSigm2(2,:),tit2(j),xlab2(j),ylab2(j)] = plot_trialSigmoidFitsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles);
                
        
    yLimits = [min(yLimits(:,1)) max(yLimits(:,2))];
        if yLimits(1) > 0
            yLimits(1) = 0;
        end
                
    % General styling
    set(sp, 'XLim', [1 oddballTask.numberOfIrrTrialsPerCycle+oddballTask.numberOfRegTrialsPerCycle], 'YLim', yLimits) % style.ERP_yLimits)    
    set(sp, 'XTick', 1:16, 'XTickLabel', [])
    set(sp, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase)        

    % set(p1, 'Color', [0.20 0.80 1], 'LineWidth', 2)       
    set(p1, 'MarkerSize', handles.style.markerSize, 'MarkerFaceColor', handles.style.markerFaceColor, 'MarkerEdgeColor', 'none')
    % set(l, 'Color', [0.871 0.921 0.980])
    
    set(pSigm, 'Color', [1 0.40 0.60])

    set(tit1, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
    set(tit2, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')

    set(ylab, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
    set(xlab, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
    
    set(ylab2, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
    set(xlab2, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase+1, 'FontWeight', 'bold')
    
    
    % Auto-SAVE
    try
        if handles.figureOut.ON == 1      
            drawnow
            dateStr = plot_getDateString(); % get current date as string
            %cd(path.outputFigures)            
            fileNameOut = sprintf('%s%s', 'plot_cyclePerCycle_', componentNames{compInd}, '_', strrep(handles.inputFile, '.bdf', ''), '.png');
            export_fig(fullfile(handles.path.figuresOut, fileNameOut), handles.figureOut.resolution, handles.figureOut.antialiasLevel, fig)
            %cd(path.code)
        end
    catch err
        err
        str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                      'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "File -> Set Path -> Add Folder"');
        error(str)
    end
    
    
%% SUBFUNCTIONS
    
    function [p,tit,xlab,ylab,pSigm, yLimits] = plot_trialPointsSub(i,x,y,sigm,compInd,chForIndex,componentNames,chName,parameters,handles)
        
        % Markers                
        p = plot(x, y, 'ko');
            hold on
            strr = sprintf('%s\n%s', ['Cycle ', num2str(i)], [strrep(componentNames{compInd}, '_', '-'), ' at ', chName{chForIndex}]);
            tit = title(strr);
            xlab = xlabel('Trial');
            ylab = ylabel('[\muV]');

        % Sigmoid plot                
        pSigm = plot_drawSigmoid(x, y, sigm, parameters, handles);
        hold off
        
        yLimits = [min(y) max(y)];
        
    function [p ,tit2,xlab2,ylab2] = plot_trialDataPointsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles)
        
        hold on
        for i = 1 : nrOfCycles
            y = ERP_Jongsma{i}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).trials;
            p(i) = plot(x, y, 'ko');
        end
        
        tit2 = title([strrep(componentNames{compInd}, '_', '-'), ' at ', chName{chForIndex}]);
        xlab2 = xlabel('Trial');
        ylab2 = ylabel('[\muV]');
        
        set(p, 'MarkerSize', handles.style.markerSize, 'MarkerFaceColor', handles.style.markerFaceColor, 'MarkerEdgeColor', 'none')
            set(p(1), 'MarkerFaceColor', [0 0 0])
            set(p(2), 'MarkerFaceColor', [1 0 0])
            set(p(3), 'MarkerFaceColor', [0 1 0])
            set(p(4), 'MarkerFaceColor', [0 0 1])
            if length(p) > 4
                set(p(5),  'MarkerFaceColor', [0 1 1])
                if length(p) > 5 
                    set(p(6),  'MarkerFaceColor', [1 1 0])
                end
            end    
            % whos
            
        
    function [pSigm,tit2,xlab2,ylab2,leg] = plot_trialSigmoidFitsPerCycle(x,ERP_Jongsma,nrOfCycles,compInd,chForIndex,componentNames,chName,fieldName,parameters,handles)
        
        hold on
        for i = 1 : nrOfCycles
            y = ERP_Jongsma{i}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).trials;
            sigm = ERP_Jongsma{i}.(chName{chForIndex}).(componentNames{compInd}).(fieldName).sigmoidParameters;
            pSigm(i) = plot_drawSigmoid(x, y, sigm, parameters, handles);
        end
        
        tit2 = title([strrep(componentNames{compInd}, '_', '-'), ' at ', chName{chForIndex}]);
        xlab2 = xlabel('Trial');
        ylab2 = ylabel('[\muV]');
        
        set(pSigm, 'Color', [0.20 0.80 1], 'LineWidth', 2)
            set(pSigm(1), 'Color', [0 0 0])
            set(pSigm(2), 'Color', [1 0 0])
            set(pSigm(3), 'Color', [0 1 0])
            set(pSigm(4), 'Color', [0 0 1])
            if length(pSigm) > 4
                set(pSigm(5),  'Color', [0 1 1])
                if length(pSigm) > 5 
                    set(pSigm(6),  'Color', [1 1 0])
                end
            end
            
            % whos
            length(pSigm) 
            if length(pSigm) <= 4
                leg = legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4');
            elseif length(pSigm) == 5                
                leg = legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5');
            elseif length(pSigm) == 6                
                leg = legend('Cycle 1', 'Cycle 2', 'Cycle 3', 'Cycle 4', 'Cycle 5', 'Cycle 6');
            end
                legend('boxoff')