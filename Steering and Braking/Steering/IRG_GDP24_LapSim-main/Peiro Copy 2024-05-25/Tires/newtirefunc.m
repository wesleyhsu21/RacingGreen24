function [sr_max, sa_max, str_a, cha_a,fxn,fyn] = newtirefunc(fx, fy, fz, model, car, rad)
    % Author: Charalampos Charalampous - Email: cc2621@ic.ac.uk
    
    % Finds the best slip angle and slip ratio for a given 
    % longitudinal and lateral force.
    
    % Input Arguments:
    % fx (double) -> Longitudinal force at iteration (1,2,2)
    % fy (double) -> Lateral force at iteration (1,2,2)
    % fz (double) -> Vertical force at iteration (1,2,2)
    % model ->  Tyre models from TTC
    % car -> Car object
    % rad -> radius of track at given iteration (double)
    % Outputs:
    % sr_max (double) ->Matrix of slip ratio for each tire (2,2)
    % sa_max (double) ->Matrix of slip angle for each tire (2,2)
    % str_a (double) -> Steering Angle
    % cha_a (double) ->Chassis Angle
    
    
    fx(isnan(fx)) = 0; % Set NaN to 0 to avoid errors
    
    fy_max = zeros(2,2); % Preload temporary fy holder
    fx_max = zeros(2,2); % Preload temporary fx holder
    % fxn = fx_max;
    % fyn=fy_max;
    
    sr = zeros(2,2); % Preload slip ratio matrix
    sa = zeros(2,2); % Preload slip angle matrix
    sr_max = zeros(2,2); % Preload slip ratio final matrix
    sa_max = zeros(2,2); % Preload slip angle final matrix
    
    err = inf; % Set error to infinity
    
    ms = 1; % Set indices 1 to avoid errors
    mc = 1;
    
    n = 10; % Number of points in sweep of steering angle and chassis angle
    
    % If the turning radius is greater than 100 set chassis angle to 0
    % Else, sweep chassis angle
    if (abs(rad) > 100)
        cha_a_values = zeros(1,n); 
    else
        cha_a_values = linspace(-5,5,n); 
        cha_a_values = deg2rad(cha_a_values);
    end
    
    fy_sum = sum(fy(1,:,:),'all');
    fx_sum = sum(fx(1,:,:),'all');
    % If the sign of force is positive, use positive sweep values
    % Else use negative sweep values
    limit = 45;
    if (fy_sum > 0)
        str_a_values = linspace(0, limit, n); 
    else
        str_a_values = linspace(-limit, 0, n);
    end
    str_a_values = deg2rad(str_a_values);
    
    % If it accelerates sweep positive values
    % Else sweep negative values
    peak = 0.149;
    if (fx_sum > 0)
        sr_temp = linspace(0, peak, n); 
    else
        sr_temp = linspace(-peak, 0, n); 
    end

    % Calculating coefficients beforehand
    IA = car.IA;
    tyre_pressure = car.tyre_pressure;
    Scaling_factor = 0.67;
    lat_coeff = cell(2, 2); % Preload lat_coeff matrix
    long_coeff = cell(2, 2); % Preload long_coeff matrix
    for i = 1:2
        for j = 1:2
            fz_ij = fz(1,i,j); % Set fz_ij 
            % The track cannot pull vertically on the tyre so eliminate negative fz_ij
            if (fz_ij <= 0)
                sa_max(i,j) = 0;
                sr_max(i,j) = 0;
                % % fxn = fx_max;
                % % fyn = fy_max;
                continue
            end

            % Set upper limit to fz_ij as tyre data becomes inaccurate beyond 1200 N
            fz_ij_cap = fz_ij;
            if (fz_ij > 1200)
                fz_ij_cap = 1200;
            end
           
         
            % Find Magic formula coefficients from look-up tables of TTC data:
            B_lat = model.latB(tyre_pressure, IA, fz_ij_cap);
            E_lat = model.latE(tyre_pressure, IA, fz_ij_cap);
            CS_lat = model.latCS(tyre_pressure, IA, fz_ij_cap);
            Mu_lat = model.latMu(tyre_pressure, IA, fz_ij_cap);
            lat_coeff{i, j} = [B_lat, E_lat, Mu_lat, CS_lat];

            B_long = model.longB(tyre_pressure, IA, fz_ij_cap);
            E_long = model.longE(tyre_pressure, IA, fz_ij_cap);
            CS_long = model.longCS(tyre_pressure, IA, fz_ij_cap);
            Mu_long = model.longMu(tyre_pressure, IA, fz_ij_cap);
            long_coeff{i, j} = [B_long, E_long, Mu_long, CS_long];
        end
    end
    
    for si = 1:n
        for ci = 1:n
            sa(1,1) =  str_a_values(si) + cha_a_values(ci) - car.toe; % Find slip angle fron steering and chassis angle
            sa(1,2) = sa(1, 1) + 2 * car.toe; % Ditto, ackermann would have made this different however no ackermann
    
            sa(2,1) = cha_a_values(ci); % Rear is just chassis angle except if you factor tow
            sa(2,2) = sa(2, 1); % Ditto
x
            for i = 1:2
                for j = 1:2
                    fz_ij = fz(1, i, j); % Set fz_ij
                    % The track cannot pull vertically on the tyre so eliminate negative fz_ij
                    if (fz_ij <= 0)
                        % % fxn = fx_max;
                        % % fyn = fy_max;
                        continue
                    end
               
                    s_ind = ones(1, n) * sa(i, j); % Create slip angle sweep matrix
    
                    % Find max fx
                    [fx_temp, fy_temp] = combinedPacejkaFix(s_ind, sr_temp, lat_coeff{i, j}, long_coeff{i, j}, fz_ij);
                    fxfy = fx_temp.^2 + fy_temp.^2; 
                    [~, k] = max(fxfy); % Find greater net force and with index find the parts
                    % Add Scaling as recomended from TTC
                    fx_max(i, j) = fx_temp(k) * Scaling_factor;
                    fy_max(i, j) = fy_temp(k) * Scaling_factor;
                    sr(i, j) = sr_temp(k); % Set temporary slip ratio to the one which gives the maximum force
                end
            end
    
            % Check to see if it returns a smaller error, with more weight on lateral force
            calc_err = 0.7 * abs(sum(fx_max - fx(1,:,:),'all')) + 1.3 * abs(sum(fy(1,:,:)- fy_max,'all'));
            if calc_err <= err
                 sr_max = sr; % Set final to temp
                 sa_max = sa; 
                 fxn = fx_max;
                 fyn = fy_max;
                 err = calc_err;
                 ms = si; % Find steering index
                 mc = ci; % Find chassis index
            end
        end
    end
    str_a = str_a_values(ms);
    cha_a = cha_a_values(mc);
end