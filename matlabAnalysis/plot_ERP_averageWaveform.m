function [p, xlab, ylab, leg, tit] = plot_ERP_averageWaveform(t, raw, filt, irregOrReg, erpOrCNV)

    hold on
    l = line([min(t) max(t)], [0 0], 'Color', [.4 .4 .4]);
    p(1) =  plot(t, raw, 'k');    
    p(2) =  plot(t, filt, 'b');
    hold off
    ylab = ylabel('\muV');
    xlab = xlabel('Time [ms]');
    leg = legend([p(1) p(2)],'Filt.', ['EP ', erpOrCNV], 2);
        legend('boxoff')
    tit = title('Average Waveform');
    
    