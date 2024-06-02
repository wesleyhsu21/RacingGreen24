clear
clc

%% Honeycomb

% Aluminium Properties
sigma_Y_solid_Al5052 = 193e6;       % Yield Strength in Pa
sigma_UTS_solid_Al5052 = 228e6;     % Ultimiate Tensilte Strength in Pa
E_solid_Al5052 = 70.3e9;            % Young's Modulus in Pa
G_solid_Al5052 = 25.9e9;            % Shear Modulus in Pa
ShearStrength_solid_Al5052 = 138e6; % Shear Stress in Pa
rho_solid_Al5052 = 2680;            % Density in kg/m^3
nu_solid_Al5052 = 0.33;             % Poisson Ratio

sigma_Y_solid_Al3003 = 41e6;        % Yield Strength in Pa
sigma_UTS_solid_Al3003 = 110e6;     % Ultimiate Tensilte Strength in Pa
E_solid_Al3003 = 68.9e9;            % Young's Modulus in Pa
G_solid_Al3003 = 25e9;              % Shear Modulus in Pa
ShearStrength_solid_Al3003 = 75.8e6;% Shear Stress in Pa
rho_solid_Al3003 = 2730;            % Density in kg/m^3
nu_solid_Al3003 = 0.33;             % Poisson Ratio

% easyComposites data
% Type 1,2,3 refers to 3.2mm,6.4mm,19.1mm cell sizes
% Data included
honeycomb_density = [72.1 83.3 28.8];
honeycomb_cellsize = [3.2e-3 6.4e-3 19.1e-3];
honeycomb_solid_density = [rho_solid_Al5052 rho_solid_Al3003 rho_solid_Al3003];
honeycomb_solid_yield = [sigma_Y_solid_Al5052 sigma_Y_solid_Al3003 sigma_Y_solid_Al3003];
honeycomb_series = [5052 3003 3003];
honeycomb_FoilThickness = [35e-3 70e-3 50e-3];
honeycomb_Perforation = ["N" "Y" "Y"];
honeycomb_sigma_c_bare = [psiToPa(539) psiToPa(625) psiToPa(115)];
honeycomb_sigma_c_stabilised = [psiToPa(559) psiToPa(655) psiToPa(125)];
honeycomb_sigma_crush = [psiToPa(255) psiToPa(235) psiToPa(40)];
honeycomb_shear_strength_length = [psiToPa(340) psiToPa(360) psiToPa(95)];
honeycomb_shear_modulus_length = [psiToPa(70e3) psiToPa(65e3) psiToPa(22e3)];
honeycomb_shear_strength_width = [psiToPa(220) psiToPa(210) psiToPa(60)];
honeycomb_shear_modulus_width = [psiToPa(31e3) psiToPa(35e3) psiToPa(10e3)];

%% Technical requirements
Safety_Factor_Energy_Absorption = 1.5;
Safety_Factor_Avg_Deccel = 1.2;
Safety_Factor_Max_Deccel = 1.1;
Required_Energy_Absorption = 7350 * Safety_Factor_Energy_Absorption;    % Energy in J
theta_honeycomb = 30;                                                   % Degrees
epsilon_d = log(1 / 1 + 2 * sind(theta_honeycomb));
g = 9.81;                                                               % ms^-2
Avg_Deccel = 20 * g / Safety_Factor_Avg_Deccel;                         % Avg decleration in ms^-2
Max_Deccel = 40 * g / Safety_Factor_Max_Deccel;                         % Max decleration in ms^-2
m = 300;                                                                % Mass in kg

%% Dimensions
Height = 0.2;                       % Length in m facing the car (horizontal) Min 0.1
Width = 0.3;                        % Width in m facing the car (vertical) Min 0.2
Depth = 0.34;                       % Depth in m facing the car Min 0.2
Volume = Height * Width * Depth;    % m^3
Area = Height * Width;
mass = honeycomb_density * Volume
cost_per_kg = 51;
cost = mass * cost_per_kg

%% Energy Absorption
Specific_Energy_Absorption = epsilon_d * honeycomb_sigma_c_bare;    % Jm^-3
Energy_Absorption = Specific_Energy_Absorption * Volume;            % J
Energy_Absorbed = (ones * Required_Energy_Absorption) <= Energy_Absorption

%% Deceleration
decceleration = Area * honeycomb_sigma_c_bare / m;
decceleration_boolean = Avg_Deccel >= decceleration




%% Plotting
dense_strain = 0.69312;
dense_stress = (dense_strain - 0.6931) * E_solid_Al3003 + honeycomb_sigma_c_bare(3);
x = [0 0.01 0.6931 dense_strain];
y = [0 honeycomb_sigma_c_bare(3) honeycomb_sigma_c_bare(3) dense_stress];

