function [sprintScore,position,eventTime, sim] = runSprint(car,n,sim,trackSelect)
    %Function to simulate the sprint event, modelled as a track that
    %fulfils the requirement of the FSUK 2023 regulations, and is a
    %modified version of a 2014 track (see GDP 2019, Jayamurthy and Jones
    %as reference).
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
    %         sprintScore: The calculated number of points achieved for the
    %         sprint event.
    %         position: The position of the result of the sprint
    %         event relative to the cars that raced at the 2022 IMechE FS
    %         UK competition.
    %         eventTime: The time of completion of the sprint event.


%Loading in a already-provided track file, and sampling it with the number
%of data points given using a FS simulations team provided function.

load('LapPlusSlalom_03_07v3.mat','x','y');

[sim.x, sim.y, sim.dist, sim.curve, sim.radius,sim.delta_heading,sim.delta_heading_corner_max] = resampleTrack(x,y,n);

%Using a currently unmodified FS simulations team function to find the
%velocity at each segment.

[sim.v,sim.slog] = velocity_finder(sim.dist,sim.radius,car);

%Using a FS simulations team provided function to compute the distance
%covered at each time.

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

%Finding the time of the event, recognising this would be the end time of
%the simulation.

eventTime = sim.time(find(sim.dist >= 1.1502E+3 - 1E-5,1));

if trackSelect ~= 'F' %Text output if not full event run.

fprintf('Time to complete the sprint event: %f s\n', eventTime);
end
%% Points calculation.

Tmin = 60.016; %The Tmax and Tmin are found from the FS UK 2022 results.
Tmax = 87.023;

if eventTime < Tmin %If the simulated time is the fastest of the 2022 results, then matches Tmin and Tmax as required.

    Tmin = eventTime;
    Tmax = 1.45*Tmin;

end

if eventTime < Tmax %Allocates points according to the FSUK 2023 regulations.

    sprintScore = 95*((Tmax/eventTime) - 1)/((Tmax/Tmin) - 1) + 5;

else %Allocates only the five points for completion if the time is beyond Tmax.

    sprintScore = 5;

end

%Evaluating position based on previous points scored. 

pointsList = [100,95.28,92.5,91.22,84.86,79.0,66.05,65.96,56.67,5.0,sprintScore];

pointsList = sort(pointsList,'descend');

position = find(pointsList == sprintScore,1);

if trackSelect ~= 'F' %Text output if not full event run.
fprintf('Autocross/sprint points: %f points \n',sprintScore);

fprintf('Position from Sprint event: %i/%i \n', position,length(pointsList));

end

end