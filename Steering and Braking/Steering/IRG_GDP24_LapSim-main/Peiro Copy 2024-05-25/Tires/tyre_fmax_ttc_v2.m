function [F_xmax, F_ymax, SL_max, SA_max] = tyre_fmax_ttc_v2(F_z, model, car)
    F_ymax = [];
    F_xmax = [];
    
    SL_max = [];
    SA_max = [];

    IA = car.IA;
    P = car.tyre_pressure;
    Scaling_factor = 0.67;

    
    n = 20;     % No. of points in tyre SL and SR sweeps
    
    for i = 1:2
        
        for j = 1:2

            FZ = F_z(1,i,j);
            
            % The track cannot pull vertically on the tyre so eliminate negative Fz
            if FZ <= 0
                F_ymax = [F_ymax, 0];
                F_xmax = [F_xmax, 0];
                SA_max = [SA_max, 0];
                SL_max = [SL_max, 0];
                continue
            end
            
 % hardcode for now


            % SL = linspace(-1,1,n); % Slip Ratio Sweep
            % SA = linspace(-30,30,n); % Slip Angle Sweep
            % 
            % [F_x,F_y,~] = PacejkaTest(SA,SL,Fz);
            % 
            % F_xmax_old = max(F_x);
            % F_ymax_old = max(F_y);
            % 
            % clear SL SA

            % The issues from above is that it was simultaneously sweep SA and SL. In
            % otherwords at each point SA AND SL were not 0. So the Fx and Fy max
            % values above gives the max Fy and Fx for a combined SA SL sweep. The
            % ellipse that we want to find is actually defined by the max Fy when there
            % is no SL and the max Fx when there is no SA.

            % Set upper limit to Fz as tyre data becomes inaccurate beyond 1200 N
            if FZ > 1200
                FZ_cap = 1200;
            else
                FZ_cap = FZ;
            end

            % Copied and pasted interpolation equation coefficients into script:
            % %lat_coeff = [coeffs.lat.B(P,IA,FZ_cap), coeffs.lat.E(P,IA,FZ_cap),coeffs.lat.Mu(P,IA,FZ_cap),coeffs.lat.CS(P,IA,FZ_cap)];
            % B_lat = 5.66e-1 + FZ_cap * 9.14e-4 + FZ_cap^2 * -1.04e-6 + FZ_cap^3 * -1.03e-9 + FZ_cap^4 * 1.25e-12;
            % E_lat = 6.67e-1 + FZ_cap * 5.47e-3 + FZ_cap^2 * -2.2e-5 + FZ_cap^3 * 3.12e-8 + FZ_cap^4 * -1.45e-11;
            % CS_lat = 2.79e3 + FZ_cap * 9.49e1 + FZ_cap^2 * -1.41e-1 + FZ_cap^3 * 1.22e-4 + FZ_cap^4 * -4.2e-8;
            % Mu_lat = 4.67 + FZ_cap * -7.49e-3 + FZ_cap^2 * 1.3e-5 + FZ_cap^3 * -1.05e-8 + FZ_cap^4 * 3.17e-12;
            % lat_coeff = [B_lat, E_lat, Mu_lat, CS_lat];
            % 
            % %long_coeff = [coeffs.long.B(P,IA,FZ_cap), coeffs.long.E(P,IA,FZ_cap),coeffs.long.CS(P,IA,FZ_cap),coeffs.long.Mu(P,IA,FZ_cap)];
            % B_long = 9.09e-1 + FZ_cap * 2.83e-3 + FZ_cap^2 * -9.41e-6 + FZ_cap^3 * 9.52e-9 + FZ_cap^4 * -3.26e-12;
            % E_long = -1.5 + FZ_cap * 2.33e-2 + FZ_cap^2 * -8.2e-5 + FZ_cap^3 * 1e-7 + FZ_cap^4 * -3.92e-11;
            % CS_long = 3.35e4 + FZ_cap * -1.58e2 + FZ_cap^2 * 5.34e-1 + FZ_cap^3 * -5.72e-4 + FZ_cap^4 * 2.07e-7;
            % Mu_long = 3.03 + FZ_cap * 1.59e-2 + FZ_cap^2 * -5.4e-5 + FZ_cap^3 * 5.99e-8 + FZ_cap^4 * -2.2e-11;
            % long_coeff = [B_long, E_long, Mu_long, CS_long];

            % Find Magic formula coefficients from look-up tables of TTC data:
            B_lat = model.latB(P,IA,FZ_cap);
            E_lat = model.latE(P,IA,FZ_cap);
            CS_lat = model.latCS(P,IA,FZ_cap);
            Mu_lat = model.latMu(P,IA,FZ_cap);
            lat_coeff = [B_lat, E_lat, Mu_lat, CS_lat];

            B_long = model.longB(P,IA,FZ_cap);
            E_long = model.longE(P,IA,FZ_cap);
            CS_long = model.longCS(P,IA,FZ_cap);
            Mu_long = model.longMu(P,IA,FZ_cap);
            long_coeff = [B_long, E_long, Mu_long, CS_long];

            % First Sweep SL, slip ratio, to find max longitudinal force
            SL = linspace(-0.2,0.2,n);
            SA = zeros(1,n);

            % Find max Fx
            [Fx,~] = combinedPacejkaFix(SA, SL, lat_coeff, long_coeff, FZ);
            [Fx_max_ij, k] = max(Fx);
            F_xmax = [F_xmax, Fx_max_ij * Scaling_factor];  % FS community recommends a scaling factor of 2/3 be applied to TTC results.
            SL_max = [SL_max, SL(k)];
            
            % Then Sweep SA, slip angle, to find max lateral force 
            SL = zeros(1,n);
            SA = linspace(-10,10,n);
            SA = deg2rad(SA);

            % Find max Fy
            [~,Fy] = combinedPacejkaFix(SA, SL, lat_coeff, long_coeff, FZ);
            [Fy_max_ij, k] = max(Fy);
            F_ymax = [F_ymax, Fy_max_ij * Scaling_factor];
            SA_max = [SA_max, SA(k)];
        end
    end

    F_ymax = reshape(F_ymax, size(F_z));
    F_ymax = transpose(squeeze(F_ymax));
    F_xmax = reshape(F_xmax, size(F_z));
    F_xmax = transpose(squeeze(F_xmax));
    SL_max = reshape(SL_max, size(F_z));
    SL_max = transpose(squeeze(SL_max));
    SA_max = reshape(SA_max, size(F_z));
    SA_max = transpose(squeeze(SA_max));

end