% load KEarray_cutoff_5000.mat
% load Timearray_cutoff_5000.mat
% 
% time = Timearray_cutoff_5000;
% regen_eff = 0.9;
% bias = [0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1];
%

function [total_regen] = regen_power(mass,velocity,time,brake_bias_rear, regen_eff, battery_charging_limit)
% mass          = car mass
% velocity      = array of the velocities on track
% time          = array of time
% brake_bias... = proprtion of the braking done on the read
% regen_eff     = motor_efficiency * controller_eff * transmission_eff
% batter_char.. = charging limit of the battery in kW
laps= 27;
velocity = transpose(velocity);
rolling_frict = 0.02 * (328.1*9.81);
KE = (0.5 * mass) .* velocity.^ 2;

for i = 1:(length(KE)-1)
    Drag = (0.5 * 1.19* 0.99) * (velocity(i)^2);
    P = (KE(i+1) - KE(i)) / (time(i+1) - time(i));
    PWR(i) = P + ((Drag*velocity(i)) + (rolling_frict*velocity(i)));
end

for i = 1:length(PWR)
    if PWR(i) >= 0
        PWR(i) = 0;
    elseif PWR(i) <= -1 * battery_charging_limit 
       PWR(i) = -1 * battery_charging_limit;
    end
end

i = 1;
time(length(PWR)) = [];
for rear_bias = brake_bias_rear
    rearPower = (rear_bias*regen_eff) .* PWR;
    Total_charge_per_lap(i) = abs( trapz(rearPower,time) / (3.6E6));
    i = i+1;
end
total_regen = Total_charge_per_lap.*laps;

end

% rearPower = (rear_bias*regen_eff) .* PWR;
% Totalcharge = abs( trapz(rearPower,time) / (3.6E6)) ;

%plot(time,rearPower)