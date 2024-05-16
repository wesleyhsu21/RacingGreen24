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

%% Composite
% 0 deg aligned with the car's direction of travel
% Assuming point force exactly in the centre of the plate
%% Dimensions
Length = 1000e-3;
Width = 320e-3;

%% Iteration 0 layup
layup_iteration_0_s = [0 0 0 -45 45 0 0 0 90 0 0 0 -45 45];
[A_0, B_0, D_0, ABD_0, Q_0, thickness_0] = ABD(layup_iteration_0_s);