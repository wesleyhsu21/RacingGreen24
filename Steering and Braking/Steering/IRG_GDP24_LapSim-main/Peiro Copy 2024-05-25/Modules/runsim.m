function [sim] = runsim(car,n,pp,event) 

sim = simulation(n);

if event == 1

    load("LapPlusSlalom_03_07.mat",'x','y');

elseif event ==2

    load("AccEvent.mat",'x','y');

elseif event ==3

    load("SkidpadOptim.mat",'x','y');
    

end
%
% scatter(x,y)


[sim.x, sim.y, sim.dist, sim.curve, sim.radius] = resampleTrack(x,y,n);
try
[sim.v,sim.slog] = velocity_finder(sim.dist,sim.radius,car,sim.x,sim.y);
catch e
    sim.time = nan*ones(1,n);
    sim.error = e.message;
    return
end
sim.time = distanceTime(sim.slog.v3, sim.dist);


% POST PROCESSING BELOW
if pp == 1

    if isnan(sim.v(end))
        sim.v(end) = [];
    end
    if isnan(sim.slog.Motor_Fx(1,2,1))
        sim.slog.Motor_Fx(1,2,1) = 0;
    end
    if isnan(sim.slog.Motor_Fx(1,2,2))
        sim.slog.Motor_Fx(1,2,2) = 0;
    end
    P = sim.slog.Motor_Fx(:,2,1) .* sim.v + sim.slog.Motor_Fx(:,2,2) .* sim.v;
    t = sim.time;
    [sim.plog.OCV, sim.plog.I, sim.plog.SOC, sim.plog.E_gen, sim.plog.Q_max] = Batt_Model(P,t);
    [sim.plog.T] = Cooling_Model(sim.plog.E_gen,t,sim.v);
end

                              

end