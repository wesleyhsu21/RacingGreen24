clear
clc

%% Steel tube regulation
% Round tube
E_steel = 2e11;% Pa
sigma_y_steel = 3.05e8;
UTS_steel = 3.65e8;
sigma_y_weld_steel = 1.8e8;
UTS_weld_steel = 3e8;
no_steel_tubes = 3;
Outer_Diameter_steel = 25.4e-3;% m
Wall_Thickness_steel = 1.6e-3;% m
I_steel_individual = pi / 4 * ((Outer_Diameter_steel / 2)^4 - ((Outer_Diameter_steel - 2 * Wall_Thickness_steel) / 2)^4);% m^4
I_steel_total = I_steel_individual * no_steel_tubes;