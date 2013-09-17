function [alphaFixed, alphaIAF] = analyze_getBandAmplitude(f, ps_mean, ps_SD, alphaRange, IAF, IAF_range, handles)

    debugMatFileName = 'tempBandAmplitude.mat';
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

    % condition the IAF, so that it is rounded to one decimal precision
    precision = 10;
    IAF_range(1) = round(precision*(IAF_range(1) + IAF)) / precision;
    IAF_range(2) = round(precision*(IAF_range(2) + IAF)) / precision;
    
    % Get indices, note that now it is possible that exact frequency
    % matches are not found, so we want the closest index then
    [val1,fixed_ind1] = min(abs(f-alphaRange(1)));
    [val2,fixed_ind2] = min(abs(f-alphaRange(2)));
    [val3,IAF_ind1] = min(abs(f-IAF_range(1)));
    [val4,IAF_ind2] = min(abs(f-IAF_range(2)));
    
    % Get the 'alpha power spectrum band'
    
        % for fixed alpha range
        alphaAmplit_fixed = ps_mean(fixed_ind1:fixed_ind2);
        f_fixed = f(fixed_ind1:fixed_ind2);
    
        % for the individual alpha range
        alphaAmplit_IAF = ps_mean(IAF_ind1:IAF_ind2);
        f_IAF = f(IAF_ind1:IAF_ind2);
    
    % Calculate the Amplit
    alphaFixed = sqrt(sum(alphaAmplit_fixed .^ 2));
    alphaIAF = sqrt(sum(alphaAmplit_IAF .^ 2));

    % Debug
        if handles.flags.showDebugMessages == 1
            disp(['        IAF Frequency: ', num2str(IAF,4), ' Hz'])
            disp(['          Fixed range (match): ', num2str(f(fixed_ind1)), '-', num2str(f(fixed_ind2)), ' Hz'])
            disp(['            Fixed RMS: ', num2str(alphaFixed), ' uV'])
            disp(['              IAF range (match): ', num2str(f(IAF_ind1)), '-', num2str(f(IAF_ind2)), ' Hz'])
            disp(['                IAF RMS: ', num2str(alphaIAF), ' uV'])
        end

        if handles.flags.showDebugPlots == 1
            plot(f_fixed, alphaAmplit_fixed, 'b', f_IAF, alphaAmplit_IAF+1, 'r')
                legend('Fixed', 'IAF', 2, 'Location', 'Best'); legend('boxoff')
                xlabel('Hz'); ylabel('\muV');
                titStr = sprintf('%s\n%s', ['input freq resolution: ', num2str(f(2)-f(1)), ' Hz'], 'vertical displacement for visualization');
                title(titStr)
        end
