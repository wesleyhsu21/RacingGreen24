function [ax, log] = v2Calc(car, model, v, radius_d, itt_lim, err_margin, i, x, y,varargin)
%   Author:     Jakub Horsky
%               jakub.horsky.cz@gmail.com
%
%   Calculates the maximal acceleration on a segment of track
%   with a given raduis of curvature and velocity
%
%   Arguments:
%       car {structure} -- includes all car constants
%       model {structure} -- contains tire data
%       v {double} -- velocity (m/s)
%       radius_d {double} -- radius of curvature (m)
%       itt_limit {int} -- max number of iterations
%       err_margin {double} -- acceptible margin of error in iterative clculation
%       >>optional
%       ax {double} -- ax in previous segment for dynamic calculation
%
%   Returns:
%       ax {double} -- max acceleration (m/s^2)
%       log {structure} -- logs relevand data (tire forces, ay, etc.)
%

switch nargin
    case 9
        ax = 0;
    case 10
        ax = varargin{1};
end
g = 9.81;
err = inf;
itt = 1;
log = slog(1);
U = zeros(3,1);

ay = v^2/radius_d;
Fy_total = ay*car.mass;

while (err > err_margin) && (itt < itt_lim)

    [F_L,F_D,F_S] = Aero_Forces(v,car,U);
    M_roll = ay*car.mass*car.cog_height + car.cop_height*F_S;
    
    Fz_total = car.mass*g - F_L;
    
    %calculating max roll, pitch moments the car is able to sustain (its a
    %deltoid with edges at maxRoll, maxPitch, minPitch (and minRoll))
    [maxRoll, maxPitch,~] = MaxMomentsCalc(Fz_total, car);
    
    %caclulating max pitch moments given the M_roll (M_roll not dependant on the ax)
    M_pitchPossible = interp1([maxPitch(1),maxRoll(1)],[maxPitch(2),maxRoll(2)],abs(M_roll));
    
    %calculating pitch moment components independant of ax
    M_pitch_weight = car.mass * g * (car.cog_split-0.5) * car.wheelbase;
    M_pitch_F_D = F_D * car.cop_height;
    M_pitch_F_L = - F_L * (car.cop_split-0.5) * car.wheelbase;
    
    %max leteral acceleration that the car is able to sustain
    ax_pitch_limit = (M_pitchPossible - (M_pitch_weight + M_pitch_F_D + M_pitch_F_L)) / (car.mass * car.cog_height);
    ax_itt_log = zeros(1,itt_lim);
    ax_itt_log(1) = ax;
    
    %Calculating pitch moment based on ax
    M_pitch_ax = car.mass * ax * car.cog_height;
    M_pitch = M_pitch_weight + M_pitch_F_D + M_pitch_F_L + M_pitch_ax;
    
    %If pitch moments is higher than possible it will be set to the max
    %value
    if (M_pitch > M_pitchPossible)
        M_pitch = M_pitchPossible;
    end
    
    %calculating Fz on each tire
    Fz = zeros(1,2,2);
    [Fz(1,:,:),U] = FzCalc(M_roll, M_pitch, Fz_total, car);
    
    %calculating max possible Fx each tire can sustain
    [Fx_max(1,:,:),Fy_max(1,:,:),~,~] = tyre_fmax_ttc_v2(Fz(1,:,:), model, car);
    Fy(1,:,:) = (Fz(1,:,:) / Fz_total) * Fy_total;
    Tire_Fx(1,:,:) = Find_Fx(Fy(1,:,:), Fx_max(1,:,:), Fy_max(1,:,:));
    
    [sl,sa,stra,chang,Tire_Fx,~] = newtirefunc(Tire_Fx(1,:,:),Fy(1,:,:),Fz(1,:,:),model,car,radius_d);

    Tire_Fx = reshape(Tire_Fx,[1,2,2]);

    Tire_Fx(1,1,1) = Tire_Fx(1,1,1) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),sl(1,1));
    Tire_Fx(1,2,1) = Tire_Fx(1,2,1) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),sl(2,1));
    Tire_Fx(1,1,2) = Tire_Fx(1,1,2) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),sl(1,2));
    Tire_Fx(1,2,2) = Tire_Fx(1,2,2) .* interp1(car.slip_matrix(:,1),car.slip_matrix(:,2),sl(2,2));



    %calculating max Fx motor can produce on each tire
    [Motor_T, R] = Motor_Torque(v, car.wheel_rad, car.ratios, car.motor_model_front, car.motor_model_rear, car.type ,sl,car.slip_matrix);
    Motor_Fx = zeros(1,2,2);
    Motor_Fx(1,:,:) = Motor_T ./ car.wheel_rad;
    
    Fx(1,:,:) =  min([Motor_Fx;Tire_Fx]); %caps the values of Fx on each tire by the min Fx (either limited by motor power or tire grip
    limiting_factor = all(Motor_Fx == Fx,'all'); %limiting_factor = 1 if all acceleration force limited by the motor torque; limiting_factor = 0 if limited by tire grip
    
    %Calculating ax and err
    Fx_sum = sum(Fx(1,:,:),'all');
    ax_motor_tires_limit = Fx_sum / car.mass;
    ax_prv = ax;
    ax = min(ax_motor_tires_limit, ax_pitch_limit);
    if (ax_pitch_limit == ax)
        limiting_factor = 2; %if limited by moments/car rolling over
    end
    itt = itt + 1;
    ax_itt_log(itt) = ax;
    
    if (ax_prv == 0) && (ax < 1e-3)
        err = 0;
        ax = 0;
    else
        err = abs(ax_prv - ax)/ax_prv;

    end
end

ax = ax - F_D/car.mass; %adds the decceleration due to the drag force

log.ax = ax;
log.err = err;
log.ax_itt = ax_itt_log;
log.itt = itt;
log.ay = ay;
log.Fz = Fz;
log.Fy = Fy;
log.Fx = Fx;
log.Tire_Fx = Tire_Fx;
log.Motor_Fx = Motor_Fx;
log.F_L = F_L;
log.F_D = F_D;
log.R = R;
log.limiting_factor = limiting_factor;
log.U = U;
log.sl = reshape(sl,[1,2,2]);
log.sa = reshape(sa,[1,2,2]);
log.stra = stra;
log.chang = chang;





end

