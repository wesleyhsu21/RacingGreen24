function [v] = v1Calc(car, model, radius_d, itt_lim, err_margin)

g = 9.81;
err = inf;
itt = 1;
v_log = zeros(1,itt_lim);
v = 0;
U = zeros(3,1);

while (err > err_margin) && (itt < itt_lim)

    [F_L,F_D,F_S] = Aero_Forces(v,car,U);

    Fz_total = car.mass*g - F_L;

    ay = v^2/radius_d;

    M_roll = ay*car.mass*car.cog_height + car.cop_height*F_S;

    M_pitch = (car.mass * g * (car.cog_split-0.5) * car.wheelbase + F_D * car.cop_height - F_L * car.wheelbase * (car.cop_split-0.5));

    [maxRoll, maxPitch, minPitch] = MaxMomentsCalc(Fz_total, car);

    M_rollPossible = interp1([maxPitch(2),maxRoll(2),minPitch(2)],[maxPitch(1),maxRoll(1),minPitch(1)],M_pitch);

    if isnan(M_rollPossible)
       
        error("Pitch Moment over the max pitch v1")
       
        disp("Pitch Moment over the max pitch v1");
        
        break

    elseif (M_roll > M_rollPossible)
        %If roll moment higher than the max possible the new velocity will
        %be calculated based on this limit
        ay = M_rollPossible / (car.mass * car.cog_height);

        v_roll = sqrt(abs(ay*radius_d));
        
        Fz = zeros(1,2,2);
        [Fz(1,:,:),U] = FzCalc(M_rollPossible, M_pitch, Fz_total, car);

        %Calculates max Fy on each tire

        [~,Fy_max,~,~] = tyre_fmax_ttc_v2(Fz, model, car);

        Fy_sum = sum(Fy_max, 'all');

        v_Fy = (abs((Fy_sum * radius_d)/car.mass)).^0.5;
        
        v_prv = v;
        v = min(v_Fy, v_roll);
        err = abs((v - v_prv) / v_prv);
        itt = itt+1;
        v_log(itt) = v;
        continue
    end
    
    %Calculates Fz on each tire
    Fz = zeros(1,2,2);
    [Fz(1,:,:),U] = FzCalc(M_roll, M_pitch, Fz_total, car);
    
    %Calculates max Fy on each tire
    [~,Fy_max,~,~] = tyre_fmax_ttc_v2(Fz, model, car);
    
    Fy_sum = sum(Fy_max, 'all');

    %max possible velocity for given centripetal force, F = m * v^2 / r
    v_prv = v;

    v = (abs((Fy_sum * radius_d)/car.mass)).^0.5;

    if (v == 0) && (v_prv < 1e-3)
        err = 0;
        v = 0;
    else
        err = abs((v - v_prv) / v_prv);
    end

    itt = itt + 1;
    v_log(itt) = v;


end

end



