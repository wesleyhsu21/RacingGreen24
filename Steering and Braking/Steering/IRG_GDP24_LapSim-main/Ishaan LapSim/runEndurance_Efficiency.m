function [enduranceScore,efficiencyCalc,position,efficiencyPosition,overallEnduranceTime,CO2emissionOverall, sim] = runEndurance_Efficiency(car,n,sim,trackSelect)
%Function to simulate the endurance (and hence efficiency) event,
%modelled using a track found from images in 2014 and modified (see GDP 2019 for
%reference, Jones and Jayamurthy), included in the FS simulator.
%Updated reference images are not believed to be available at this
%time.
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
%         enduranceScore: The calculated number of points achieved for the
%         endurance event.
%         efficiencyCalc: The calculated number of points for the
%         efficiency event.
%         position: The position of the result of the Endurance
%         event relative to the cars that raced at the 2022 IMechE FS
%         UK competition.
%         efficiencyPosition: The position of the result of the
%         Efficiency event relative to the cars that raced at the 2022
%         IMechE FS UK competition.
%         overallEnduranceTime: The time of completion of the endurance event.
%         CO2emissionOverall: The calculated CO2 output of the car during
%         the endurance event.

%Loading in the sprint event distance array in order to gain the lap distance (setup for a
%more generalised track case).

%load('LapPlusSlalom_03_07.mat','dist');

%Evaluating the overall lap distance (assuming the endurance and sprint
%tracks are identical).

lapDist = 1.1502E+3; %dist(end);

%Loading in a data file that contains two revolutions of the track. Note:
%This is an inherently inefficient method, similar in nature to that done
%by Williams, 2022. This is temporary, in order to ensure full
%functionality of the endurance event. A subsequent step soon will be to
%improve the efficiency of the overall program to not require this.

load("EnduranceTrack_Inefficientv2.mat",'x','y');

%Applying a given function by the FS simulations team as part of this lap
%simulator, generating the necessary discretisations of the track.

[sim.x, sim.y, sim.dist, sim.curve, sim.radius,sim.delta_heading,sim.delta_heading_corner_max] = resampleTrack(x,y,n);

%Applying the (as of this time) unmodified function by the FS simulations
%team to find the velocities at each segment.

[sim.v,sim.slog] = velocity_finder(sim.dist,sim.radius,car);

%Applying the function provided by the FS simulations team to find the
%distance covered in each segment.

sim.time = distanceTime(sim.v, sim.dist);
%car.energy_generated = regen_power(car.mass,sim.v(1:find(sim.dist>=2*1.120E+3,1)),sim.time(1:find(sim.dist>=2*1.120E+3,1)),1-car.brakeSystem.brake_bias,car.regen_efficiency,car.battery_charging_limit);
car.energy_generated = regen_power(car.mass,sim.v(1:find(sim.dist>=2*1.1502E+3,1)),sim.time(1:find(sim.dist>=2*1.1502E+3,1)),1-car.brakeSystem.brake_bias,car.regen_efficiency,car.battery_charging_limit);
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

%Calculating the time for the sprint lap. Note: To improve efficiency, a
%better method would be to take this from the previous sprint event if this
%has been run, such as in the full event run case.

timeSprint = sim.time(find(sim.dist>=lapDist - 1E-5, 1));


if trackSelect ~= 'F'
    fprintf('Number of laps required to cover the ~22 km of the endurance event: %i Laps \n', floor(22E+3/lapDist));
end

%Note: Need to incorporate a flying lap simulation in here, taking
%the velocity from the end of the previous lap and taking it as the
%starting boundary in the calculation for the new velocity.

%Subsequently, need to calculate the overall time for the lap by
%multiplying the number of laps (not including the first lap) with
%this new lap time, + the initial lap, to calculate the overall
%time.

%Note: This program efficiency improvement is a planned development path. Until updated, DO NOT USE this
%commented section.

%         [simTemp.x, simTemp.y, simTemp.dist, simTemp.curve, simTemp.radius] = resampleTrack(x,y,n);
%
%         [simTemp.v(2:end),simTemp.slog(2:end)] = velocity_finder_Endurance(sim.dist(2:end),sim.radius(2:end),car,sim);
%
%         simTemp.time = distanceTime(simTemp.slog.v3, simTemp.dist);

%         timeFlying = simTemp.time(end);




%Calculating the time of a single flying lap.

