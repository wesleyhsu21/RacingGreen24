%% IRG24 Cooling Systems:
% Radiator Sizing Optimisation Code
clear
clc

% load('radiatorParameters.mat')
load('radiatorParametersv4.mat')

% Attribute an array of potential radiator area values to iterate through
radiatorArea = 0.01:0.01:0.2;

% Maybe try loop
for i = 1:length(radiatorArea)
    current_area = radiatorArea(i); % 0.1 m^2

    % Initialize parameters
    air.u_min = 0; % Starting lower bound for air velocity (m/s)
    air.u_max = 20; % Starting upper bound for air velocity (m/s)
    error = 1e-3; % Tolerance for the minimization
    optimal_u_air = 0; % Placeholder for optimal air velocity
    min_delta_q = 1e4; % Placeholder for minimum delta_q

    % Iterate to find the air velocity that minimizes delta_q
    for u_air = linspace(air.u_min, air.u_max, 1000)
        % Update air velocity
        air.u = u_air;
        air.Re = air.rho * air.u * fan.diameter / air.mu;
        air.Nu = 0.0266 * air.Re^0.805 * air.Pr^(1/3);
        air.h = air.Nu * air.k / fan.W_tube;

        % Update overall heat transfer coefficient
        U_total = ((1 / (eta_0 * air.h * current_area)) + (1 / (water.h * radiator.pipe_A_int)))^-1;

        % Calculate NTU and effectiveness
        NTU = U_total / air.Cp; % Number of transfer units
        epsilon = 1 - exp(((1 / C_r) * NTU^0.22) * (exp(-C_r * NTU^0.78) - 1));

        % Calculate heat transfer by radiator
        q_radiator = epsilon * air.Cp * (water.deltaT);

        % Calculate delta_q
        delta_q = q_radiator - motor.heat;

        % Check if this is the minimal delta_q
        if delta_q > 0 && delta_q < min_delta_q
            min_delta_q = delta_q;
            optimal_u_air = u_air;
        end
    end
end

% Display the optimal air velocity for the first iteration
disp(['Optimal air velocity for radiator area of 0.1 m^2: ', num2str(optimal_u_air), ' m/s']);
disp(['Minimum delta_q for radiator area of 0.1 m^2: ', num2str(min_delta_q), ' W']);
