function [simAccelerationArray, simEndurance_EfficiencyArray, simSkidpadArray, simSprintArray,sensiresult] = runsimsenclcd(car,carAccel,n,trackSelect)


%load("nogarosmallcords.mat",'nogaroxx','nogaroyy');


k=10; %Sensitivity dividing factors for the first variable.
l = 10; %Sensitivity dividing factors for the second variable.


%Starting sensitivity analysis

%Choosing the upper and lower bound for parameters (Change as necessary).

lbCLA = -2.6;
ubCLA = -1;
lbCDA=0.5;
ubCDA=1.4;

%Range and step of sensitivity testing for each parameter.
range_CLA = ubCLA - lbCLA; %Range of testing sensitivity on cl
step_CLA = range_CLA/k; %Tesing step of testing sensitivity on cl

range_CDA = ubCDA - lbCDA; %Range of testing sensitivity on cl
step_CDA = range_CDA/l; %Tesing step of testing sensitivity on cl
%Initialising arrays of values for each input and output parameter.

simAccelerationArray = cell(k,l);
simEndurance_EfficiencyArray = cell(k,l);
simSkidpadArray = cell(k,l);
simSprintArray = cell(k,l);
carArray = cell(k,l);
carArrayAccel = cell(k,l);
carArray{1,1} = car;
carArrayAccel{1,1} = carAccel;

AccelPoints = zeros(k,l);
AccelPositions = zeros(k,l);
AccelTime = zeros(k,l);
EndurancePoints = zeros(k,l);
EfficiencyPoints = zeros(k,l);
EndurancePosition = zeros(k,l);
EfficiencyPosition = zeros(k,l);
EnduranceTime = zeros(k,l);
CO2EmissionOverall = zeros(k,l);
SkidpadPoints = zeros(k,l);
SkidpadPosition = zeros(k,l);
SkidpadTime = zeros(k,l);
SprintPoints = zeros(k,l);
SprintPosition = zeros(k,l);
SprintTime = zeros(k,l);

Points = cell(k,l);
overallPoints = zeros(k,l);

%Filling in the arrays.

for i = 1:k+1
    for j = 1:l+1
    simAccelerationArray{i,j} = simulation(n);
    simEndurance_EfficiencyArray{i,j} = simulation(n);
    simSkidpadArray{i,j} = simulation(n);
    simSprintArray{i,j} = simulation(n);
    carArray{i,j} = car;
    carArrayAccel{i,j} = carAccel;
    end

end

%Running a for loop, going through the different parameters to identify the
%effects of the different parameters on points.

parfor i = 1 : k
    for j = 1:l
        fprintf('Iteration %i: \n',i*j);

        %Updating suspension parameters. Note: the specific property
        %updating came from the constructor method defined in the Car
        %objects, originally made by IFR Simulations team.

        carArray{i,j}.CLA = lbCLA + (i-1)*step_CLA;
        carArray{i,j}.CDA = lbCDA + (j-1)*step_CDA;

        carArrayAccel{i,j}.CLA = lbCLA + (i-1)*step_CLA;
        carArrayAccel{i,j}.CDA = lbCDA + (j-1)*step_CDA;



 switch trackSelect
 %Switch statement to select either a single event of focus, or to run
 %through all of the events.



    case 'F' %Running through all events

        %fprintf('Full weekend selected \n');

        %fprintf('Acceleration event initiated. \n');

        [AccelPoints(i,j), AccelPositions(i,j), AccelTime(i,j), simAccelerationArray{i,j}] = runAccelEvent(carArrayAccel{i,j},n,simAccelerationArray{i,j},'F'); %Running acceleration.

        %fprintf('Acceleration event simulation complete. Endurance and Efficiency events initiated. \n');

        %Running the Endurance and Efficiency combined.
        [EndurancePoints(i,j),EfficiencyPoints(i,j),EndurancePosition(i,j),EfficiencyPosition(i,j),EnduranceTime(i,j),CO2EmissionOverall(i,j), simEndurance_EfficiencyArray{i,j}] = runEndurance_Efficiency(carArray{i,j},n,simEndurance_EfficiencyArray{i,j},trackSelect);
        %fprintf('Endurance and Efficiency events complete. Skidpad event initiated. \n')

        [SkidpadPoints(i,j),SkidpadPosition(i,j),SkidpadTime(i,j), simSkidpadArray{i,j}] = runSkidpad(carArray{i,j},n,simSkidpadArray{i,j},trackSelect); %Running skidpad.

        %fprintf('Skidpad event complete. Sprint event initiated. \n');

        [SprintPoints(i,j),SprintPosition(i,j),SprintTime(i,j), simSprintArray{i,j}] = runSprint(carArray{i,j},n,simSprintArray{i,j},trackSelect); %Running autocross/sprint.

        %fprintf('All events simulated. Post-processing initiated. \n');

        %Outputing the results of the different events, and outputting each
        %position, combining them into a table with the overall values.

        %Calculating the overall points for the dynamic events

        Points{i,j} = [round(AccelPoints(i,j),2);round(EndurancePoints(i,j),2);round(EfficiencyPoints(i,j),2);round(SkidpadPoints(i,j),2);round(SprintPoints(i,j),2)];

        overallPoints(i,j) = sum(Points{i,j});
         x(i,j)=carArray{i,j}.CLA;
        y(j,i)=carArray{i,j}.CDA;







  end
    end
end
delete(gcp('nocreate'));

%Plotting contour plot if 2-parameter sensitivity.

if k > 1 && l > 1

% x = linspace(lbCDA,ubCDA,k);
% y = linspace(lbCLA,ubCLA,l);
[X,Y] = meshgrid(x(:,1),y(:,1)); %Idea to use meshgrid from MathWorks, 2023. 
z = overallPoints;

contourf(X',Y',z);

xlabel('Variable 1 (CLA)','interpreter','latex');
ylabel('Variable 2 (CDA)','Interpreter','latex');
c = colorbar;
c.Label.String = 'Overall Points'; %Colorbar string labelling from MathWorks, 2023.

end

%Plotting points if 1-parameter sensitivity.

if l == 1

x = linspace(lbCLA,ubCLA,k);
y = overallPoints;

plot(x',y,'.b');

xlabel('Variable 1 (ENTER)','interpreter','latex');
ylabel('Points','Interpreter','latex');

end

sensiresult = {X,Y,overallPoints};

% for i=1:k
% 
%     SensiCLAResult(1,i)=carArray{i}.CLA;
%     SensiCLAResult(2,i)=overallPoints(i);
% 
% end
% sensiresult = SensiCLAResult;
% end