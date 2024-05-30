function [PvRPM] = hybrid_powertrain(engine_power_curve, motor_power_curve, motor_cutoff)



rpm_step = 50;

%make a combined curve
%hybrid_power_curve = zeros( engine_power_curve(14,1),2);

for rpm = 1 : rpm_step : engine_power_curve(14,1)
    if rpm < engine_power_curve(1,1) 
        % motor power only
        param(rpm) = 0;
        PvRPM(rpm, 1) = rpm ;
        PvRPM(rpm,2) = interp1( motor_power_curve(:,1) , motor_power_curve(:,2) , rpm);
    elseif rpm >= engine_power_curve(1,1) && rpm < motor_cutoff
        % combined engine and motor power
        param(rpm) = 2;
        PvRPM( rpm, 1) = rpm;
        PvRPM(rpm,2) = interp1(motor_power_curve(:,1) , motor_power_curve(:,2) , rpm) + interp1(engine_power_curve(:,1) , engine_power_curve(:,2) , rpm);
    elseif rpm >= motor_cutoff
            % engine power only
            param(rpm) = 1;
            PvRPM(rpm,1) = rpm;
            PvRPM(rpm,2) = interp1(engine_power_curve(:,1), engine_power_curve(:,2),  rpm);    
    end
end

% plot(engine_power_curve(:,1), engine_power_curve(:,2),".r")
% hold on
% plot(motor_power_curve(:,1), motor_power_curve(:,2),".g")
% hold on
% plot(PvRPM(:,1),PvRPM(:,2),".b")
% legend('engine','motor','hybrid')
% xlabel('RPM')
% ylabel('Power (W)')
end