 function plot_denSingleTrial(samples, stim, sr, av, denav, plot_type, sc, coeff, den_coeff, yo, y, YDEN, sweeps, max_contour)
        
     %plot average
     set(0,'DefaultFigureColor','w')
     figure('Position',[500 500 700 700])

     subplot(7,1,1:2)       
     plot(((1:samples)-stim+1)/sr,av, 'color',[0.6 0.6 0.6])
     hold on
     plot(((1:samples)-stim+1)/sr,denav, 'color','r')
     xlim([(1-stim+1)/sr (samples-stim+1)/sr])         
     title('Average ERP','fontsize',14)
     xlabel('Time (sec)','fontsize',10)

     switch plot_type
        case 'coeff'
           subplot(7,1,3:7)  
           step = 1/(sc+2):1/(sc+2):1;
            for i=1:sc+1
                scaling_factor = 1.5 * max(abs(coeff(i,:))) * (sc+1);
                aux1= coeff(i,:)/ scaling_factor;
                aux2=den_coeff(i,:)/scaling_factor;
                plot(((1:samples)-stim+1)/sr,aux1+step(sc+2-i),'color', [0.6 0.6 0.6])
                hold on
                plot(((1:samples)-stim+1)/sr,aux2+step(sc+2-i),'r')
            end
            for i=1:sc
                texto =['D' num2str(i)];
                text(-1.1,step(sc+2-i)+0.01,texto);
            end
            texto =['A' num2str(sc)];
            text(-1.1,step(1)+0.01,texto);
            axis off
             text(-0.1,0.05,'Time (sec)');
              text(-1.1,0.94,'(b) Wavelet Coefficients');

    case 'bands'
        subplot(7,1,3:7)  
        step = 1/(sc+2):1/(sc+2):1;
        scaling_factor = 1.5 * max(max(abs(yo))) * (sc+1);
        aux = y/ scaling_factor;
        aux_all = yo/ scaling_factor;
        for i=1:sc+1
            plot(((1:samples)-stim+1)/sr,aux_all(i,:)+step(sc+2-i),'color', [0.6 0.6 0.6])
            hold on
            plot(((1:samples)-stim+1)/sr,aux(i,:)+step(sc+2-i),'r')
        end   
        for i=1:sc
            texto =['D' num2str(i)];
            text(-1.1,step(sc+2-i)+0.01,texto);
        end
        texto =['A' num2str(sc)];
        text(-1.1,step(1)+0.01,texto);
        axis off

    case 'single'
        subplot(7,1,3:7)  
        nr_sweeps = min(sweeps,max_trials);
        scaling_factor = 1.7 * max(max(abs(xx))) * nr_sweeps;
        step = 1/(nr_sweeps+1):1/(nr_sweeps+1):1;
        aux_all = xx / scaling_factor;
        aux = YDEN / scaling_factor;                  
        for i=1:nr_sweeps;
            plot(((1:samples)-stim+1)/sr,aux_all(1+nr_sweeps-i,:)+step(i),'color', [0.6 0.6 0.6])
            hold on
            plot(((1:samples)-stim+1)/sr,aux(1+nr_sweeps-i,:)+step(i) ,'r')
        end
        for i=1:nr_sweeps
            texto =['#' num2str(1+nr_sweeps-i)];
            text(-1.1,step(i)+0.01,texto);
        end
        axis off

    case 'contour'
        subplot(7,1,3:7)
        axis on            
        nr_sweeps = min(sweeps,max_contour);
        [c,h]=contourf(((1:samples)-stim+1)/sr,1:nr_sweeps,YDEN(1:nr_sweeps,:),10);      
        set(h,'Edgecolor','none')
     end      


    %% Saving
    % save([save_path,save_filename],'YDEN','coeff','den_coeff','y','yo','denav','av','xx')


