%______FUNCTION TO CALCULATE THERMAL PARAMETERS OF BATTERY PACK__________
% ____________CONTACT: TOM HOLLAND, TJH17@IC.AC.UK_______________________

function [U,A] = Cooling_Data(u)
%% Fluid data @ 30oC
rho = 1.165; % density of air
C = 1006; % specific heat
mu = 1.86e-5; % absoulte viscosity
nu = mu/rho; % kinematic viscosity
k_air = 0.026; % conductivity
alpha = k_air/(rho*C); % alpha parameter
Pr = nu/alpha; % Prandtl number
Re_crit = 5e5; % critical Reynolds number
u(1)=0.0001;
%% Flow properties
x = 1; % pack distance to front of car

Re = (u.*x)./nu; % Reynolds number

Nu = 0.0308*(Re.^0.8)*Pr^(1/3); % Nusselt number, assume turbulent conditions

h = Nu.*k_air./x; % heat transfer coefficient for convection

%% Thermal Reisistances
A = 6*(74.6e-3)*(284e-3); % heat transfer area

% gap pad
L_g = 1e-3; % thickness
k_g = 2; % conductivity
R_g = L_g/(k_g*A); % conductive resistance

% base plate
L_a = 5e-3; % thickness
k_a = 177; % conductivity, aluminium alloy 2024-T6
R_a = L_a/(k_a*A); % conductive resistance

% convection
R_c = 1./(h*A); % convective resistance

R_tot = R_g + R_a + R_c; % total thermal resisitance

U = 1./(R_tot.*A); % overall heat transfer coefficient

