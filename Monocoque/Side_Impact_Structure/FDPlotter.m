clear
clc
close all

% Force-Displacement Plotter
matName = "ThreePointBendFEA.mat";
figName = "TestFig.png";
yLab = 'Displacement / mm';
xLab = 'Force / N'

load(matName)
x = ThreePointBend.TestData(:,1)
y = ThreePointBend.TestData(:,2)


XYPlot = figure;
plot(x,y)
hold on
xlabel(xLab)
ylabel(yLab)
hold off
betterPlot(XYPlot)
legend("off")
saveas(XYPlot, figName)