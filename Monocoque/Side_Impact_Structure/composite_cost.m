function [cost] = composite_cost(Layup_S,cost_per_m2,L,b)
no_layers = length(Layup_S) * 2;
prepreg_area = L * b * no_layers;% m^2
cost = prepreg_area * cost_per_m2;
end