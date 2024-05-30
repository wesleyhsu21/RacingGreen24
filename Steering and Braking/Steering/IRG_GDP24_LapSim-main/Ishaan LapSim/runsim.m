function [simAcceleration, simEndurance_Efficiency, simSkidpad, simSprint] = runsim(car,carAccel,n,trackSelect)

simAcceleration = simulation(n);
simEndurance_Efficiency = simulation(n);
simSkidpad = simulation(n);
simSprint = simulation(n);




switch trackSelect
%Switch statement to select either a single event of focus, or to run
%through all of the events.

    case 'A' %Acceleration

        fprintf('Event selected: Acceleration \n');
        [~,~,~, simAcceleration] = runAccelEvent(carAccel,n,simAcceleration,trackSelect);

    case 'E' %Endurance and Efficiency (as the efficiency calculation is based on endurance)

        fprintf('Event selected: Endurance and Efficiency \n');
        [~,~,~,~,~,~, simEndurance_Efficiency] = runEndurance_Efficiency(car,n,simEndurance_Efficiency,trackSelect);

    case 'Sk' %Skidpad

        fprintf('Event selected: Skidpad \n');
        [~,~,~, simSkidpad] = runSkidpad(car,n,simSkidpad,trackSelect);

    case 'Sp' %Autocross/Sprint

        fprintf('Event selected: Autocross/Sprint \n');
        [~,~,~, simSprint] = runSprint(carAccel,n,simSprint,trackSelect);

    case 'F' %Running through all events

        parpool(4);

        fprintf('Full weekend selected \n');

        fprintf('Acceleration event initiated. \n');
        
        fAccel = parfeval(@runAccelEvent,4,carAccel,n,simAcceleration,trackSelect);
        %[AccelPoints, AccelPositions, AccelTime, simAcceleration] = runAccelEvent(car,n,simAcceleration,trackSelect); %Running acceleration.

        %fprintf('Acceleration event simulation complete. Endurance and Efficiency events initiated. \n');

        %Running the Endurance and Efficiency combined.

        fEndurance_Efficiency = parfeval(@runEndurance_Efficiency,7,car,n,simEndurance_Efficiency,trackSelect);

        %[EndurancePoints,EfficiencyPoints,EndurancePosition,EfficiencyPosition,EnduranceTime,CO2EmissionOverall, simEndurance_Efficiency] = runEndurance_Efficiency(car,n,simEndurance_Efficiency,trackSelect);
        %fprintf('Endurance and Efficiency events complete. Skidpad event initiated. \n')

        fSkidpad = parfeval(@runSkidpad,4,car,n,simSkidpad,trackSelect);

        %[SkidpadPoints,SkidpadPosition,SkidpadTime, simSkidpad] = runSkidpad(car,n,simSkidpad,trackSelect); %Running skidpad.

        fSprint = parfeval(@runSprint,4,carAccel,n,simSprint,trackSelect);

%         fprintf('Skidpad event complete. Sprint event initiated. \n');
% 
%         [SprintPoints,SprintPosition,SprintTime, simSprint] = runSprint(car,n,simSprint,trackSelect); %Running autocross/sprint.

        fprintf('All events simulated. Post-processing initiated. \n');

        %Outputing the results of the different events, and outputting each
        %position, combining them into a table with the overall values.

        [AccelPoints, AccelPositions, AccelTime, simAcceleration] = fetchOutputs(fAccel);
        [EndurancePoints,EfficiencyPoints,EndurancePosition,EfficiencyPosition,EnduranceTime,CO2EmissionOverall, simEndurance_Efficiency] = fetchOutputs(fEndurance_Efficiency);
        [SkidpadPoints,SkidpadPosition,SkidpadTime, simSkidpad] = fetchOutputs(fSkidpad);
        [SprintPoints,SprintPosition,SprintTime, simSprint] = fetchOutputs(fSprint);
        %Calculating the overall points for the dynamic events


        Points = [round(AccelPoints,2);round(EndurancePoints,2);round(EfficiencyPoints,2);round(SkidpadPoints,2);round(SprintPoints,2)];

        overallPoints = sum(Points);

        %Computing the overall position using the summation of the points
        %from the 2022 events with overall points found by taking summation of the teams that completed
        %all of the events. This data can be found in individual event form
        %in the different functions and from IMechE, 2022.

        overallTeamPoints = [249.75,252.97,324.16,492.99,456.65,461.72,401.08,201.3,119.28,112.1,98.3,59.67,2,89.86,overallPoints]; %All teams from 2022 included.
        overallTeamPoints = sort(overallTeamPoints,'descend');
        overallPosition = find(overallTeamPoints == overallPoints);
        totalPointsAvailable = 250+100+100+75+75; %Method of calculating the total available points, as a reference.

        %Producing a table of outputs to provide a convenient way of
        %viewing the outputs in time, points, and positions.

        Event = ["Acceleration";"Endurance (note: 6 cars fully completed)";"Efficiency (Calculation result is the overall CO2 emissions)";"Skidpad";"Sprint";"Overall"];
        Times_Calculation = {round(AccelTime,3);round(EnduranceTime,3);round(CO2EmissionOverall,3);round(SkidpadTime,3);round(SprintTime,3);'N/A'};
        Points = [Points;overallPoints];
        Positions = [AccelPositions;EndurancePosition;EfficiencyPosition;SkidpadPosition;SprintPosition;overallPosition];
        Number_of_Entries = [7+1;14+1;11;7+1;10+1;14+1];
        Events = table(Event,Times_Calculation,Points,Positions,Number_of_Entries)


        delete(gcp('nocreate'));


end

end