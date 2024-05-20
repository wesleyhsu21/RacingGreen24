% this script models heat transfer for the radiator
% Seider-Tate empiracal model is used here
% alongside with Geankoplis data correlation for Seider-Tate
clc
clear

%%
% motor config
% assumption: 6L/min of water at 50C for a max 120 C motor temperature

con_motor_P = 75*1000; % continous power % note: current battery pack has max 73kW
min_motor_eff = 0.86;
motor_heat = (1-min_motor_eff)*con_motor_P; % W; assuming all wasted energy goes into heat

%%
% water as coolant
water_C = 4184; % heat capacity of water 
coolant_Vflow_rate = 6; % L/min
coolant_Vflow_rate = coolant_Vflow_rate/60000; % m^3/s
rho_coolant = 997;
coolant_Mflow_rate = coolant_Vflow_rate*rho_coolant;

delta_T_coolant = motor_heat/water_C/coolant_Mflow_rate
%%
% air
