function pSigm = plot_drawSigmoid(x, y, sigm, parameters, handles)

    % upsample the x (trials) so that the curve looks a bit smoother
    upScaleFactor = 10;
    x = linspace(min(x), max(x), upScaleFactor*length(x));
    
    yFit = sigmoid_4param(sigm,x);    
    pSigm = plot(x, yFit);
    
   