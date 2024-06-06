clear
clc
close all

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
layup_iteration_0_s = [90 0 -45 45 0 -45 45 0 0 90 -45 45 0 0];
[A_0, B_0, D_0, ABD_0, Q_0, thickness_0] = ABD(layup_iteration_0_s);

L = 780e-3;% Length of the structure in m
b = 300e-3;% Depth of the beam, i.e. about the axis of bending in m
c = 50e-3;% Thickness of the foam core

%% Dimensions and properties
E_c = psiToPa(65e3);% Modulus of the foam core in Pa
d = c + thickness_0;
G_c = psiToPa(35e3);% Shear modulus of the foam core in Pa
sigma_critical_fc = 1.780e9;% Compressive composite facesheet failure stress in Pa
tau_critical_glue = 25e6;% Glue delamination stress
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

%% Orthoropic approximation
F = 7500;% Force in N

b_adapted = 0.05; %A

E_f_x = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(1,1) / b_adapted;
E_f_y = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(2,2) / b_adapted;
%% Dimensionless quantities
tbar = thickness_0 / c;
cbar = c / L;
sigmabar = sigma_critical_fc / sigma_critical_core;
taubar = tau_critical_core / sigma_critical_fc;
Ebar = E_f_x / sigma_critical_fc;
Fbar = F / (b * L * sigma_critical_fc);

%% Equivalent bending stiffness
EI_sw = (E_f_x * b * thickness_0 * d^2 / 2) + (E_f_x * b * thickness_0^3 / 6) + (E_c * b * c^3 / 12);

%% Equivalent shear stiffness
AG_sw = b * c * G_c;

%% 3 point bend deflection estimation
delta_3point_perimeter = (F * L^3) / (48 * EI_sw) + (F * L) / (4 * AG_sw);% Approximate deflection in m

%% Facesheet failure
F_critical_facesheet = (4 * d * b * thickness_0 * sigma_critical_fc) / L;% Critial load in 3-point bending causing facesheet failure
if F_critical_facesheet < F
    disp("Sandwich structure fails in facesheet failure")
end

%% Core delamination
F_critical_glue = 2 * b * d * tau_critical_glue;

F_critical_CS = 2 * b * d * tau_critical_core;

%% Indentation failure
F_critical_indentation = b * thickness_0 * ((pi^2 * d * E_f_x * sigma_critical_fc ^ 2) / (3 * L)) ^ (2/3);

%% Min Force for failure
[minload,i_minload] = min([F_critical_facesheet F_critical_glue F_critical_CS F_critical_indentation]);
failuremode = ["Facesheet Failure" "Delamination" "Core Shear Failure" "Indenation Failure"];
disp(['Fails in ' failuremode(i_minload) ' at ' minload ' N'])

%% Energy absorption
delta_fail = (minload * L^3) / (48 * EI_sw) + (minload * L) / (4 * AG_sw);% Approximate deflection in m
% Know that it deflects before failure

delta_desired = 0.05;
F_absorption = delta_desired / ((L^3) / (48 * EI_sw) + (L) / (4 * AG_sw));

Energy_absorbed = delta_desired * F_absorption;

%% Steel absorption
E_steel = 2e11;
sigma_y_steel = 3.05e8;
UTS_steel = 3.65e8;
no_tubes = 2;
OD_tube = 25.4e-3;
wall_thickness = 1.6e-3;
ID_tube = OD_tube - 2 * wall_thickness;

area_single = pi / 4 * (OD_tube^2 - ID_tube^2);
area_tubes = area_single * no_tubes;

strain_y_steel = sigma_y_steel / E_steel;
Energy_absorbed_steel = (strain_y_steel * sigma_y_steel / 2) * area_tubes * L;
%% Test
required_EI = 3.4067e+03 * 3
EI_sw

% Deflects at delta_desired, absorbs more energy assuming linear elasticity
Energy_absorbed_steel
Energy_absorbed

%% Visualisation
% Define the dimensions of the sandwich structure
LenPlot = L * 1000; % Length in mm
W = b * 1000; % Width in mm
t = thickness_0 * 1000;  % Thickness of facesheet in mm
core = c * 1000;  % Thickness of core in mm

% Create vertices for the facesheets and the core
facesheet1_vertices = [0 0 0;
                       LenPlot 0 0;
                       LenPlot W 0;
                       0 W 0;
                       0 0 t;
                       LenPlot 0 t;
                       LenPlot W t;
                       0 W t];

core_vertices = [0 0 t;
                 LenPlot 0 t;
                 LenPlot W t;
                 0 W t;
                 0 0 (t + core);
                 LenPlot 0 (t + core);
                 LenPlot W (t + core);
                 0 W (t + core)];

facesheet2_vertices = [0 0 (t + core);
                       LenPlot 0 (t + core);
                       LenPlot W (t + core);
                       0 W (t + core);
                       0 0 (2*t + core);
                       LenPlot 0 (2*t + core);
                       LenPlot W (2*t + core);
                       0 W (2*t + core)];

% Define the faces of the boxes using the vertices
faces = [1 2 3 4; 
         5 6 7 8; 
         1 2 6 5; 
         2 3 7 6; 
         3 4 8 7; 
         4 1 5 8];

% Create the figure
composite_structure = figure;
hold on;

% Plot the first facesheet
patch('Vertices', facesheet1_vertices, 'Faces', faces, 'FaceColor', 'blue', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Plot the core
patch('Vertices', core_vertices, 'Faces', faces, 'FaceColor', 'yellow', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Plot the second facesheet
patch('Vertices', facesheet2_vertices, 'Faces', faces, 'FaceColor', 'blue', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Set the axes properties
xlabel('Length / mm')
ylabel('Width / mm')
zlabel('Height / mm')
axis equal
grid on
view(3)

% Add title
%title('Composite Sandwich Structure')
legend('Facesheet', 'Core',Location='northwest')
betterPlot(composite_structure)
saveas(composite_structure, "composite_sandwich_structure.png")
hold off;

%% Force deflection graph


%% Closing all
close all

%% Estimation of cost
cost_per_m2_8552 = 35;% £
L_test = 600e-3;
b_test = 275e-3;
[cost_test,area_test] = composite_cost(layup_iteration_0_s,cost_per_m2_8552,L_test,b_test);% Minus honeycomb and adhesives, 2 halves
cost_test = cost_test * 2
area_test = area_test * 2

[cost,~] = composite_cost(layup_iteration_0_s,cost_per_m2_8552,L,b);% Minus honeycomb and adhesives, 2 halves
area_covered = L * b;
mass_per_m2 = mass_total / area_covered
cost_per_m2 = cost / area_covered