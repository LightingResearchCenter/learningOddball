function [l, p_filt, p_CNV_filt, p_CNV, p, leg, xlab, ylab, tit, yTickPos] = ...
            plot_ERP_perTrial(t, epochs_Jongsma, epochs_Jongsma_filt, epochs_Jongsma_CNV_filt, epochs_Jongsma_CNV, chName, cycle, chForIndexERP, chForIndexCNV, yOffset, style, parameters, handles)
        
            numberOfTargets = length(epochs_Jongsma{1}.(chName{1}));                   

                hold on
                for ij = 1 : numberOfTargets

                   yOff = yOffset*ij; % update the horizontal line (baseline)

                   y = epochs_Jongsma{cycle}.(chName{chForIndexERP}){ij};                            

                   % Horizontal line (baseline)
                   l(ij) = line([min(t) max(t)], [yOff yOff]);                                     

                   % Filtered
                   p_filt(ij) = plot(t, yOff + epochs_Jongsma_filt{cycle}.(chName{chForIndexERP}){ij});               

                   % CNV low-pass
                   p_CNV_filt(ij) = plot(t, yOff + epochs_Jongsma_CNV_filt{cycle}.(chName{chForIndexCNV}){ij});               

                   % CNV EP
                   p_CNV(ij) = plot(t, yOff + epochs_Jongsma_CNV{cycle}.(chName{chForIndexCNV}){ij});

                   % EP denoise
                   p(ij) = plot(t, yOff + y);

                   yTickPos(ij) = yOff; % save for yTick positions (Trial)
                                      
                   % Store the peak values (for debugging mainly)
                   maxVal.filtERP(ij) = max(epochs_Jongsma_filt{cycle}.(chName{chForIndexERP}){ij});
                   maxVal.filtCNV(ij) = max(epochs_Jongsma_CNV_filt{cycle}.(chName{chForIndexCNV}){ij});
                   maxVal.epERP(ij) = max(y);
                   maxVal.epCNV(ij) = max(epochs_Jongsma_CNV{cycle}.(chName{chForIndexCNV}){ij});

                end            

                leg = legend([p_filt(1) p_CNV_filt(1) p_CNV(1) p(1)], ['Filt. (',num2str(parameters.filter.bandPass_ERP_loFreq), '-', num2str(parameters.filter.bandPass_ERP_hiFreq), ' Hz)'],...
                                ['Filt. CNV (',num2str(parameters.filter.bandPass_CNV_loFreq), '-', num2str(parameters.filter.bandPass_CNV_hiFreq), ' Hz)'],...
                                ['CNV EP, scale: ', num2str(parameters.ep_den.scales_preStim)], ['ERP EP, scale: ', num2str(parameters.ep_den.scales_postStim)], 4);
                    legend('boxoff')   

                yLims = get(gca, 'YLim');

                l(ij+1) = line([0 0], [yLims(1) yLims(2)]); % time 0
                p3time1 = 1000 * parameters.oddballTask.timeWindows.P3(1);
                p3time2 = 1000 * parameters.oddballTask.timeWindows.P3(2);
                l(ij+2) = line([p3time1 p3time1], [yLims(1) yLims(2)]);
                l(ij+3) = line([p3time2 p3time2], [yLims(1) yLims(2)]);
                    txt(1) = text((p3time1+p3time2)/2, yTickPos(ij)*1.05, 'P3',...
                        'VerticalAlignment', 'top', 'HorizontalAlignment', 'center');

                hold off

                xlab = xlabel('Time [ms]');
                ylab = ylabel('Target #');
                titStr = sprintf('%s\n%s', ['Cycle ', num2str(cycle)], ['CNV at ', chName{chForIndexCNV}, ', and ERPs at ', chName{chForIndexERP}]);
                tit = title(titStr);            
                
        set(leg, 'Position',[0.1074 0.8894 0.1553 0.1092]);
        set(leg, 'FontName', handles.style.fontName, 'FontSize', handles.style.fontSizeBase-2)

        %Get the maximum of the accumulated max of each ERP
        maxVal.max_filtERP = max(maxVal.filtERP);
        maxVal.max_filtCNV = max(maxVal.filtCNV);
        maxVal.max_epERP = max(maxVal.epERP);
        maxVal.max_epCNV = max(maxVal.epCNV);

        % display on command window
        disp(['   ... max_ERP = ', num2str(maxVal.max_filtERP), ' uV'])
        disp(['   ... max_CNV = ', num2str(maxVal.max_filtCNV), ' uV'])
        disp(['   ... max_ERP EP = ', num2str(maxVal.max_epERP), ' uV'])
        disp(['   ... max_CNV EP = ', num2str(maxVal.max_epCNV), ' uV'])
        
        
        