clear
clc

%% Assumptions
% Beam theory applicable to sandwich structures for low t/c, c/L
% Assume homogeneous isotropic facesheets with modulus E_f
% Assume isotropic foam core of modulus E_c
% Assume sigma_fc_failure is lower than sigma_ft_failure (compressive lower
% than tensile)
% Facesheet failure occurs in 3 point bending

%% Definitions
% t = Thickness of ONE laminate facesheet
% c = Thickness of foam core
% d = c + t i.e. distance from halfway through a facesheet to halfway
% through the other facesheet

%% Facesheet layup
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

% Assuming worst case strain
epsilon_0 = epsilon0_0 + z_max_0 * K;

sigma_0 = N / thickness_0;

E_f = abs(sigma_0 ./ epsilon_0);% Modulus of the facesheet in Pa


%% Dimensions and properties
E_c = ;% Modulus of the foam core in Pa
b = ;% Depth of the beam, i.e. about the axis of bending in m
c = ;% Thickness of the foam core
d = c + thickness_0;
G_c = ;% Shear modulus of the foam core in Pa
L = ;% Length of the structure in m
sigma_critical_fc = ;% Compressive composite facesheet failure stress in Pa
tau_critical_glue = ;% Glue delamination stress
tau_critical_core = ;% Critical core shear stress
sigma_critical_core = tau_critical_core;% Critical stress same due to isotropic

%% Dimensionless quantities
tbar = thickness_0 / c;
cbar = c / L;
sigmabar = sigma_critical_fc / sigma_critical_core;
taubar = tau_critical_core / sigma_critical_fc;
Ebar = E_f / simga_critical_fc;
Fbar = F / (b * L * sigma_critical_fc);

%% Equivalent bending stiffness
EI_sw = (E_f * b * t * d^2 / 2) + (E_f * b * t^3 / 6) + (E_c * b * c^3 / 12);

%% Equivalent shear stiffness
AG_sw = b * c * G_c;

%% 3 point bend deflection estimation
delta_3point = (F * L^3) / (48 * EI_sw) + (F * L) / (4 * AG_sw);% Approximate deflection in m

%% Facesheet failure
F_critical_facesheet = (4 * d * b * t * sigma_critical_fc) / L;% Critial load in 3-point bending causing facesheet failure
if F_critical_facesheet < F
    disp("Sandwich structure fails in facesheet failure")
end

%% Core delamination
S = F/2;% Shear force magnitude in 3-point bending
tau_I = S / (b * d);% Core shear stress
if tau_critical_glue < tau_I
    disp("Sandwich structure fails in delamination failure")
end

if tau_critical_core < tau_I
    disp("Sandwich structure fails in core yield failure")
end

%% Indentation failure
F_critical_indentation = b * t * ((pi^2 * d * E_f * sigma_critical_fc ^ 2) / (3 * L)) ^ (2/3);