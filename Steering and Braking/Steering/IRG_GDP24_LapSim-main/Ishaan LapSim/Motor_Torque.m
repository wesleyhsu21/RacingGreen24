function [T,r,RPM, enginePower,RPM_elec,RPM_limit_hit] = Motor_Torque(velocity,radius,ratios,~ ,sl, carparams)

%   Author:   Jakub Horsky and Aaditya Aaditya
%             jakub.horsky.cz@gmail.com
%
% Calculates Torque (and optionally gear ratio) on a each wheel
%
%   Arguments:
%       velocity {double} -- velocity of the car [m/s]
%       radius {double} -- radius of the wheels [m]
%       ratios {array} -- gear ratio(s) in the gearbox
%       PvRPM {2xn matrix} -- power [W] to rpm graph of the engine/elecrtric
%       motor
%       type {string} -- type of the power_unit, either "electric" (for
%       electric motor) or "engine" (for combustion engine)
%       s1 -- slip factor
%   Returns:
%       T {2x2 matrix} -- torque on each wheel
%       r {double} -- gear ratio that was used
%
%   Physical Modelling Assumptions:
%       no shift time
%       perfect transmition of torque from motor to wheels
%       torque on the left and the right wheel will be identical

if (carparams.type == "engine")
    wheel_ang = velocity / radius;
    % use torque cuve for the engine
    PvRPM = carparams.engine_model;
    %   Condition applies if the angular velocity of the drive shaft from the
    %   wheel after the gearbox with the maximal gear ratio is higher than the
    %   minimal angular velocity of the engine
    if (60*wheel_ang*max(ratios)/(2*pi) > min(PvRPM(:,1)))
        %finds the power coresponding to each gear ratio
        for i = 1:length(ratios)
            RPM(i) = 60*wheel_ang*ratios(i)/(2*pi);
            if (RPM(i) > min(PvRPM(:,1))) && (RPM(i) < max(PvRPM(:,1))) %engine can provide power
                power(i) = interp1(PvRPM(:,1),PvRPM(:,2),RPM(i));
            else %if the RPM of the driveshaft from the wheel with given gear ratio is outside the RPM range of engine -> engine cannot power the driveshaft
                power(i) = 0;
            end
        end
        [Power, index] = max(power);
        RPM = RPM(index);
        enginePower = Power;
        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;
        T_RR = (Power/wheel_ang) / 2;
        T_RL = T_RR;
        r = ratios(index);

        %   If the the drive shaft with the highest gear ratio is rotating
        %   slower than the engine's lowest RPM.
    else
        Torque = PvRPM(1,2)*max(ratios)/(PvRPM(1,1)*2*pi/60);
        RPM = PvRPM(1,1);
        enginePower = polyval(carparams.engine_model_poly,RPM);
        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;
        T_RR = (Torque) / 2;
        T_RL = T_RR;
        r = max(ratios);
    end

elseif (carparams.type == "hybrid") %Same as above, except with a new power curve
    wheel_ang = velocity / radius;
    % make and use a combined torque curve
    PvRPM = hybrid_powertrainV2(carparams.engine_model_poly,carparams.motor_model_poly, carparams);
    if (60*wheel_ang*max(ratios)/(2*pi) > min(PvRPM(:,1)))
        for i = 1:length(ratios)
            RPM(i) = 60*wheel_ang*ratios(i)/(2*pi);
            if (RPM(i) > min(PvRPM(:,1))) && RPM(i) < max(PvRPM(:,1)) %engine can provide power
                power(i) = interp1(PvRPM(:,1),PvRPM(:,2),RPM(i));
            else %if the RPM of the driveshaft from the wheel with given gear ratio is outside the RPM range of engine -> engine cannot power the driveshaft
                power(i) = 0;
            end
        end
        [Power, index] = max(power);
        RPM = RPM(index);
        RPM_limit_hit = 0;
        if RPM >= max(PvRPM(:,1)) %If the RPM exceeds the limiter, then caps it to the limiter and calculates the power generated in this case.
            RPM_limit_hit = 1;
            RPM = max(PvRPM(:,1))/min(ratios);
            Power = interp1(PvRPM(:,1),PvRPM(:,2),RPM);
        end
        enginePower = polyval(carparams.engine_model_poly,RPM); %Engine only power.
        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;
        T_RR = (Power/wheel_ang) / 2;
        T_RL = T_RR;
        r = ratios(index);
	    if RPM == max(PvRPM(:,1))/min(ratios) && all(power(find(~isnan(power))) == 0) %Setting to minimum gear ratio, as this would be required for this to function.
		    r = ratios(length(power));
	    end
    else
        Torque = PvRPM(1,2)*max(ratios)/(PvRPM(1,1)*2*pi/60);
        RPM = PvRPM(1,1);
        enginePower = polyval(carparams.engine_model_poly,RPM);
        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;
        T_RR = (Torque) / 2;
        T_RL = T_RR;
        r = max(ratios);
        RPM_limit_hit = 0;
    end

