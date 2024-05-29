P = sim.slog.Motor_Fx(:,2,1) .* sim.v * 2;

Energy = 0;

for i = 2:1:5000

    Energy =+ Energy + P(i) * (sim.time(i)-sim.time(i-1));
   
end

Energy_kWh = Energy/(3600*1000);

distance_lap_km = 2009.56/1000;

power_consumptio_per_kWh = distance_lap_km/Energy_kWh;