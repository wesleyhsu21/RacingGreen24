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

x_theory = [0 3036]
y_theory = [0 50]


XYPlot = figure;
plot(x,y)
hold on
plot(x_theory,y_theory)
xlabel(xLab)
ylabel(yLab)
hold off
betterPlot(XYPlot)
legend('FEA','Theoretical',Location='southeast')
saveas(XYPlot, figName)

%% Area under
area = trapz(x,y) * 1e-3

close all