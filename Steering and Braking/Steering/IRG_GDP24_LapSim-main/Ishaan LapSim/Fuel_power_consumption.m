function [fuel_consumed,power_consumed] = Fuel_power_consumption(engine_fuel_consumption_polynomial, motor_power_consumption_polynomial, motor_cutoff, rpm, rpm_elec, car)
% engine_fuel_rpm_curve = [2414, 8.085921992;
%                       3217, 17.48278436;
%                       3703, 21.06848219;
%                       4248, 23.29633513;
%                       8157, 51.33599258;
%                       9005, 60.27290726;
%                       9412, 64.94702863;
%                       9839, 69.37141511;
%                       10331, 72.81677223;
%                       10875, 75.10159664;
%                       11849, 82.14227112;
%                       12376, 84.78473319;
%                       13200, 86.1646508;
%                       13984, 82.65590919];
%
% motor_power_rpm_curve = [0.0, 0.0;
%                     6286.2944, 34.0388;
%                     6375.6345, 34.4911;
%                     6497.4619, 34.6042;
%                     6578.6802, 34.7173;
%                     6643.6548, 34.7173;
%                     6749.2386, 34.2649;
%                     6846.7005, 34.0388;
%                     6960.4061, 33.8126;
%                     7065.9898, 33.5864;
%                     7285.2792, 33.2472;
%                     7512.6904, 32.9079;
%                     7683.2487, 32.9079;
%                     7991.8782, 32.7948];
%
% motor_fuel_rpm_curve = [motor_power_rpm_curve(:,1), motor_power_rpm_curve(:,2).*(1/efficiency)];
% rpm_step = 1;
% rpm = 5000;
%
% engine_range =  engine_power_curve(1,1) : rpm_step : engine_power_curve(14,1);
% motor_range = motor_power_curve(1,1) : rpm_step : motor_power_curve(14,1);
%
% engine = polyfit(engine_power_curve(:,1), engine_power_curve(:,2),3);
% motor = polyfit(motor_power_curve(:,1), motor_power_curve(:,2),3);

if car.type == "hybrid"
    if rpm < car.engine_model(1,1) %NOTE: UPDATE WITH ENGINE FUEL CURVE OBJECT.
        power_consumed = polyval(car.motor_power_RPM,rpm);
        fuel_consumed = polyval(car.engine_fuel_RPM,car.engine_model(1,1));
    elseif rpm < motor_cutoff
        power_consumed = polyval(car.motor_power_RPM,rpm);
        fuel_consumed = polyval(car.engine_fuel_RPM,rpm);
    elseif rpm >= motor_cutoff
        fuel_consumed = polyval(car.engine_fuel_RPM,rpm);
        power_consumed = 0;
    end
elseif car.type == "engine"
    fuel_consumed = polyval(car.engine_fuel_RPM,rpm);
    power_consumed = 0;
elseif car.type == "electric"
    fuel_consumed = 0;
    power_consumed = polyval(car.motor_power_RPM,rpm);

elseif car.type == "hybridTTRhub"
    if rpm < car.engine_model(1,1) && rpm_elec < car.motor_cutoff %If engine is idling and rpm_elec below cutoff
        power_consumed = polyval(car.motor_power_RPM,rpm_elec);
        fuel_consumed = polyval(car.engine_fuel_RPM,car.engine_model(1,1));
    elseif rpm_elec < motor_cutoff && rpm >= car.engine_model(1,1) %If engine above idling and rpm_elec below cutoff
        power_consumed = polyval(car.motor_power_RPM,rpm_elec);
        fuel_consumed = polyval(car.engine_fuel_RPM,rpm);
    elseif rpm_elec >= motor_cutoff && rpm >= car.engine_model(1,1)
        fuel_consumed = polyval(car.engine_fuel_RPM,rpm);
        power_consumed = 0;
    end
end


end






