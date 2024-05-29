%Imperial Racing Green Laptime Sim

%Author: Charalampos Charalampous
%Email: aekaros13@gmail.com - cc2621@imperial.ac.uk

%Special thanks to Conor Leo, Jakub Horsky, Thomas Phillip, William Foster
%and to everyone who contributed to the FS lap time simulator
clc;
clear;
tic;

addpath('Coordinates/')
addpath('GUI data/')
addpath("Modules/")
addpath("Objects/")
addpath("Tires/")
addpath('PProcessing/')

fprintf('Simulations is initiated \n')
%npoints = input('Please give number of track subdivisions, ');
npoints = 100;

carparams = carFsAWD;

pp = 1; %Set to 1 for post-processing

event = 3; %1-Sprint 2-Acceleration 3-SkidPad

[sim] = runsim(carparams,npoints,pp,event);

fprintf('Simulation is done \n')

toc;
