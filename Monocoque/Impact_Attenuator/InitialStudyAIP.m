clear
clc
close all

%% Loading Parameters from InitalStudy_IA
load("IAParams.mat")
IA_Height = IAParams.Height;
IA_Width = IAParams.Width;

%% Parameters
AIP_Height = 0.2;% in m
AIP_Width = 0.3;% in m

%% Calculating bending moment
F = 120000;% Total distributed load through the IA determined in the SES

delta_H = AIP_Height - IA_Height;% Difference in the IA and AIP height in m
M_max_vertical = F / AIP_Height * IA_Height / 2 * (AIP_Height - delta_H) / 4 - F / 2 * AIP_Height / 2;
M_max_vertical_abs = abs(M_max_vertical);

delta_W = AIP_Width - IA_Width;
M_max_horizontal = F / AIP_Width * IA_Width / 2 * (AIP_Width - delta_W) / 4 - F / 2 * AIP_Width / 2;
M_max_horizontal_abs = abs(M_max_horizontal);

%% Steel mass
Steel_AIP_thicknesss = 1.5e-3;% in m
Steel_AIP_volume = AIP_Width * AIP_Height * Steel_AIP_thicknesss;% in m^3
rho_steel = 7850;% kgm^-3
mass_steel = Steel_AIP_volume * rho_steel

%% Aluminium mass
Aluminium_AIP_thickness = 4e-3;% in m
Aluminium_AIP_volume = AIP_Width * AIP_Height * Aluminium_AIP_thickness;% in m^3
rho_aluminium = 2710;% kgm^-3
mass_aluminium = Aluminium_AIP_volume * rho_aluminium

%% Sandwich structure

% Facesheet layup
layup_iteration_0_s = [0 0 90 0 -45 45 0 -45 45 0];
[A_0, B_0, D_0, ABD_0, Q_0, thickness_0] = ABD(layup_iteration_0_s);

L = AIP_Width;% Length of the structure in m
b = AIP_Height;% Depth of the beam, i.e. about the axis of bending in m
c = 40e-3;% Thickness of the foam core

% Orthoropic approximation
% Width axis is the x axis
% Height axis is the y axis

E_f_x = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(1,1) / IA_Width;
E_f_y = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(2,2) / IA_Height;

% Dimensions and properties
E_c = psiToPa(65e3);% Modulus of the foam core in Pa
d = c + thickness_0;
G_c = psiToPa(35e3);% Shear modulus of the foam core in Pa
sigma_critical_fc = 1.780e9;% Compressive composite facesheet failure stress in Pa
tau_critical_glue = 60e6;% Glue delamination stress
tau_critical_core = psiToPa(360);% Critical core shear stress
sigma_critical_core = psiToPa(625);% Critical stress same due to isotropic
rho_fc = 1570;% Facesheet density in kgm^-3
rho_c = 83.3;% Core density in kgm^-3
volume_fc = thickness_0 * b * L;% Volume in m^3
mass_fc = volume_fc * rho_fc;% Mass in kg
volume_c = c * b * L;% Volume in m^3
mass_c = volume_c * rho_c;% Mass in kg
mass_total = mass_fc + mass_c %Total mass per side in kg
thickness_total = c + 2 * thickness_0

% Equivalent bending stiffnesses
EI_sw_x = (E_f_x * b * thickness_0 * d^2 / 2) + (E_f_x * b * thickness_0^3 / 6) + (E_c * b * c^3 / 12);
EI_sw_y = (E_f_y * b * thickness_0 * d^2 / 2) + (E_f_y * b * thickness_0^3 / 6) + (E_c * b * c^3 / 12);

% Equivalent shear stiffness
AG_sw = b * c * G_c;