timeFlying = sim.time(find(sim.dist >= 2*lapDist - 1E-5, 1)) - timeSprint;

%Calculating the overall endurance event time by considering the number of
%flying laps that must occur, and adding this to the original sprint lap
%starting from a standstill.

lapNum = 27; %Fixed to 27 in line with FS UK competitions.


overallEnduranceTime = timeSprint + (lapNum - 1)*timeFlying;

if trackSelect ~= 'F' %Text output if this event is run individually.
    fprintf('Time to complete the Endurance event (without any degradation modelled): %f s \n', overallEnduranceTime);
end
%% Points calculation.

%Endurance event points.

Tmin = 1782.950; %The minimum and maximum times as given in the 2022 FS UK results.
Tmax = 2585.278;

if overallEnduranceTime < Tmin %Considering that, if this is the fastest endurance time, then the minimum and maximum times must be updated.

    Tmin = overallEnduranceTime;
    Tmax = 1.45*Tmin;

end

if overallEnduranceTime < Tmax %Implementing the points scoring mentioned in the regulations for a completed run of the endurance event in less than the maximum time.

    enduranceScore = 225*(((Tmax/overallEnduranceTime) - 1)/((Tmax/Tmin) - 1)) + 25;

else %If the time is beyond the maximum, then the endurance score is calculated as the number of completed laps, per the 2023 regulations.

    enduranceScore = floor((sim.time(end) - timeSprint)/lapDist) + 8; %Scaled to account for additional laps completed in FS UK.


end

%Evaluating the position of the simulation relative to the cars that raced
%at the FS UK 2022 competition. Note: this does include cars the did not
%finish. However, as they recorded scores, it was deemed beneficial to
%include them for reference, as the reason for DNF is unknown.

pointsList = [250,232.7,221.5,159.9,150.8,101.3,24,21,15,14,14,13,3,2,enduranceScore];

pointsList = sort(pointsList,'descend');

position = find(pointsList == enduranceScore,1);

if trackSelect ~= 'F' %Text output if not running the full event set.

    fprintf('Endurance points: %f points \n',enduranceScore);

    fprintf('Position from Endurance event: %i/%i (note: 6 cars completed) \n', position,length(pointsList));

end

%Efficiency (currently placeholder values, to be included following
%consumption calculations implemented).

%To calculate the efficiency, need to calculate the overall fuel consumed
%and the overall energy consumed. To do this, can apply a summation for the
%fuel (as it is just a singular value at each time, and must only be combined), but need to numerically integrate
%the power consumption to calculate energy consumption

%fuelConsumedOverall = sum(sim.slog.fuel_consumed(1:length(sim.x)/2,4)) + (floor(22E+3/lapDist) - 1)*sum(sim.slog.fuel_consumed(length(sim.x)/2 + 1:end,4));

%Applying the trapezium method to numerically integrate the power consumed
%into energy consumed, applying the gaps between the simulation times. 

%Update: This also has to be done for the fuel curve, taking care to
%convert from g to kg for the conversion factor to CO2 to hold.

energyConsumedSprint = 0;
energyConsumedFlying = 0;

fuelConsumedSprint = 0;
fuelConsumedFlying = 0;

for i = 1:find(sim.dist >= lapDist - 1E-5,1) - 1
    fuelConsumedSprint = fuelConsumedSprint + 0.5*((sim.time(i+1)-sim.time(i)))*(sim.slog.fuel_consumed(i,4) + sim.slog.fuel_consumed(i+1,4));
    energyConsumedSprint = energyConsumedSprint + 0.5*((sim.time(i+1)-sim.time(i))/3600)*(sim.slog.power_consumed(i,4) + sim.slog.power_consumed(i+1,4));
end


for i = find(sim.dist >= lapDist - 1E-5,1):find(sim.dist >= 2*lapDist - 1E-5,1)
    
    fuelConsumedFlying = fuelConsumedFlying + 0.5*((sim.time(i+1)-sim.time(i)))*(sim.slog.fuel_consumed(i,4) + sim.slog.fuel_consumed(i+1,4));
    energyConsumedFlying = energyConsumedFlying + 0.5*((sim.time(i+1)-sim.time(i))/3600)*(sim.slog.power_consumed(i,4) + sim.slog.power_consumed(i+1,4));

end

