function [v,slog5] = velocity_finder(dist,radius,car,x,y)
    
load("tyrePoly.mat","model");

n = length(dist); 

itt_lim = 10; 
    
err_margin = 0.01;

sim_vel = simulation(n);

radius(isinf(radius)) = 1000000;

slog5 = slog(n);

ax = 0;

for i = 1:n
    try
    sim_vel.slog.v1(i,1) = v1Calc(car,model,radius(i),itt_lim,err_margin);
    catch e
        error(e.message);
    end
    

end

CDA = 2.20;

sim_vel.slog.v1(((sim_vel.slog.v1(:,1) > ((2*car.motor_power)/(1.184*CDA))^(1/3)) | (sim_vel.slog.v1(:,1) == 0)), 1) = ((2*car.motor_power)/(1.184*CDA))^(1/3);
% sim_vel.slog.v1((sim_vel.slog.v1(:,1) > ((2*car.motor_power)/(1.184*CDA))^(1/3)) , 1) = ((2*car.motor_power)/(1.184*CDA))^(1/3);
% sim_vel.slog.v1(  (sim_vel.slog.v1(:,1) == 0), 1) = inf;

for i = 1:n-1

    sim_vel.slog.v2(i) = min(sim_vel.slog.v1(i),sim_vel.slog.v2(i));

    [ax, slog1] = v2Calc(car, model, sim_vel.slog.v2(i), radius(i), itt_lim, err_margin, i,x,y,ax);

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
    slog5.stra(i,1) = slog1.stra;
    slog5.chang(i,1) = slog1.chang;


    slog1.ax_log(i)  = ax;
    
    sim_vel.slog.v2(i+1) = (sim_vel.slog.v2(i)^2 + (2*ax*(dist(i+1) - dist(i))))^0.5;  % The sign on this needs changed should be + for the acceleration loop
end

for i = n:-1:2

    sim_vel.slog.v3(i) = min(sim_vel.slog.v2(i),sim_vel.slog.v3(i));
    try
    [ax, slog2] = v3Calc2(car, model, sim_vel.slog.v3(i), radius(i), itt_lim, err_margin,x,y,i);
    catch e
        error(e.message);
    end
    sim_vel.slog.v3(i-1) = (sim_vel.slog.v3(i)^2 - (2*ax*(dist(i) - dist(i-1))))^0.5;

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
        slog5.stra(i,1) = slog2.stra;
        slog5.chang(i,1) = slog2.chang;


    end
end

slog5.v1 = sim_vel.slog.v1;

slog5.v2 = sim_vel.slog.v2;

slog5.v3 = sim_vel.slog.v3;

v = zeros(n,1);

for i=1:n
       
  v(i,1) = min([slog5.v1(i,1),slog5.v2(i,1),slog5.v3(i,1)]);
  %slog5.stra(i,1) = car.wheelbase/radius(i) + (slog5.sa(i,1,1)+slog5.sa(i,1,2))/2 - (slog5.sa(i,2,1) + slog5.sa(i,2,2))/2 ;

end

for i=n:-1:1
       
  v(i,1) = slog5.v2(i,1);

  if slog5.v3(i,1) > slog5.v2(i,1)

      break

  end

end