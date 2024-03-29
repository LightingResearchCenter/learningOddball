function plot_artifactRemovalPlot(t, epochIn, dataOut_afterMuscle, epochOut_afterFixedThreshold, epochOut_afterEOG_removal, ...
            epochOut_afterECG_removal, epochOut, ch, zoomRange, parameters, handles)
            
                    
        % DEBUG difference matrices
        diff_origFixed = epochIn - epochOut_afterFixedThreshold;
        diff_fixedEog = epochOut_afterFixedThreshold - epochOut_afterEOG_removal;
        diff_eogEcg = epochOut_afterEOG_removal - epochOut_afterECG_removal;
        diff_fixedEcg = epochOut_afterFixedThreshold - epochOut_afterECG_removal;
        diff_total = epochIn - epochOut_afterECG_removal;

        % debug plot
        scrsz = get(0,'ScreenSize'); % get screen size for plotting
        fig = figure('Color','w');      
            set(fig, 'Position', [0.05*scrsz(3) 0.15*scrsz(4) 0.92*scrsz(3) 0.9*scrsz(4)])                
            rows = 5;
            cols = 2;

        ch = 2; % 1 for Fz, 2 for Pz            

        i = 1;           
        sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, epochIn(:,ch), t, epochOut_afterFixedThreshold(:,ch));
            tit(i) = title(' ');

            i = 2;           
            sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, epochIn(:,ch), t, epochOut_afterFixedThreshold(:,ch));
            leg(1) = legend('In', 'After Fixed');
                legend('boxoff')

        i = 3;
        sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_origFixed(:,ch), t, diff_fixedEog(:,ch));
            tit(i) = title(' ');

            i = 4;
            sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_origFixed(:,ch), t, diff_fixedEog(:,ch));
            leg(2) = legend('Diff(In-Fixed)', 'Diff(Fixed-EOG)');
                legend('boxoff')

        i = 5;
        sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_fixedEcg(:,ch), t, diff_eogEcg(:,ch));
            tit(i) = title(' ');

            i = 6;
            sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_fixedEcg(:,ch), t, diff_eogEcg(:,ch));
            leg(3) = legend('Diff(Fixed-ECG)', 'Diff(EOG-ECG)');
                legend('boxoff')

        i = 7;
        sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_eogEcg(:,ch), t, diff_total(:,ch));
            tit(i) = title(' ');

            i = 8;
            sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, diff_eogEcg(:,ch), t, diff_total(:,ch));
            leg(4) = legend('Diff(EOG-ECG)', 'Diff(In-Out)');
                legend('boxoff')

        i = 9;
        sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, epochOut_afterFixedThreshold(:,ch), t, epochOut(:,ch));
            tit(i) = title(' ');

            i = 10;
            sp(i) = subplot(rows,cols,i); 
            p(i,:) = plot(t, epochOut_afterFixedThreshold(:,ch), t, epochOut(:,ch));
            leg(5) = legend('Fixed', 'Out');
                legend('boxoff')

        % STYLE            
        set(sp, 'XLim', [min(t) max(t)])
        set(sp([2 4 6 8 10]), 'XLim', zoomRange)

            set(sp([1 2]), 'YLim', 60*handles.style.ERP_yLimits)
            set(sp([9]), 'YLim', 10*handles.style.ERP_yLimits)
            set(sp([10]), 'YLim', 5*handles.style.ERP_yLimits)

        set(leg, 'Location', 'NorthEastOutside')

        % Auto-SAVE
        try
            if handles.figureOut.ON == 1      
                drawnow
                dateStr = plot_getDateString(); % get current date as string          
                fileNameOut = sprintf('%s%s', 'artifactRemoval_', strrep(handles.inputFile, '.bdf', ''), '.png');
                export_fig(fullfile(handles.path.figuresOut, fileNameOut), handles.figureOut.resolution, handles.figureOut.antialiasLevel, fig)
                %cd(path.code)
            end
        catch err
            err
            str = sprintf('%s\n%s', 'Crashing probably because you have not installed export_fig from Matlab File Exchange!', ...
                          'Download it from: http://www.mathworks.com/matlabcentral/fileexchange/23629-exportfig, and "File -> Set Path -> Add Folder"');
            error(str)
        end

        pause