fuelConsumedOverall = (fuelConsumedSprint + (lapNum-1)*fuelConsumedFlying)/1000; %kg
fuelConsumedOverall = 1000/737.22 * fuelConsumedOverall; %Converted to litres, via value of density being 737.22 kg/m^3, according to https://www.thecalculatorsite.com/conversions/substances/petrol.php.
energyConsumedOverall = energyConsumedSprint + (lapNum-1)*energyConsumedFlying;

sim.slog.overallEnergy = energyConsumedOverall;
sim.slog.overallFuel = fuelConsumedOverall;

%Warning in case of consumption exceeding battery capacity.

if energyConsumedOverall >= car.battery_capacity
    warning('Power consumption exceeds the capacity of the battery.')
end

if trackSelect ~= 'F' %Text ooutput if not full car event.

    fprintf('Fuel consumed over the event: %f litres \n',fuelConsumedOverall);
    fprintf('Energy consumed over the event: %f kWh \n',energyConsumedOverall/1000);

end

%Conversion factors from 2023 FS UK regulations.

CO2emissionFuel = 2.31 * fuelConsumedOverall; %kg per litre
CO2emissionElectric = 0.45 * (energyConsumedOverall/1000 - car.energy_generated); %kg per KWh

CO2emissionOverall = CO2emissionElectric + CO2emissionFuel;

if trackSelect ~= 'F' %Text output if not full event set.
    fprintf('Fuel CO2 consumption: %f kg \n',CO2emissionFuel);
    fprintf('Electric CO2 consumption: %f kg \n',CO2emissionElectric);
    fprintf('Overall CO2 consumption: %f kg \n',CO2emissionOverall);

end

%Minimum and maximum from FS UK 2022 results.


%lapNum = floor(22E+3/lapDist);

CO2min = 0.575; %Adjusted value from FS UK 2022 results.
CO2max = 13.213; %From FS UK 2023 regulations.
CO2Tmin = 11.076;
Tmin = 65.961*27;
Tmax = 95.644*27;
TmaxE = 2585.278;
LapsTotalTmin = 27;
LapsTotalCO2min = 27;


%Calculating the total laps completed by the team, dependent on the time of
%endurance event completion.

if overallEnduranceTime < TmaxE
    LapsTotalteam = lapNum;
else
    LapsTotalteam = enduranceScore;
end

%Calculating the average lap time of the event.

Tteam = sum([timeSprint,timeFlying*ones(1,lapNum - 1)]);

%Note: Assuming event is completed within Tmax, calculating the efficiency
%factor using the equations defined in the FS UK 2023 regulations.

EfficiencyFactormin = 0.030; %((Tmin/27)/(Tmax/27))*((CO2min/27)/(CO2max/27); From FS UK 2022 results.
EfficiencyFactormax = 0.815; %((Tmin/LapsTotalTmin)/(T/27)) * ((CO2min/LapsTotalCO2min)/(CO2Tmin/27));

EfficiencyFactorteam = ((Tmin/LapsTotalTmin)/(Tteam/LapsTotalteam)) * ((CO2min/LapsTotalCO2min)/(CO2emissionOverall/LapsTotalteam));

%Calculating the efficiency score based on the FS UK 2023 regulations.

if CO2emissionOverall > CO2max || Tteam > Tmax
    if Tteam > Tmax
        warning('Average endurance time too long.');
    end
    if CO2emissionOverall > CO2max
        warning('CO2 emissions too high.');
    end
    efficiencyCalc = 0;

elseif CO2emissionOverall < CO2min

    efficiencyCalc = 100;
    CO2min = CO2emissionOverall;

else

    efficiencyCalc = 100 * ((EfficiencyFactormin/EfficiencyFactorteam) - 1)/((EfficiencyFactormin/EfficiencyFactormax) - 1);

end

pointsList = [100,97.1,87.3,52.9,52.7,50.9,49.8,47.4,43.8,23.9,efficiencyCalc]; %From FS UK 2022 results.

pointsList = sort(pointsList,'descend');

efficiencyPosition = find(pointsList == efficiencyCalc,1); %Auto-set to be the final position out of the cars that were tested.

if trackSelect ~= 'F' %Text output if not running the full event set.

    fprintf('Efficiency points: %f points \n',efficiencyCalc);

    fprintf('Position from Efficiency event: %i/%i (note: not including any teams that exceeded CO2max) \n', efficiencyPosition,length(pointsList));

end

end