% this script models delta T of the battery module on one side
% heat generation is divided by 6 as we assume 

%%
% battery parameters
h_ts = ; % height of battery stack
l_ts = ; % length of battery stack
q_ts = ;
q_ts_one_side = q_ts/6;
c_ts = ; % heat capacity of battery
mass_ts = ; % mass of battery

%%
% paraffin parameters
paraffin_k = ; % thermal conductivity
paraffin_latent = 2200*1000; 
c_paraffin = 2900; % specific heat

%%
% aluminium plate parameters
Al_thickness = 2.3*10^-3; % 2.3 mm from regulation
Al_k = 235; 

%%
% air parameters
% assume air at 25 C
% https://www.engineersedge.com/physics/viscosity_of_air_dynamic_and_kinematic_14483.htm

kinematic_viscosity = 1.562*10^-5;
Pr_air = 0.7296; % Prantl number
rho_air = 1.184; 
Cp_air = 1007;
alpha_air = 2.141*10^-5; % thermal diffusivity
air_k = 0.0255; 
g = 9.81; 
beta_air = 0.0034; % thermal expansion coefficient of air at 25C


