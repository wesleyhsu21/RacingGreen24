% this script models delta T of the battery module on one side
% heat generation is divided by 6 as we assume 
clc
clear

%syms deltaT
deltaT = 35;
Al_T = 273 + 25 + deltaT;
air_T = 273 + 25;

%%
% battery parameters
% assume 8 L battery 20 x 20 x 20 cm battery pack
h_ts = 0.27; % height of battery stack
l_ts = 0.27; % length of battery stack
A_ts = h_ts * l_ts;

c_ts = 1044; % heat capacity of battery % from 2023 data
mass_ts = 25; % mass of battery % rough estimate
battery_efficiency = 0.95; % 5 percent energy discharge turns into heat
con_peak_power = 75*1000; % peak power: 124 kW for the EMRAX 228 % continous peak power 75k W % current battery pack max power 70 kW, regulation max 80 kW

Q_battery = con_peak_power*(1-battery_efficiency); % heat energy dissapated by battery
q_ts_one_side = Q_battery/(6*A_ts) % q is W/m^2

%%
% paraffin parameters
% 60% paraffin wax and 40 % graphite
paraffin70_k = 7.1; % thermal conductivity
paraffin_latent = 214*1000; % J/kg
c_paraffin = 2900; % specific heat

% assume 2 mm paraffin thickness
paraffin_thickness = 0.002;

R_paraffin = paraffin_thickness/(paraffin70_k*A_ts);

%%
% aluminium plate parameters
Al_thickness = 2.3*10^-3; % 2.3 mm from regulation
Al_k = 235;

R_Al = Al_thickness/(Al_k*A_ts); % heat resistance of aluminium plate

%T_Al = null; % temp at the surface of the plate

%%
% air parameters
% assume air at 25 C
% https://www.engineersedge.com/physics/viscosity_of_air_dynamic_and_kinematic_14483.htm

T_air = 25 + 273; % T air at infinity 
kinematic_viscosity = 1.562*10^-5;
Pr_air = 0.7296; % Prantl number
rho_air = 1.184; 
Cp_air = 1007;
alpha_air = 2.141*10^-5; % thermal diffusivity
air_k = 0.0255; 
g = 9.81; 
beta_air = 0.0034; % thermal expansion coefficient of air at 25C

Ra = (g*beta_air*(Al_T - air_T)*(h_ts^3))/(kinematic_viscosity*alpha_air); % Rayleigh number: ratio of buoyanceto viscous forces

% using Churchill-Bernstein empiracal model, natural convection for a
% vertical plate
Nu = 0.68 + (0.67 * Ra^0.25)*(1 + (0.492/Pr_air)^(9/16))^(4/9); % Nusselt number: ratio of convective to conductive heat transfer across boundary layer

h_air = Nu*air_k/A_ts; % convective heat transfer coefficient for air

sigma_stef = 5.67*10^-8;
etta_Al = 1; % 

%%
R_cond_total = R_Al + R_paraffin;
k_cond_total = (Al_thickness + paraffin_thickness)/(R_cond_total*A_ts)

q_cond_total = k_cond_total*deltaT*A_ts/(Al_thickness + paraffin_thickness)
q_conv = h_air*A_ts*deltaT
q_rad = etta_Al*sigma_stef*A_ts*(Al_T^4 - air_T^4)

%%

eqn = q_ts_one_side - q_conv - q_cond_total - q_rad
%S = solve(eqn, deltaT, 'ReturnConditions', true)

