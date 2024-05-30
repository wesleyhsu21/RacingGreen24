function [ax, log, Sa] = v3Calc2(car, model, v, radius_d, itt_lim, err_margin,x,y,i)
%   Author:     Jakub Horsky
%               jakub.horsky.cz@gmail.com
%
%   Calculates the maximal breaking acceleration on a segment of track
%   with a given raduis of curvature and velocity
%
%   Arguments:
%       car {structure} -- includes all car constants
%       model {structure} -- contains tire data
%       v {double} -- velocity (m/s)
%       radius_d {double} -- radius of curvature (m)
%       itt_limit {int} -- max number of iterations
%       err_margin {double} -- acceptible margin of error in iterative clculation
%
%   Returns:
%       ax {double} -- max acceleration (m/s^2)
%       log {structure} -- logs relevand data (tire forces, ay, etc.)
%

g = 9.81;
err = inf;
itt = 1;
ax = 0;
ax_prv = 0;
Sa = zeros(2,2);
ay = v^2/radius_d;
Fy_total = ay*car.mass;
U = zeros(3,1);


while (err > err_margin) && (itt < itt_lim)

    [F_L,F_D,F_S] = Aero_Forces(v,car,U);
    M_roll = ay*car.mass*car.cog_height + car.cop_height*F_S;
    Fz_total = car.mass*g - F_L;
    log = slog(1);
    
    %calculating max roll, pitch moments the car is able to sustain (its a
    %deltoid with edges at maxRoll, maxPitch, minPitch (and minRoll))
    [maxRoll,~, minPitch] = MaxMomentsCalc(Fz_total, car);
    
    if any(isnan(maxRoll)) == true &&  any(isnan(minPitch)) == true
    
        ax = 0;
        log = slog(1);
        Sa = zeros(2,2);
        
        return
        
    end
    %caclulating max pitch moments given the M_roll (M_roll not dependant on the ax)
    M_pitchPossible = interp1([minPitch(1),maxRoll(1)],[minPitch(2),maxRoll(2)],abs(M_roll));
    
    %calculating pitch moment components independant of ax
    M_pitch_weight = car.mass * g * (car.cog_split-0.5) * car.wheelbase;
    M_pitch_F_D = F_D * car.cop_height;
    M_pitch_F_L = - F_L * (car.cop_split-0.5) * car.wheelbase;
    
    %max leteral acceleration that the car is able to sustain
    ax_pitch_limit = (M_pitchPossible - (M_pitch_weight + M_pitch_F_D + M_pitch_F_L)) / (car.mass * car.cog_height);
    ax_log = zeros(1,itt_lim);
    errArr = zeros(1,itt_lim);
    
    ax1 = 0;
    ax2 = ax_pitch_limit;
        
    ax = (ax1+ax2)/2;
    %Calculating pitch moment based on ax
    M_pitch_ax = car.mass * ax * car.cog_height;
    M_pitch = M_pitch_weight + M_pitch_F_D + M_pitch_F_L + M_pitch_ax;
    
    %If pitch moments is higher than possible it will be set to the max
    %value
    if (M_pitch < M_pitchPossible)
        error("Pitch moment over the limit")
        disp("Pitch moment over the limit")
        M_pitch = M_pitchPossible;
    end
    
    %calculating Fz on each tire
    Fz = zeros(1,2,2);
    [Fz(1,:,:),U] = FzCalc(M_roll, M_pitch, Fz_total, car);
%     disp("Fz")
%     squeeze(Fz)
    
    %calculating max possible Fx each tire can sustain
    [Fx_max(1,:,:),Fy_max(1,:,:),~,~] = tyre_fmax_ttc_v2(Fz(1,:,:), model, car);
    Fy(1,:,:) = (Fz(1,:,:) / Fz_total) * Fy_total;
    Tire_Fx(1,:,:) = - Find_Fx(Fy(1,:,:), Fx_max(1,:,:), Fy_max(1,:,:)); %minus for breaking
    
    try
    [sl,sa,stra,chang,Tire_Fx,~] = newtirefunc(Tire_Fx(1,:,:),Fy(1,:,:),Fz(1,:,:),model,car,radius_d);
    catch e
        error(e.message);
    end
    Tire_Fx = reshape(Tire_Fx,[1,2,2]);

    Tire_Fx(1,1,1) = Tire_Fx(1,1,1) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),abs(sl(1,1)));
    Tire_Fx(1,2,1) = Tire_Fx(1,2,1) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),abs(sl(2,1)));
    Tire_Fx(1,1,2) = Tire_Fx(1,1,2) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),abs(sl(1,2)));
    Tire_Fx(1,2,2) = Tire_Fx(1,2,2) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),abs(sl(2,2)));
   
    %apply break bias
    Fx_F_bb = zeros(2,2);
    Fx_R_bb = zeros(2,2);
    Fx_F_bb(1,:) = max(Tire_Fx(1,1,:));
    Fx_F_bb(2,:) = max(Tire_Fx(1,1,:))*(1-car.brakeSystem.brake_bias)/car.brakeSystem.brake_bias;
    Fx_R_bb(2,:) = max(Tire_Fx(1,2,:));
    Fx_R_bb(1,:) = max(Tire_Fx(1,2,:))*car.brakeSystem.brake_bias/(1-car.brakeSystem.brake_bias);
    Fx_bb = max(Fx_R_bb, Fx_F_bb);
    Fx_sum = sum(Fx_bb, 'all');
    Fx_sum2 = max(sum(Fx_F_bb, 'all'),sum(Fx_R_bb, 'all'));
    if (Fx_sum ~= Fx_sum2)

        disp("Fx_sum do not equal");
        
    end
    
    ax_breaks_limit = Fx_sum / car.mass;
    ax_returned = max(ax_breaks_limit, ax_pitch_limit);
    
    if (ax_returned == ax_breaks_limit) 
        limiting_factor = 0; %if limited by break bias/tire grip
    else
        limiting_factor = 2; %if limited by moments/car rolling over
    end
    
    if (ax_returned<ax)
        ax1 = ax;
    else
        ax2 = ax;
    end
    err = abs((ax - ax_returned)/ax);
    itt = itt + 1;
    ax_log(itt) = ax;
    errArr(itt) = err;
    if (ax_prv == 0) && (abs(ax) < 1e-3)
        err = 0;
        ax = 0;
    end
end
ax = ax - F_D/car.mass; %adds the decceleFzration due to the drag force

Fx_bb = reshape(Fx_bb,[1,2,2]);

i = i-1;

log.ax = ax;
log.err = err;
log.ax_itt = ax_log;
log.itt = itt;
log.ay = ay;
log.Fz = Fz;
log.Fy = Fy;
log.Fx = Fx_bb;
log.Tire_Fx = Tire_Fx;
log.Motor_Fx = zeros(1,2,2);
log.F_L = F_L;
log.F_D = F_D;
log.R = 0;
log.limiting_factor = limiting_factor;
log.U = U;
log.sa = reshape(sa, [1,2, 2]);
log.sl = reshape(sl, [1 ,2 ,2]);
log.stra = stra;
log.chang = chang;


end

