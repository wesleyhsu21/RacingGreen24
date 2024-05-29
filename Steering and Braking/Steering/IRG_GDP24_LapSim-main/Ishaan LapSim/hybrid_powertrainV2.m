function [PvRPM] = hybrid_powertrainV2(engine_power_curve, motor_power_curve, car)

rpm_step = 50; %Step set based on discussion with IRG10 team.

%make a combined curve
%hybrid_power_curve = zeros( engine_power_curve(14,1),2);

for rpm = 1 : rpm_step : car.engine_model(end,1)
    if rpm < car.engine_model(1,1) 
        % motor power only
        param(idivide(int16(rpm),int16(rpm_step)) + 1) = 0;
        PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1, 1) = rpm ;
        PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1,2) = polyval(motor_power_curve,rpm);
    elseif rpm >= car.engine_model(1,1) && rpm < car.motor_cutoff
        % combined engine and motor power
        param(idivide(int16(rpm),int16(rpm_step)) + 1) = 2;
        PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1, 1) = rpm;
        PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1,2) = polyval(motor_power_curve,rpm) + polyval(engine_power_curve,rpm);
    elseif rpm >= car.motor_cutoff
            % engine power only
            param(idivide(int16(rpm),int16(rpm_step)) + 1) = 1;
            PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1,1) = rpm;
            PvRPM(idivide(int16(rpm),int16(rpm_step)) + 1,2) = polyval(engine_power_curve,rpm);    
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