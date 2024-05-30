%Imperial Eco Marathon Laptime Sim

%Author: Charalampos Charalampous
%Email: aekaros13@gmail.com

%Special thanks to Conor Leo, Jakub Horsky, Thomas Phillip, William Foster
%and to everyone who contributed to the FS lap time simulator

%profile -historysize 1E+7
%profile on

clc;
clear;
tic;

%Included track selection process to give options for different events.
trackSelect = input("Please select track option (A = Acceleration, E = Endurance and Efficiency, Sp = Sprint, Sk = Skidpad, or F = Full event): ",'s');
sensiswitch = input("Please enter on or off for sensitivity analysis: ",'s');
%npoints = input('Please give number of track subdivisions, ');
npoints = 5000;


carparams = IRG2023Car;
carparamsAccel = IRG2023CarAccel;

%sensiswitch= 'on'; %The switch of sensitivity analysis; on/off

if strcmp(sensiswitch,'off') %Whether use the sensitivity analysis

    fprintf('Simulations is initiated \n')

    [simAcceleration,simEndurance_Efficiency,simSkidpad,simSprint] = runsim(carparams,carparamsAccel,npoints,trackSelect); %Modified runsim function, allows for calculation of each event as desired.

    fprintf('Simulation is done \n')

else


    fprintf('Simulations is initiated \n')

    fprintf('Sensitivity analysis is initiated \n')

    [simAccelerationArray,simEndurance_EfficiencyArray,simSkidpadArray,simSprintArray,sensiresult] = runsimsencop(carparams,carparamsAccel,npoints,trackSelect); %Modified runsim function, allows for calculation of each event as desired.

    fprintf('Simulation is done \n')

end

toc;

%profile viewer
