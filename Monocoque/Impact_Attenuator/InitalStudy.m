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

sigma_Y_solid_Al3003 = 41e6;       % Yield Strength in Pa
sigma_UTS_solid_Al3003 = 110e6;     % Ultimiate Tensilte Strength in Pa
E_solid_Al3003 = 68.9e9;            % Young's Modulus in Pa
G_solid_Al3003 = 25e9;            % Shear Modulus in Pa
ShearStrength_solid_Al3003 = 75.8e6; % Shear Stress in Pa
rho_solid_Al3003 = 2730;            % Density in kg/m^3
nu_solid_Al3003 = 0.33;             % Poisson Ratio

% easyComposites data
% Type 1,2,3 refers to 3.2mm,6.4mm,19.1mm cell sizes
honeycomb_density = [72.1 83.3 28.8];
honeycomb_solid_density = [rho_solid_Al5052 rho_solid_Al3003 rho_solid_Al3003];
honeycomb_solid_yield = [sigma_Y_solid_Al5052 sigma_Y_solid_Al3003 sigma_Y_solid_Al3003];
honeycomb_series = [5052 3003 3003];
honeycomb_FoilThickness = [35e-3 70e-3 50e-3];
honeycomb_Perforation = ["N" "Y" "Y"];
honeycomb_sigma_c_bare = [psiToPa(539) psiToPa(625) psiToPa(115)];
honeycomb_sigma_c_stabilised = [psiToPa(559) psiToPa(655) psiToPa(125)];
honeycomb_sigma_crush = [psiToPa(255) psiToPa(235) psiToPa(40)];
honeycomb_shear_strength_length = [psiToPa(340) psiToPa(360) psiToPa(95)];
honeycomb_shear_modulus_length = [psiToPa(70e3) psiToPa(65e3) psiToPa(23e3)];
honeycomb_shear_strength_width = [psiToPa(220) psiToPa(210) psiToPa(60)];
honeycomb_shear_modulus_width = [psiToPa(31e3) psiToPa(35e3) psiToPa(10e3)];

% Finding constants
honeycomb_relative_density = honeycomb_density ./ honeycomb_solid_density;
honeycomb_constant_axial_stress = (honeycomb_shear_strength_length ./ honeycomb_solid_yield) ./ honeycomb_relative_density;
honeycomb_constant_transverse_stress = (honeycomb_shear_strength_width ./ honeycomb_solid_yield) ./ (honeycomb_relative_density) .^ 1.5;