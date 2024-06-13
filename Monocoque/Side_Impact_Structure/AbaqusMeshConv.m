clear
clc
close all

x = [6 8 10 15 25 35 50];
y = [776 779 770 740 405 372 222];

meshConv = figure;
plot(x,y,"-")
hold on
xlabel('Base Size')
ylabel('Max Stress in 0$^{\circ}$ Plies / MPa')
betterPlot(meshConv)
hold off;
legend off
saveas(meshConv, "MeshConvergence.png")

close all