IAPlot = figure;
plot(x,y)
hold on
T1xregion1 = [0 dense_strain dense_strain 0];
T1yregion1 = [0 0 honeycomb_sigma_c_bare(3) honeycomb_sigma_c_bare(3)];
fill(T1xregion1, T1yregion1, 'red', 'FaceAlpha', 0.3)
xlabel('$\varepsilon$')
ylabel('$\sigma$ / Pa')
hold off
betterPlot(IAPlot)
legend('','Specific Energy Absorption')
saveas(IAPlot, 'IAPlot.png')

%% Minimum geometry
% Define the dimensions of the box
height = 100; % Height in mm
width = 200;  % Width in mm
length = 200; % Length in mm

% Define the vertices of the box
vertices = [0 0 0; 
            length 0 0; 
            length width 0; 
            0 width 0; 
            0 0 height; 
            length 0 height; 
            length width height; 
            0 width height];

% Define the faces of the box using the vertices
faces = [1 2 3 4; 
         5 6 7 8; 
         1 2 6 5; 
         2 3 7 6; 
         3 4 8 7; 
         4 1 5 8];

% Create the figure
IAgeometry = figure;
hold on;

% Plot the box
patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'EdgeColor', 'black');

% Set the axes properties
xlabel('Length / mm')
ylabel('Width / mm')
zlabel('Height / mm')
axis equal
grid on
view(3)

% Add title
title('Mininum Impact Attenuator Geometry')
betterPlot(IAgeometry)
legend("off")
saveas(IAgeometry,"IAgeometry.png")
hold off;

%% Actual geometry
% Define the dimensions of the box
height = 100; % Height in mm
width = 300;  % Width in mm
length = 340; % Length in mm

% Define the vertices of the box
vertices = [0 0 0; 
            length 0 0; 
            length width 0; 
            0 width 0; 
            0 0 height; 
            length 0 height; 
            length width height; 
            0 width height];

% Define the faces of the box using the vertices
faces = [1 2 3 4; 
         5 6 7 8; 
         1 2 6 5; 
         2 3 7 6; 
         3 4 8 7; 
         4 1 5 8];

% Create the figure
IAgeometry_actual = figure;
hold on;

% Plot the box
patch('Vertices', vertices, 'Faces', faces, 'FaceColor', 'cyan', 'EdgeColor', 'black');

% Set the axes properties
xlabel('Length / mm')
ylabel('Width / mm')
zlabel('Height / mm')
axis equal
grid on
view(3)

% Add title
title('Actual Impact Attenuator Geometry')
betterPlot(IAgeometry_actual)
legend("off")
saveas(IAgeometry_actual,"IAgeometry_actual.png")
hold off;

%% Combined
% Define the dimensions of the actual box
actual_height = Height * 1000; % Height in mm
actual_width = Width * 1000;  % Width in mm
actual_length = Depth * 1000; % Length in mm

% Define the dimensions of the minimum box
min_height = 50; % Minimum height in mm
min_width = 200; % Minimum width in mm
min_length = 200; % Minimum length in mm

% Define the vertices of the actual box
actual_vertices = [0 0 0; 
                   actual_length 0 0; 
                   actual_length actual_width 0; 
                   0 actual_width 0; 
                   0 0 actual_height; 
                   actual_length 0 actual_height; 
                   actual_length actual_width actual_height; 
                   0 actual_width actual_height];

% Define the vertices of the minimum box
min_vertices = [0.5 0.5 0.5; 
                min_length 0.5 0.5; 
                min_length min_width 0.5; 
                0.5 min_width 0.5; 
                0.5 0.5 min_height; 
                min_length 0.5 min_height; 
                min_length min_width min_height; 
                0.5 min_width min_height];

% Define the faces of the box using the vertices
faces = [1 2 3 4; 
         5 6 7 8; 
         1 2 6 5; 
         2 3 7 6; 
         3 4 8 7; 
         4 1 5 8];

% Create the figure
IAgeometry_comparison = figure;
hold on;

% Plot the actual box
patch('Vertices', actual_vertices, 'Faces', faces, 'FaceColor', 'cyan', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Plot the minimum box
patch('Vertices', min_vertices, 'Faces', faces, 'FaceColor', 'red', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Set the axes properties
xlabel('Length / mm')
ylabel('Width / mm')
zlabel('Height / mm')
axis equal
grid on
view(3)

% Add title
%title('Comparison of Impact Attenuator Geometries')
grid on
betterPlot(IAgeometry_comparison)
legend('Actual Geometry', 'Minimum Geometry',Location='northwest')
%legend("off")
saveas(IAgeometry_comparison, "IAgeometry_comparison.png")
hold off;

%%
close all

%% Saving Parameters
IAParams.Height = Height;
IAParams.Width = Width;
IAParams.Depth = Depth;

save("IAParams.mat","IAParams")