function [T,r] = Motor_Torque(velocity,radius,ratios,PvRPM_front, PvRPM_rear, type ,sl, sl_matrix)
%   Author:   Jakub Horsky & Charalampos Charalampous
%             jakub.horsky.cz@gmail.com & cc2621@ic.ac.uk
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
%   Returns:
%       T {2x2 matrix} -- torque on each wheel
%       r {double} -- gear ratio that was used
%
%   Physical Modelling Assumptions:
%       no shift time
%       perfect transmition of torque from motor to wheels
%       torque on the left and the right wheel will be identical


if (type == "engine")
    wheel_ang = velocity / radius;

%   Condition applies if the angular velocity of the drive shaft from the
%   wheel after the gearbox with the maximal gear ratio is higher than the 
%   minimal angular velocity of the engine
    if (60*wheel_ang*max(ratios)/(2*pi) > min(PvRPM(:,1)))
        
        %finds the power coresponding to each gear ratio
        for i = 1:length(ratios)
            RPM(i) = 60*wheel_ang*ratios(i)/(2*pi);
            if (RPM(i) > min(PvRPM(:,1)) && RPM(i) < max(PvRPM(:,1)))
                power(i) = interp1(PvRPM(:,1),PvRPM(:,2),RPM(i));
            else %if the RPM of the driveshaft from the wheel with given gear ratio is greater than the RPM range of engine -> motor cannot power the driveshaft and power = 0
                power(i) = 0; 
            end
        end
        [Power, index] = max(power);

        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;

        T_RR = (Power/wheel_ang) / 2;
        T_RL = T_RR;

        r = ratios(index);

%   If the the drive shaft with the highest gear ratio is rotating 
%   slower than the engine's lowest RPM.
    else 
        Torque = PvRPM(1,2)*max(ratios)/(PvRPM(1,1)*2*pi/60);

        T_FR = zeros(length(velocity),1);
        T_FL = T_FR;

        T_RR = (Torque) / 2;
        T_RL = T_RR;

        r = max(ratios);
    end

elseif (type == "electric")
    
    % wheel_ang = velocity / radius;
    % RPM = 60*wheel_ang*ratios/(2*pi);
    % 
    % if (RPM <= PvRPM(size(PvRPM,1),1)) && (RPM >= 0)
    %     power = interp1(PvRPM(:,1),PvRPM(:,2),RPM);
    % else
    %     power = 0;
    % end
    % 
    % T_FR = zeros(length(velocity),1);
    % T_FL = T_FR;
    % 
    % T_RR = (power/wheel_ang) / 2;
    % T_RL = T_RR;
    T = zeros(2,2);

    i = 1;
    for j = 1:2

            % % wheel_ang = velocity * (sl(i,j)+1) / radius;
            % wheel_ang = velocity  / radius;
            % RPM = 60*wheel_ang*ratios/(2*pi);

            % if (RPM <= PvRPM_front(size(PvRPM_front,1),1)) && (RPM >= 0)
            %     power = interp1(PvRPM_front(:,1),PvRPM_front(:,2),RPM);
            % else
            %     power = 0;
            % end

            % T(i,j) = power/wheel_ang/2;
            T(i,j)=0;



    end

    i = 2;
    for j = 1:2

            % wheel_ang = velocity * (sl(i,j)+1) / radius;
            wheel_ang = velocity  / radius;
            RPM = 60*wheel_ang*ratios/(2*pi);

            if (RPM <= PvRPM_rear(size(PvRPM_rear,1),1)) && (RPM >= 0)
                power = interp1(PvRPM_rear(:,1),PvRPM_rear(:,2),RPM);
            else
                power = 0;
            end

            T(i,j) = power/wheel_ang/2;



    end
    
    r = ratios;

    return



elseif (type == "electricAWD")

    T = zeros(2,2);
    
    i = 1;
    for j = 1:2

            % wheel_ang = velocity * (sl(i,j)+1) / radius;
            wheel_ang = velocity  / radius;
            RPM = 60*wheel_ang*ratios/(2*pi);

            if (RPM <= PvRPM_front(size(PvRPM_front,1),1)) && (RPM >= 0)
                power = interp1(PvRPM_front(:,1),PvRPM_front(:,2),RPM);
            else
                power = 0;
            end

            T(i,j) = power/wheel_ang/2;



    end

    i = 2;
    for j = 1:2

            % wheel_ang = velocity * (sl(i,j)+1) / radius;
            wheel_ang = velocity  / radius;
            RPM = 60*wheel_ang*ratios/(2*pi);

            if (RPM <= PvRPM_rear(size(PvRPM_rear,1),1)) && (RPM >= 0)
                power = interp1(PvRPM_rear(:,1),PvRPM_rear(:,2),RPM);
            else
                power = 0;
            end

            T(i,j) = power/wheel_ang/2;



    end


    r = ratios;
    
    return


end

T = [T_FL,T_FR;T_RL,T_RR];
