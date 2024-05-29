function [v,slog5] = velocity_finder(dist,radius,car)

load("tyrePoly.mat","model");

n = length(dist);

itt_lim = 10;

err_margin = 0.01;

sim_vel = simulation(n);

radius(isinf(radius)) = 10000;

slog5 = slog(n);

ax = 0;

for i = 1:n

    sim_vel.slog.v1(i,1) = v1Calc(car,model,radius(i),itt_lim,err_margin);

end

sim_vel.slog.v1(((sim_vel.slog.v1(:,1) > ((2*car.motor_power)/(1.184*car.CDA))^(1/3)) | (sim_vel.slog.v1(:,1) == 0)), 1) = ((2*car.motor_power)/(1.184*car.CDA))^(1/3);

%Calculating the RPM of the powertrain, assuming 100% efficiency
%between the translational velocity and the input of the powertrain.
%NOTE: currently unsure about the feasibility of this efficiency,
%changes may be made pending a subsequent discussion with the
%powertrain team.

slog5.rpm(:,1) = 60.*sim_vel.slog.v1./(2*pi*car.wheel_rad);
if car.type == "hybridTTRhub"
    slog5.rpm_elec(:,1) = slog5.rpm(:,1);
end
%Calculating fuel and power consumption according to the function defined
%by AA, as well as energy heat power generated (using thermal efficiency curve provided).

for i = 1:n

    [slog5.fuel_consumed(i,1),slog5.power_consumed(i,1)] = Fuel_power_consumption(car.engine_fuel_RPM,car.motor_power_RPM,car.motor_cutoff,slog5.rpm(i,1),slog5.rpm_elec(1,2),car);
    slog5.engine_heat_power(i,1) = polyval(car.engine_heat_model_poly,slog5.rpm(i,1));
    if slog5.rpm(i,1) >= car.engine_model(1,1)
        slog5.engine_heat_power(i,1) = (1 - polyval(car.engine_heat_model_poly,slog5.rpm(i,1))) * slog5.engine_heat_power(i,1);
    else
        slog5.engine_heat_power(i,1) = (1 - polyval(car.engine_heat_model_poly,car.engine_model(1,1))) * polyval(car.engine_model_poly,car.engine_model(1,1));
    end

end


for i = 1:n-1

    sim_vel.slog.v2(i) = min(sim_vel.slog.v1(i),sim_vel.slog.v2(i));

    [ax, slog1] = v2Calc(car, model, sim_vel.slog.v2(i), radius(i), itt_lim, err_margin, n,ax);

    slog5.rpm_elec(i,2) = slog1.rpm_elec(1,2);

    [slog5.fuel_consumed(i,2),slog5.power_consumed(i,2)] = Fuel_power_consumption(car.engine_fuel_RPM,car.motor_power_RPM,car.motor_cutoff,slog1.rpm(1,2),slog1.rpm_elec(1,2),car);

    slog5.R(i) = slog1.R;
    slog5.ax_log(i) = ax;
    slog5.ay(i) = slog1.ay;
    slog5.F_D(i) = slog1.F_D;
    slog5.F_L(i) = slog1.F_L;
    slog5.err(i) = slog1.err;
    slog5.itt(i) = slog1.itt;
    slog5.limiting_factor(i) = slog1.limiting_factor;
    slog5.ax_itt(i,:) = slog1.ax_itt;
    slog5.U(i,:) = slog1.U;
    slog5.Motor_Fx(i,:,:) = slog1.Motor_Fx(1,:,:);
    slog5.Tire_Fx(i,:,:) = slog1.Tire_Fx(1,:,:);
    slog5.sl(i,:,:) = slog1.sl(1,:,:);
    slog5.sa(i,:,:) = slog1.sa(1,:,:);
    slog5.Fx(i,:,:) = slog1.Fx(1,:,:);
    slog5.Fy(i,:,:) = slog1.Fy(1,:,:);
    slog5.Fz(i,:,:) = slog1.Fz(1,:,:);
    slog5.rpm(i,2) = slog1.rpm(1,2);
    slog5.RPM_limit_hit(i) = slog1.RPM_limit_hit;

    %Calculating engine heat power from the RPM calculated, if the RPM is
    %above the idling of the engine.
    slog5.engine_heat_power(i,2) = slog1.engine_heat_power(1,2);

    if slog5.rpm(i,2) >= car.engine_model(1,1)

        slog5.engine_heat_power(i,2) = (1 - polyval(car.engine_heat_model_poly,slog5.rpm(i,2))) * slog5.engine_heat_power(i,2);
   
    else
        
        slog5.engine_heat_power(i,2) = (1 - polyval(car.engine_heat_model_poly,car.engine_model(1,1))) * polyval(car.engine_model_poly,car.engine_model(1,1));
    
    end
    



    slog1.ax_log(i)  = ax;

    sim_vel.slog.v2(i+1) = (sim_vel.slog.v2(i)^2 + (2*ax*(dist(i+1) - dist(i))))^0.5;  % The sign on this needs changed should be + for the acceleration loop
