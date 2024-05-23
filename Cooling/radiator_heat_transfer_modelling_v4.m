%% IRG24 Cooling: Radiator Script
% This script models heat transfer for the radiator
% Seider-Tate empirical model is employed here 
% alongside with Geankoplis data correlation for Seider-Tate
clc
clear

% Establishing structures for cooling system components:
fan = struct();
radiator = struct();
motor = struct();
water = struct(); 
g = 9.81;

%% Air parameters: 
% Assume air at 25°C:
% https://www.engineersedge.com/physics/viscosity_of_air_dynamic_and_kinematic_14483.htm

%% Fan parameters: 
fan.diameter = 220e-3; % m
fan.Vdot = 40.5 * 4.72e-4; % CFM conversion to m^3/s
fan.velocity = fan.Vdot / (pi * fan.diameter^2 / 4); % Fan velocity calculated from volumetric flow rate
fan.W_tube = 54.2e-3; % m
fan.thickness = 15e-3;
fan.rho = 1250; % PLA
fan.weightRatio = 0.07 / (80e-3*80e-3*15e-3 * 1250);

%% Radiator parameters: 
% radiator.m = 2.651; % (kg) Mass of Alphacool Eisbaer Extreme liquid cooler core 280 - black edition
radiator.rho = 2710; % (kg/m^3)
radiator.width = 240e-3; % x-direction on drawing
radiator.thickness = 54.2e-3; % Thickness/depth
radiator.height = 105e-3; % height of radiator
radiator.area = radiator.width * radiator.height; % Modelling for now as rectangular plate
radiator.vol = radiator.area * radiator.thickness; % Modelling radiator as a cuboid block
radiator.mass = radiator.rho * radiator.vol;
radiator.AR = 2; % width to height ratio
radiator.pipe.diameter = 6.35e-3; % m
radiator.pipe.thickness = 0.5e-3; % m (Leo said so)
radiator.pipe.length = (radiator.width * 2) + (radiator.height / 2); % Length of piping through the radiator (from inlet -> outlet)
radiator.pipe.rho = 8960; % kg/m^3 of Cu
radiator.A_ext = radiator.width * radiator.height; % Surface area of external facing plane
radiator.pipe.A_int = (pi * radiator.pipe.diameter) * radiator.pipe.length; % Internal surface area of total pipe inside radiator

%% Air parameters: 
air.T = 25 + 273; % T air at infinity 
air.mu = 1.849e-5; % At 25°C (298°K) Dynamic Viscosity
air.nu = 1.562e-5; % Kinematic viscosity
air.Pr = 0.7296; % Prandtl number
air.rho = 1.184; % Density of air at 298°K
air.Cp = 1004.5; % Isobaric
air.Cv = 716.5; % Isochoric
air.gamma = air.Cp / air.Cv; % Ratio of specific heats
air.alpha = 2.141e-5; % Thermal diffusivity
air.k = 0.0255; % Thermal conductivity
air.beta = 0.0034; % thermal expansion coefficient of air at 25°C
air.u = 3; % placeholder value
% air.Ra = (g * air.beta * (Ts - Tinf) * L^3)
air.Re = air.rho * air.u * fan.diameter / air.mu; 
air.Nu = 0.0266 * air.Re^0.805 * air.Pr^(1/3); % Uses Sieder-Tate, Geankoplis data correlation (Flow perpendicular to cylinder)
% air.Nu = 0.68 + (0.67*air.Ra)
air.h = air.Nu * air.k / fan.W_tube;

%% Motor parameters: 
% assumption: 6L/min of water at 50°C for a max 120°C motor temperature
motor.continuous_power = 35 * 1000; % continous power % note: current battery pack has max 73kW
motor.efficiency = 0.86; 
motor.heat = (1 - motor.efficiency) * motor.continuous_power; % W, assuming all wasted energy goes into heat

%% Coolant (Water) Parameters: 
water.Cp = 4184; % J/kgK, heat capacity of water 
water.Vflow_rate = 6 / 60000; % m^3/s, converting from L/min to m^3/s
water.rho = 997; 
water.k = 0.64; % W/mK, at 50°C
water.mu = 5.47e-4; % Pa.s, at 50°C
water.Pr = 6.977; % Prandtl number
water.Mflow_rate = water.Vflow_rate * water.rho; % kg/s
water.ubar = water.Vflow_rate / (pi / 4 * radiator.pipe.diameter^2); % Mean velocity of water flowing through radiator pipe
water.Re = water.rho * water.ubar * radiator.pipe.diameter / water.mu; 
water.deltaT = motor.heat / water.Cp / water.Mflow_rate; % Temperature rise of coolant
water.Nu = 0.023 * water.Re^0.8 * water.Pr^0.4; % Nusselt number for water flow
water.h = water.Nu * water.k / radiator.pipe.diameter; 

% Overall heat transfer coefficient
eta_0 = 0.7; % Hard-coded, ambiguous formula due to lack of radiator fin parameters (Overall surface efficiency)
U_total = ((1 / (eta_0 * air.h * radiator.A_ext)) + (1 / (water.h * radiator.pipe.A_int)))^-1; % Overall heat transfer coefficient of coolant and airflow

%% Other: 
C_r = air.Cp/water.Cp; 
NTU = U_total/C_r; % Number of transfer units
epsilon = 1 - exp(((1/C_r)*NTU^0.22)*(exp(-C_r*NTU^0.78)-1));
q_radiator = epsilon*air.Cp*(water.deltaT);
q_motor = motor.heat;
delta_q = q_radiator - motor.heat;

% Display results
disp(['Overall heat transfer coefficient U_total: ', num2str(U_total), ' W/(m^2*K)']);
disp(['Coolant temperature rise delta_T: ', num2str(water.deltaT), ' K']);

% Creating plots for the area of the radiator vs the volumetric flow rate conditions: 

save('radiatorParametersv4.mat')