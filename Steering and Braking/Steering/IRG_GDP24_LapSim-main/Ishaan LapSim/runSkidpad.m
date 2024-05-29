function [SkidpadScore,position,eventTime, sim] = runSkidpad(car,n,sim, trackSelect)
    %Function to simulate the skidpad event, modelled as a track with a 20
    %m straight to the circles (modelled as a racing line of diameter 18.25 m), two consecutive laps of the right circle
    %followed by two consecutive laps of the left circle, followed by a
    %subsequent 20 m straight, as defined in the IMechE 2023 FS UK
    %Regulations.
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
    %         SkidpadScore: The calculated number of points achieved for the
    %         skidpad event.
    %         position: The position of the result of the skidpad
    %         event relative to the cars that raced at the 2022 IMechE FS
    %         UK competition.
    %         eventTime: The time of completion of the skidpad event.



%Loading in the track, and using a function created by the FS simulations
%team to create the segments with a chosen number of points.

load('SkidpadTrackv3.mat','x','y');

[sim.x, sim.y, sim.dist, sim.curve, sim.radius,sim.delta_heading,sim.delta_heading_corner_max] = resampleTrack(x,y,n);

%Using a currently unmodified FS simulations team function to find the
%velocity at each segment.

[sim.v,sim.slog] = velocity_finder(sim.dist,sim.radius,car);

%Computing the distance covered in each segment over time.

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

%Note: for timing or this, need to use the distance metric to find
%the start time and end time for the right circle, then for the
%left, to produce the necessary average and hence the score. This is
%included in the right and left circle times via calculation of the
%required distance to be covered to then 'cross' the start-finish line. To
%prevent issues with the times not registering correctly due to the
%sampling, a 1E-5 tolerance has been included.

rightCircleTime = sim.time(find(sim.dist >= 134.6681 - 1E-5,1)) - sim.time(find(sim.dist >= 77.3341 - 1E-5,1));
leftCircleTime = sim.time(find(sim.dist >= 249.3363 - 1E-5,1)) - sim.time(find(sim.dist >= 192.0022 - 1E-5,1));

if trackSelect ~= 'F' %Text output of times if not in full event run.

fprintf('Right circle run time: %f s\n', rightCircleTime);
fprintf('Left circle run time: %f s \n',leftCircleTime);

end

%Calculating the event time from the average of the two circle runs, as per
%the IMechE FS UK 2023 regulations.

eventTime = mean([leftCircleTime,rightCircleTime]);

if trackSelect ~= 'F' %Text output if not in full event run.

fprintf('Average time of runs: %f s \n', eventTime);

end

%% Points calculation.

Tmin = 5.350; %These are found from the FS UK 2022 results.
Tmax = 6.687;

if eventTime < Tmin %If the time to completion is faster than that of the times set in 2022, changes the Tmin and Tmax to match.

    Tmin = eventTime;
    Tmax = 1.25*Tmin;

end

if eventTime < Tmax %Calculating the skidpad score as per the FS UK 2023 regulations.

    SkidpadScore = 70*((Tmax/eventTime)^2 - 1)/((Tmax/Tmin)^2 - 1) + 5;

else %If the time is beyond Tmax, then only allocates the 5 points for completion.

    SkidpadScore = 5;

end

%Evaluates position using the points scoring from the previous year.

pointsList = [75,63.37,58.57,39.49,38.79,38.21,28.49,SkidpadScore];

pointsList = sort(pointsList,'descend');

position = find(pointsList == SkidpadScore,1);

if trackSelect ~= 'F' %Text output if not in full event run.

fprintf('Skidpad event score: %f points \n', SkidpadScore);

fprintf('Position from Skidpad event: %i/%i \n', position,length(pointsList));

end

end