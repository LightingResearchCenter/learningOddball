function [p, pSigm, xLab, ylab, tit, l, compAnnot, yLimits] = plot_ERP_componentPlot(i, rows, cols, x, ERP_Jongsma, cycle, chName, chForIndexERP,componentNames, fieldName, style, parameters, handles)
                    
    % axis off
    box off

    if i <= 4 % ERP components                               
        y = ERP_Jongsma{cycle}.(chName{i}).(componentNames{i}).(fieldName).trials;
        sigm = ERP_Jongsma{cycle}.(chName{i}).(componentNames{i}).(fieldName).sigmoidParameters;
        p = plot(x, y, 'ko');
        ylab = ylabel('\muV');
        tit = title([strrep(componentNames{i}, '_', '-'), ' at ', (chName{i})]);
        yLimits = [min(y) max(y)];

    else % reaction time         
        y = ERP_Jongsma{cycle}.(chName{chForIndexERP}).(componentNames{i}).(fieldName).trials;           
        sigm = ERP_Jongsma{cycle}.(chName{chForIndexERP}).(componentNames{i}).(fieldName).sigmoidParameters;
        p = plot(x, y, 'ko');
        tit = title([componentNames{i}]);
        ylab = ylabel('ms');
        yLimits = [min(y) max(y)];
    end

    hold on
    xLoc = parameters.oddballTask.numberOfIrrTrialsPerCycle + 0.5;
    yLoc = get(gca, 'YLim');
    l = line([xLoc xLoc], yLoc);
    hold off

    % SIGMOID
    hold on
    pSigm = plot_drawSigmoid(x, y, sigm, parameters, handles);
    hold off

    if i == rows
        xLab = xlabel('target #');    
    else
        xLab = xlabel(' ');
    end

    if i == 3
        compAnnot = xlabel(fieldName);
    else
        compAnnot = xlabel(' ');
    end

end        