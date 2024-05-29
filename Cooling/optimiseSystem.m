%% IRG24 Cooling Systems - System Configuration
% Topology Optimisation Code

% Run the optimization
optimiseCoolingSystem();

%%
function optimiseCoolingSystem()
    % Define constants
    g = 9.81;
    water.Cp = 4184; % (kJ/kgK)
    water.rho = 997; % (kg/m^3)

    % Define components
    components = {
        struct('name', 'Battery',   'Tin', 25, 'Tout', 45,  'eta', 0.95, 'power', 40, 'VdotMin', 3,  'VdotMax', 8); % Data given from Leo
        struct('name', 'EMRAX228',  'Tin', 50,              'eta', 0.86, 'power', 28, 'VdotMin', 6,  'VdotMax', 15); % Max arbitrarily defined
        struct('name', 'NOVA15',    'Tin', 40,              'eta', 0.9,  'power', 13, 'VdotMin', 7,  'VdotMax', 15); % Max arbitrarily defined
        struct('name', 'BAMOCARD3', 'Tin', 65,              'eta', 0.9,  'power', 1,  'VdotMin', 6, 'VdotMax', 12); % Min arbitrarily defined
    };

    % Precompute heat and deltaT for each component
    for i = 1:length(components)
        components{i}.heat = components{i}.power * (1 - components{i}.eta);
        components{i}.deltaT = @(Vdot) components{i}.heat / (water.rho * Vdot / 60000) / water.Cp;
    end 

    % Optimization setup
    options = optimoptions('ga', 'Display', 'iter', 'UseParallel', true);
    nVars = length(components) * 2; % For series/parallel and flow rates

    % Genetic Algorithm for optimization
    [x, fval] = ga(@(x) objective_function(x, components, water), nVars, [], [], [], [], [], [], @(x) constraints(x, components, water), options);

    % Decode and display the optimal configuration
    decode_solution(x, components);

    function cost = objective_function(x, components, water)
        % Basically its a customisable objective function. Using heat dissipation: 
        cost = 0;
        n = length(components);

        for i = 1:n
            Vdot = x(n + i);
            if Vdot < components{i}.VdotMin || Vdot > components{i}.VdotMax
                cost = inf;
                return;
            end
            cost = cost + components{i}.heat;
        end
    end

    function [c, ceq] = constraints(x, components, water)
        n = length(components);
        c = [];
        ceq = [];

        % Extract series/parallel configuration and flow rates
        config = x(1:n) > 0.5; % If > 0.5, then series, otherwise parallel
        Vdots = x(n + 1:end);

        % Initialize temperatures
        Tout_prev = water.Tin;

        for i = 1:n
            % Check temperature constraints
            if config(i) % Series
                Tin = Tout_prev;
            else % Parallel
                Tin = water.Tin;
            end

            if Tin > components{i}.Tin
                c = [c; Tin - components{i}.Tin];
            end

            % Compute Tout
            deltaT = components{i}.deltaT(Vdots(i));
            Tout = Tin + deltaT;

            % Update previous outlet temperature
            if config(i)
                Tout_prev = Tout;
            end
        end
    end

    function decode_solution(x, components)
        n = length(components);
        config = x(1:n) > 0.5;
        Vdots = x(n + 1:end);

        fprintf('Optimal Configuration:\n');
        for i = 1:n
            fprintf('%s - %s, Flow Rate: %.2f L/min\n', components{i}.name, ternary(config(i), 'Series', 'Parallel'), Vdots(i));
        end
    end

    function result = ternary(cond, true_val, false_val)
        if cond
            result = true_val;
        else
            result = false_val;
        end
    end
end