end


for i = n:-1:2

    sim_vel.slog.v3(i) = min(sim_vel.slog.v2(i),sim_vel.slog.v3(i));

    [ax, slog2] = v3Calc2(car, model, sim_vel.slog.v3(i), radius(i), itt_lim, err_margin);

    sim_vel.slog.v3(i-1) = (sim_vel.slog.v3(i)^2 - (2*ax*(dist(i) - dist(i-1))))^0.5;

    %Calculating the rpm of the powertrain, assuming 100% efficiency, same
    %as with v1, and calculating fuel and power consumption according to the function defined by AA.

    slog5.rpm(i - 1,3) = 60.*sim_vel.slog.v3(i - 1)./(2*pi*car.wheel_rad);


    %Calculating engine heat power from the RPM calculated, if the RPM is
    %above the idling of the engine.

    slog5.engine_heat_power(i-1,3) = polyval(car.engine_heat_model_poly,slog5.rpm(i-1,3));

    if slog5.rpm(i-1,3) >= car.engine_model(1,1)
        slog5.engine_heat_power(i-1,3) = (1 - polyval(car.engine_heat_model_poly,slog5.rpm(i-1,3))) * slog5.engine_heat_power(i-1,3);
    else
        slog5.engine_heat_power(i-1,3) = (1 - polyval(car.engine_heat_model_poly,car.engine_model(1,1))) * polyval(car.engine_model_poly,car.engine_model(1,1));
    end

    if car.type == "hybridTTRhub"
    slog5.rpm_elec(i-1,3) = slog5.rpm(i-1,3);
    end
    [slog5.fuel_consumed(i - 1,3),slog5.power_consumed(i - 1,3)] = Fuel_power_consumption(car.engine_fuel_RPM,car.motor_power_RPM,car.motor_cutoff,slog5.rpm(i - 1,3),slog5.rpm_elec(i-1,3),car);


    if sim_vel.slog.v3(i-1) < sim_vel.slog.v2(i-1) && sim_vel.slog.v3(i-1) < sim_vel.slog.v1(i-1)

        slog5.R(i-1) = slog2.R(1);
        slog5.ax_log(i-1) = ax;
        slog5.ay(i-1) = slog2.ay;
        slog5.F_D(i-1) = slog2.F_D;
        slog5.F_L(i-1) = slog2.F_L;
        slog5.err(i-1) = slog2.err;
        slog5.itt(i-1) = slog2.itt;
        slog5.U(i-1,:) = slog2.U;
        slog5.ax_itt(i-1,:) = slog2.ax_itt;
        slog5.limiting_factor(i) = slog2.limiting_factor;
        slog5.Motor_Fx(i-1,:,:) = slog2.Motor_Fx(1,:,:);
        slog5.Tire_Fx(i-1,:,:) = slog2.Tire_Fx(1,:,:);
        slog5.sl(i-1,:,:) = slog2.sl(1,:,:);
        slog5.sa(i-1,:,:) = slog2.sa(1,:,:);
        slog5.Fx(i-1,:,:) = reshape(slog2.Fx, [1,2,2]);
        slog5.Fy(i-1,:,:) = slog2.Fy(1,:,:);
        slog5.Fz(i-1,:,:) = slog2.Fz(1,:,:);

    end
end

slog5.v1 = sim_vel.slog.v1;

slog5.v2 = sim_vel.slog.v2;

slog5.v3 = sim_vel.slog.v3;

