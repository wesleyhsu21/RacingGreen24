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
% Using ESDU83035 for estimation of stiffness

%% Dimensions
Length = 1000e-3;% m
Width = 320e-3;% m
% V_f = 0.577;% Fibre volume fraction
% V_m = 1 - V_f;% Matrix volume fraction
% rho_f = 1800;% Fibre density in kgm^-3
% rho_m = 1300;% Matrix density in kgm^-3
% E_f = 5.516e9;% Fibre modulus in Pa
% E_alpha = 161e9;% Layer modulus of elasticity in alpha direction
% E_m = (E_alpha - E_f * V_f) / V_m;% Matrix modulus

% nu_f = ;% Fibre poisson ratio
% nu_m = ;% Matrix poisson ratio
% nu_alpha_beta = nu_f * V_f + nu_m * V_m;% Layer poisson ratio for load applied in alpha direction

%% Iteration 0 layup
layup_iteration_0_s = [0 0 0 -45 45 0 0 0 90 0 0 0 -45 45];
[A_0, B_0, D_0, ABD_0, Q_0, thickness_0] = ABD(layup_iteration_0_s);
z_max_0 = thickness_0/2;% Max z-coordinate value

%% 3-point bending
F = 1000;% Force in N
% Force loading matrix
N = [0;
    F;
    0];
M_max = F * Length / 2;% Magnitude of Max moment in Nm

% Assuming specially orthotrpic, B = 0

% Moment/unit length vector
M = [M_max / Width;
    0;
    0];

% Curvature vector
K = D_0 \ M;

%% Applying ABD
epsilon0_0 = A_0 \ N;
epsilon_0 = 