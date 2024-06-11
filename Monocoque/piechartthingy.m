% Data for the pie chart
materials = {'IM7/8552', 'Redux 312', 'Aluminium Honeycomb', 'Aluminium AIP', 'Firewall ABS','Firewall Aluminium'};
costs = [3146.50, 238.67, 346.45, 7.10 74.13 79.20];

% Calculate percentages
percentages = (costs / sum(costs)) * 100;

% Create the labels with percentages
percentageLabels = cell(size(materials));
for i = 1:length(materials)
    percentageLabels{i} = sprintf('%s: %.2f%%', materials{i}, percentages(i));
end

% Create a pie chart
figure;
pie(costs);
%title('Cost Breakdown of Materials');

% Optional: Display legend
legend(percentageLabels, 'Location', 'southoutside', 'Orientation', 'horizontal');

%betterPlot(piechart)