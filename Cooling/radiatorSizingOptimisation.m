%% IRG24 Cooling Systems:
% Radiator Sizing Optimisation Code
clear
clc

% load('radiatorParameters.mat')
load('radiatorParametersv4.mat')

% Attribute an array of potential radiator area values to iterate through
radiatorArea = 1e-4:1e-5:0.04; 

% Initialize results arrays
optimal_u_air_array = zeros(size(radiatorArea));
min_delta_q_array = zeros(size(radiatorArea));
% Initialize parameters
airspeedArray = 0:0.01:20;
CFM = [];

% Iterate over radiator area values
for i = 1:length(radiatorArea)
    current_area = radiatorArea(i);

    % air.u_min = 0; % Starting lower bound for air velocity (m/s)
    % air.u_max = 20; % Starting upper bound for air velocity (m/s)
    error = 1e-3; % Tolerance for the minimisation
    optimal_u_air = 0; % Placeholder for optimal air velocity
    min_delta_q = motor.heat; % Placeholder for minimum delta_q
    delta_q = [];
    % Iterate to find the air velocity that minimizes delta_q
    for j = 1:length(airspeedArray)
        % Update air velocity
        air.u = airspeedArray(j);
        air.Re = air.rho * air.u * (current_area/(pi/4))^(1/2) / air.mu;
        air.Nu = 0.0266 * air.Re^0.805 * air.Pr^(1/3);
        air.h = air.Nu * air.k / fan.W_tube;

        % Update overall heat transfer coefficient
        U_total = ((1 / (eta_0 * air.h * current_area)) + (1 / (water.h * radiator.pipe.A_int)))^-1;

        % Calculate NTU and effectiveness
        NTU = U_total / C_r; % Number of transfer units
        epsilon = 1 - exp(((1 / C_r) * NTU^0.22) * (exp(-C_r * NTU^0.78) - 1));
        epsilon = 1 - exp(((1/C_r)*NTU^0.22)*(exp(-C_r*NTU^0.78)-1));

        % Calculate heat transfer by radiator
        q_radiator = epsilon * air.Cp * (water.deltaT);

        % Calculate delta_q
        delta_q(j) = q_radiator - motor.heat;

        % Check if this is the minimal delta_q
        if delta_q(j) > 0
            min_delta_q = delta_q(j);
            optimal_u_air = airspeedArray(j);
            break
        else
            optimal_u_air = airspeedArray(j);
            min_delta_q = delta_q(j);
        end
    end

    % Store results for current area
    optimal_u_air_array(i) = optimal_u_air;
    min_delta_q_array(i) = min_delta_q;
    CFM(i) = optimal_u_air_array(i)*current_area;
    CFM(i) = CFM(i) * 2118.88; % Conversion
end


fanArea = radiatorArea;
fanWeight = fanArea * fan.thickness * fan.rho *fan.weightRatio;

radiatorWeight = (radiatorArea) * radiator.thickness * radiator.rho * eta_0;
radiatorHeight = sqrt(radiatorArea/radiator.AR);
radiatorWidth = radiator.AR * radiatorHeight;

% Pipes
radiator.pipe.weight = radiator.pipe.diameter * radiator.pipe.thickness * (2*radiatorWidth + radiatorHeight) * radiator.pipe.rho;
waterWeight = ((radiator.pipe.diameter/2)^2)*pi * (2*radiatorWidth + radiatorHeight) * water.rho;

radiatorAssembly_total_mass = waterWeight + radiator.pipe.weight + fanWeight + radiatorWeight;

radiatorArea = radiatorArea * 100^2; % Conversion from m^2 to cm^2


% Display the optimal air velocity for the first iteration
disp(['Optimal air velocity for radiator area of 1e-4 m^2: ', num2str(optimal_u_air_array(1)), ' m/s']);
disp(['Minimum delta_q for radiator area of 1e-4 m^2: ', num2str(min_delta_q_array(1)), ' W']);

% Plotting graphs of CFM vs. Area and CFM vs. Mass
figure(1)
yyaxis left;
plot(CFM(217:end),radiatorArea(217:end), "-", MarkerSize=12)
xlabel("Volumetric Flow Rate, CFM $ft^3/min$", "Interpreter", "Latex")
ylabel("Radiator Area in $cm^2$", "Interpreter", "Latex")
axis auto

yyaxis right;
plot(CFM(217:end), radiatorAssembly_total_mass(217:end), "-", MarkerSize=12)
xlabel("Volumetric Flow Rate, (CFM) $ft^3/min$", "Interpreter", "Latex")
ylabel("Radiator Mass in kg", "Interpreter", "Latex")
axis auto
legend("Radiator Area, $cm^2$", "Radiator Mass, $kg$", "Interpreter", "Latex")

