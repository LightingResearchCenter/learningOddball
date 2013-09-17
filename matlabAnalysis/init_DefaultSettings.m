function handles = init_DefaultSettings()

    % http://www.network-science.de/ascii/, font "rectangle"
    
        cl = fix(clock); hours = num2str(cl(4)); % get the current time
        if cl(5) < 10; mins = ['0', num2str(cl(5))]; else mins = num2str(cl(5)); end
        disp(' ');
        disp(' __                    _            _____   _   _ _       _ _ ')
        disp('|  |   ___ ___ ___ ___|_|___ ___   |     |_| |_| | |_ ___| | |')
        disp('|  |__| -_| .''|  _|   | |   | . |  |  |  | . | . | . | .''| | |')
        disp('|_____|___|__,|_| |_|_|_|_|_|_  |  |_____|___|___|___|__,|_|_|')
        disp('                            |___|                             ')
        disp(' ')
        disp(['Initiated: ', date, ', ', hours, ':', mins])
        disp('-------'); 
        
    handles.style.scrsz = get(0,'ScreenSize'); % get screen size for plotting
        
    % General debug switch
    handles.flags.showDebugMessages = 0;
    handles.flags.showDebugPlots = 0;
    handles.flags.saveDebugMATs = 1; % takes quite a lot space from HDD, but easier to develop, 
                                     % no need to be ON when just using this
                                     % script and not adding anything new
                                     % Takes maybe roughly 25% more time to
                                     % process everything with this option
                                     % ON (depends on the speed of your HDD
                                     % though)

    %% PATHS

        % main paths 
        % change these only if you move the data somewhere else
        handles.path.homeFolder = '/home/petteri/'; % Unix home folder, for EEG Data
        handles.path.codeFolder = mfilename('fullpath'); % Setting the path for the code
        handles.path.codeFolder = strrep(handles.path.codeFolder, 'init_DefaultSettings',''); % Removing the filename from the path

            % derived pathnames
            % NO NEED to touch these unless you know what you are really doing
            handles.path.dataFolder = fullfile(handles.path.homeFolder, 'EEG-oddball');
            handles.path.debugMATs = fullfile(handles.path.dataFolder, 'debugMATs');
            
            handles.path.figuresOut = fullfile(handles.path.codeFolder, 'figuresOut');

    %% PLOT STYLING
    
        handles.style.scrsz = get(0,'ScreenSize'); % get screen size for plotting
        set(0,'DefaultFigureColor','w')
    
        handles.style.fontName = 'Latin Modern Roman';
        handles.style.fontSizeBase = 10;     
        handles.style.markerSize = 6;  
        handles.style.markerFaceColor = [0 0.4 1];
        handles.style.markerEdgeColor = 'none';
        handles.style.ERP_yLimits = [-10 15];
        handles.style.RT_limits = [-200 800];
           
        % settings when auto-saving figures, see exportfig.m for more details
        handles.figureOut.ON                = 1;
        handles.figureOut.resolution        = '-r150';  
        handles.figureOut.format            = 'png';        
        handles.figureOut.antialiasLevel    = '-a1';