elseif (carparams.type == "electric")
    wheel_ang = velocity * (sl(1,2,1)+1) / radius;
    % Use electric torque curve
    PvRPM = carparams.motor_model;
    enginePower = 0;
    RPM = 60*wheel_ang*carparams.motor_ratio/(2*pi);

    if (RPM <= PvRPM(size(PvRPM,1),1)) && (RPM >= 0)
        power = interp1(PvRPM(:,1),PvRPM(:,2),RPM);
    else
        power = 0;
    end
    T_FR = zeros(length(velocity),1);
    T_FL = T_FR;
    T_RR = (power/wheel_ang) / 2;
    T_RL = T_RR;
    r = carparams.motor_ratio;

elseif carparams.type == "hybridTTRhub"
    %Hybrid through the road with hub motors
    wheel_ang_eng = velocity / radius;
    % use torque cuve for the engine
    PvRPM = carparams.engine_model;
    %   Condition applies if the angular velocity of the drive shaft from the
    %   wheel after the gearbox with the maximal gear ratio is higher than the
    %   minimal angular velocity of the engine
    if (60*wheel_ang_eng*max(ratios)/(2*pi) > min(PvRPM(:,1)))
        %finds the power coresponding to each gear ratio
        for i = 1:length(ratios)
            RPM(i) = 60*wheel_ang_eng*ratios(i)/(2*pi);
            if RPM(i) > carparams.engine_model(end,1) %Including a rev limiter.
                RPM(i) = carparams.engine_model(end,1);
            end
            if (RPM(i) > min(PvRPM(:,1)) && RPM(i) < max(PvRPM(:,1))) %engine can provide power
                power(i) = interp1(PvRPM(:,1),PvRPM(:,2),RPM(i));
            else %if the RPM of the driveshaft from the wheel with given gear ratio is outside the RPM range of engine -> engine cannot power the driveshaft
                power(i) = 0;
            end
        end
        [Power, index] = max(power);
        RPM = RPM(index);
        T_RR = (Power/wheel_ang_eng) / 2;
        T_RL = T_RR;
        r = ratios(index);
        enginePower = Power;
        %   If the the drive shaft with the highest gear ratio is rotating
        %   slower than the engine's lowest RPM.
    else
        Torque = PvRPM(1,2)*max(ratios)/(PvRPM(1,1)*2*pi/60);
        RPM = PvRPM(1,1);
        enginePower = polyval(carparams.engine_model_poly,RPM);
        if RPM > carparams.engine_model(end,1) %Including a rev limiter.
            RPM = carparams.engine_model(end,1);
        end
        T_RR = (Torque) / 2;
        T_RL = T_RR;
        r = max(ratios);
    end
    wheel_ang = velocity * (sl(1,2,1)+1) / radius;
    % Use electric torque curve
    PvRPM = carparams.motor_model;
    RPM_elec = 60*wheel_ang*carparams.motor_ratio/(2*pi);
    if RPM_elec > max(carparams.motor_model(:,1))
        RPM_elec = max(carparams.motor_model(:,1));
    end
    if RPM_elec >= 0 && RPM_elec < carparams.motor_cutoff
        power_elec = interp1(PvRPM(:,1),PvRPM(:,2),RPM_elec);
    else
        power_elec = 0;
    end
    T_FL = (power_elec/wheel_ang)/2;
    T_FR = T_FL;


end
T = [T_FL,T_FR;T_RL,T_RR];
if carparams.type ~= "hybridTTRhub"
    RPM_elec = 0;
end
if carparams.type ~= "hybrid"
    RPM_limit_hit = 0;
end

end


