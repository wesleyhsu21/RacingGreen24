% this script models heat transfer for the radiator
% Seider-Tate empiracal model is used here
% alongside with Geankoplis data correlation for Seider-Tate
clc
clear

%% Air parameters
% assume air at 25 C
% https://www.engineersedge.com/physics/viscosity_of_air_dynamic_and_kinematic_14483.htm

% Fan parameters: 
d_fan = 220e-3; % m
Vdot_fan = 40.5 * 4.72e-4; % cfm conversion to m^3/s
u_fan = Vdot_fan / (pi*d_fan^2/4); % Fan velocity calculated from volumetric flow rate. 
W_tube = 54.2e-3; % m

% Radiator parameters: 
radiator_w = 240e-3; % x-direction on drawing
radiator_t = 54.2e-3; % Thickness/depth
radiator_h = 105e-3; % height of radiator
radiator_pipe_d = 6.35e-3; % m
radiator_pipe_l = (radiator_w * 2) + (radiator_h/2); % Length of piping through the radiator (from inlet -> outlet)
A_ext = radiator_w * radiator_h; % Surface area of external facing plane
A_int = (pi * radiator_pipe_d) * radiator_pipe_l; % Internal surface area of total pipe inside radiator. 

% Air parameters: 
T_air = 25 + 273; % T air at infinity 
mu_air = 1.849e-5; % At 25*C (298*K)
kinematic_viscosity = 1.562*10^-5;
Pr_air = 0.7296; % Prandtl number
rho_air = 1.184; 
Cp_air = 1007;
alpha_air = 2.141*10^-5; % thermal diffusivity
k_air = 0.0255; 
g = 9.81; 
beta_air = 0.0034; % thermal expansion coefficient of air at 25*C
u_air = 10; % placeholder value
Re_air = rho_air * u_air * d_fan / mu_air; 
Nu_air = 0.0266 * Re_air^0.805 * Pr_air^(1/3); % Uses Sieder-Tate, Geankoplis data correlation. (Flow perpendicular to cylinder)
h_air = Nu_air * k_air / W_tube;


%%
% motor config
% assumption: 6L/min of water at 50C for a max 120 C motor temperature

con_motor_P = 75*1000; % continous power % note: current battery pack has max 73kW
min_motor_eff = 0.86;
motor_heat = (1-min_motor_eff)*con_motor_P; % W; assuming all wasted energy goes into heat

%%
% water as coolant
Cp_w = 4184; % heat capacity of water 
coolant_Vflow_rate = 6; % L/min
coolant_Vflow_rate = coolant_Vflow_rate/60000; % m^3/s
rho_w = 997; 
k_w = 0.64; % At 50*Celcius
mu_w = 5.47e-4; % at 50*C
Pr_w = 6.977; % Validity lies in 0.6 <= Pr <= 160, Re_w > 10,000, L/D > 10. 
coolant_Mflow_rate = coolant_Vflow_rate * rho_w;
ubar_w = coolant_Vflow_rate / (pi/4*radiator_pipe_d^2); % Mean velocity of water flowing through radiator pipe. 
Re_w = rho_w * ubar_w * radiator_pipe_d / mu_w; 
delta_T_coolant = motor_heat/Cp_w/coolant_Mflow_rate; 
Nu_w = 0.023 * Re_w^0.8 * Pr_w^0.4; 
h_w = Nu_w * k_w / radiator_pipe_d; 
eta_0 = 0.7; % Hard-coded, ambiguous formula due to lack of radiator fin parameters (Overall surface efficiency)
U_total = ((1/eta_0*h_air*A_ext) + (1/h_w*A_int))^-1; % Overall heat transfer coefficient of coolant and airflows

%% Other:
C_r = Cp_air/Cp_w; 
NTU = U_total/C_r; % Number of transfer units
epsilon = 1 - exp(((1/C_r)*NTU^0.22)*(exp(-C_r*NTU^0.78)-1));
q_radiator = epsilon*Cp_air*(delta_T_coolant); 
delta_q = q_radiator - motor_heat