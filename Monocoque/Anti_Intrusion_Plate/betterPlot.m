function [] = betterPlot(figure,lineWidthBool)
        
    if nargin < 2
        lineWidthBool = true;
    end

    set(0,'CurrentFigure',figure)    
    ax = gca;
    lgd = legend;
    box on;
    grid on;
    ax.FontSize = 16;
    ax.TickLabelInterpreter = "latex";
    ax.XLabel.Interpreter = "latex";
    ax.YLabel.Interpreter = "latex";
    ax.ZLabel.Interpreter = "latex";

    lgd.Interpreter = "latex";
    lgd.FontSize = 13;
    
    if lineWidthBool
        hline = findobj(gcf, 'type', 'line');
        set(hline,'LineWidth',1.5)
    end
    
end

