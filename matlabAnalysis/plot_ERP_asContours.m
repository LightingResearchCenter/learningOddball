function [c,h,tit,xlab,ylab,zlab] = plot_ERP_asContours(t, noTrials, matrix, n, chName, contourMode, irregOrReg, erpOrCNV, colorBarLimits, style, parameters, handles)

    axis on                    
    
    [c,h] = contourf(t, 1:noTrials, matrix(:,1:noTrials)', n);                  
    
    tit = title([erpOrCNV, ' ', irregOrReg, ' at ', chName, ' (', contourMode, ')']);
    
    xlab = xlabel(' ');
    ylab = ylabel('Trials');
    zlab = zlabel('\muV');
    
    caxis(colorBarLimits)
    colorbar