v = zeros(n,1);

for i=1:n

    v(i,1) = min([slog5.v1(i,1),slog5.v2(i,1),slog5.v3(i,1)]);

    if v(i,1) == slog5.v1(i,1)

        slog5.fuel_consumed(i,4) = slog5.fuel_consumed(i,1);
        slog5.power_consumed(i,4) = slog5.power_consumed(i,1);
        slog5.rpm(i,4) = slog5.rpm(i,1);
        slog5.limiting_factor(i) = -1;
        slog5.vel_select(i) = 1;
        slog5.rpm_elec(i,4) = slog5.rpm_elec(i,1);

        if slog5.rpm(i,4) < car.motor_cutoff
            slog5.motor_heat_power(i) = slog5.power_consumed(i,1) * (1 - car.motor_efficiency);
        else
            slog5.motor_heat_power(i) = 0;
        end

        slog5.engine_heat_power(i,4) = slog5.engine_heat_power(i,1);

    elseif v(i,1) == slog5.v2(i,1)

        slog5.fuel_consumed(i,4) = slog5.fuel_consumed(i,2);
        slog5.power_consumed(i,4) = slog5.power_consumed(i,2);
        slog5.vel_select(i) = 2;
        if slog5.power_consumed(i,4) < 0
            slog5.power_consumed(i,4) = 0; %Accounting for negative power consumption in the model, although not considering regenerative braking at this time.
        end
        slog5.rpm(i,4) = slog5.rpm(i,2);
        if slog5.rpm(i,4) < car.motor_cutoff
            slog5.motor_heat_power(i) = slog5.power_consumed(i,2) * (1 - car.motor_efficiency);
        else
            slog5.motor_heat_power(i) = 0;
        end
        slog5.engine_heat_power(i,4) = slog5.engine_heat_power(i,2);
        slog5.rpm_elec(i,4) = slog5.rpm_elec(i,2);

    elseif v(i,1) == slog5.v3(i,1)

        slog5.fuel_consumed(i,4) = slog5.fuel_consumed(i,3);
        slog5.power_consumed(i,4) = 0;%slog5.power_consumed(i,3);
        slog5.rpm(i,4) = slog5.rpm(i,3);
        slog5.vel_select(i) = 3;
        if slog5.rpm(i,4) < car.motor_cutoff
            slog5.motor_heat_power(i) = slog5.power_consumed(i,3) * (1 - car.motor_efficiency);
        else
            slog5.motor_heat_power(i) = 0;
        end

        slog5.engine_heat_power(i,4) = slog5.engine_heat_power(i,3);
        slog5.rpm_elec(i,4) = slog5.rpm_elec(i,3);
    end


end



%Calculating the braking heat energy generated, by taking the velocity
%difference between two points and hence computing the loss of kinetic
%energy as heat. Also calculating the braking forces.

for i = 1:n-1
    if v(i+1) < v(i)
        brake_heat_energy(i) = 0.5 .* car.mass .* (v(i+1)-v(i)).^2;
        [~,F_D(i)] = Aero_Forces(v(i),car.CLA,car.CDA);
        [~,F_D(i+1)] = Aero_Forces(v(i+1),car.CLA,car.CDA);
        F_Ddiff(i) = F_D(i+1) - F_D(i);
        F_D_energy_change(i) = F_Ddiff(i) * (dist(i+1) - dist(i)); 
        brake_heat_energy(i) = brake_heat_energy(i) - F_D_energy_change(i);
        slog5.brake_heat_energy_change(i,1,1) = brake_heat_energy(i)*0.5*car.brakeSystem.brake_bias;
        slog5.brake_heat_energy_change(i,1,2) = slog5.brake_heat_energy_change(i,1,1);
        slog5.brake_heat_energy_change(i,2,1) = brake_heat_energy(i)*0.5*(1-car.brakeSystem.brake_bias);
        slog5.brake_heat_energy_change(i,2,2) = slog5.brake_heat_energy_change(i,2,1);


    else
        slog5.brake_heat_energy_change(i) = 0;
    end
end

if any(slog5.RPM_limit_hit == 1) %Idea for single warning from AA.
     warning('Engine RPM limit hit with lowest gear ratio.');
end

end