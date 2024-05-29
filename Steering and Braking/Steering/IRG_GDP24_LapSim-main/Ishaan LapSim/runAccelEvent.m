function [AccelScore,position,eventTime, sim] = runAccelEvent(car,n,sim,trackSelect)
    %Function to simulate the acceleration event, modelled as a track of 75
    %m length, straight, with a 0.3 m staging area, as per the IMechE 2023 FS UK regulations.
    %Inputs: car: (user-defined class by the FS simulations team), contains
    %        all relevant car data for simulation.
    %        n: The number of discretisations of points, defined in the
    %        Sim.m script.
    %        sim: (user-defined class by FS simulations team), contains
    %        relevant data containers for simulation outputs.
    %        trackSelect: Character that provides the choice of
    %        acceleration event. Necessary for decision regarding text
    %        outputs.
    %Outputs: Updated sim object
    %         AccelScore: The calculated number of points achieved for the
    %         acceleration event.
    %         position: The position of the result of the Acceleration
    %         event relative to the cars that raced at the 2022 IMechE FS
    %         UK competition.
    %         eventTime: The time of completion of the acceleration event.


%Loading in the created acceleration track.

load("AccelTrackv3.mat",'x','y');

%Creating the segments of the track, determined by the user-defined number
%of discretisations. Function created by the FS simulations team.
[sim.x, sim.y, sim.dist, sim.curve, sim.radius,sim.delta_heading,sim.delta_heading_corner_max] = resampleTrack(x,y,n);

%Computing the velocity at each segment. Function at the time of writing of
%this comment (0013 on 23/05/2023) created entirely by FS simulations team.
[sim.v,sim.slog] = velocity_finder(sim.dist,sim.radius,car);

%Computing the distance covered across each segment. Function created by
%the FS simulations team.
sim.time = distanceTime(sim.v, sim.dist);

%Calculating braking forces and checking if the brakes lock-up.

for i = 1:n-1
    if sim.v(i+1) < sim.v(i)
        [~,F_D(i)] = Aero_Forces(sim.v(i),car.CLA,car.CDA);
        braking_force(i) = car.mass.*(sim.v(i+1) - sim.v(i))/(sim.time(i+1) - sim.time(i));
        braking_force(i) = braking_force(i) - F_D(i);
        sim.slog.braking_force(i,1,1) = 0.5*braking_force(i)*car.brakeSystem.brake_bias;
        sim.slog.braking_force(i,1,2) = sim.slog.braking_force(i,1,1);
        sim.slog.braking_force(i,2,1) = 0.5*braking_force(i)*(1-car.brakeSystem.brake_bias);
        sim.slog.braking_force(i,2,2) = sim.slog.braking_force(i,2,1);
        if abs(sim.slog.braking_force(i,1,1)) > car.LF_front
            warning('Braking force for front lock-up exceeded.');
        end
        if abs(sim.slog.braking_force(i,2,2)) > car.LF_rear
            warning('Braking force for rear lock-up exceeded.');
        end

    else
        sim.slog.braking_force(i) = 0;
    end
end

%Computation of the overall event time, taking into account the runoff.
%-1E-5 included due to rounding differences causing errors.
eventTime = sim.time(find(sim.dist >= 75.3 - 1E-5,1)) - sim.time(find(sim.dist >= 0.3 - 1E-5,1));
if trackSelect ~= 'F' %If not considering the full event, provides text outputs of the time of completion.
    fprintf('Time to complete the acceleration event: %f s \n', eventTime);
end
%% Points calculation, based on 2022 best scores.

Tmin = 4.175; %From IMechE 2022 FS results.
Tmax = 6.263; %150% of the minimum time, as determined by the FSUK 2023 regulations.
Tbest = [4.175,4.208,4.237,4.490,4.473,4.453,4.717]; %Based on 2022 FS UK results, assuming the best times (as the runoff times are not available in the documentation - although can be from the livestream, planned as a future inclusion).

if eventTime < Tmin %If the acceleration time found is the fastest, then sets these as the new Tmin and Tmax. This would also guarantee the maximum points. However, this method is kept for consistency with the regulations.

    Tmin = eventTime;
    Tmax = 1.5*Tmin;

end

if eventTime < Tmax %If the time to completion is less than the maximum, score is computed using the formula given in the regulations.

    AccelScore = 65*((Tmax/eventTime) - 1)/((Tmax/Tmin) - 1) + 5;

    %Checking whether the score would qualify in the top 6, and hence get
    %taken to the run-off. Subsequent conditional then adds an extra 0-5
    %points depending on positioning of the time relative to the top six.

    T = sort([Tbest,eventTime]); 
    if find(T == eventTime,1) <= 6

        AccelScore = AccelScore + (6 - find(T == eventTime,1));

    end

else %If the time is too long relative to the previous Tmax, then the score is capped at 5 for completion.

    AccelScore = 5;

end


pointsList = [75.0,72.47,70.15,58.32,58.01,57.83,47.59,AccelScore]; %Array of the points scored by other 2022 teams and the score computed above.

pointsList = sort(pointsList,'descend');

position = find(pointsList == AccelScore,1); %Finding the position of the car in the event relative to the other competitors.

if trackSelect ~= 'F' %If not running the full event, then output text of the score and position.
    fprintf('Acceleration event score: %f points \n', AccelScore);

    fprintf('Position from Acceleration event: %i/%i \n', position,length(pointsList));
end

end