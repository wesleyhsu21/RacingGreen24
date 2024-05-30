%______FUNCTION TO CALCULATE TEMPERATURE RISE IN BATTERY PACK____________
% ____________CONTACT: TOM HOLLAND, TJH17@IC.AC.UK_______________________

function [T] = Cooling_Model(E_gen,t,v)

[U,A] = Cooling_Data(v); % calculate overall heat transfer coefficient



%% Thermal conditions
T_amb = 25; % ambient temperature
T_0 = 35; % start temperature
rho = 2368.9; % density of module
Vol = A*0.1276; % volume of pack
C = 5660; % heat capacity of module (EV3 Battery Final Report)
C = 6*C; % heat capacity of pack

%% Initialisation
T = zeros(length(t),1); % initialise T
T(1) = T_0;

%% Running
dt = diff(t); % timestep vector
a = (U.*A)./(C); % parameter a in lump capacitance solution
b = E_gen./C; % parameter b in lump capacitance solution

% compute time-marching temperature solution
for i = 1:length(t)-1
    T(i+1) = T_amb + (T(i)-T_amb)*(exp(-a(i)*dt(i))) + (((b(i)/a(i)))*(1-exp(-a(i)*dt(i))));
end
