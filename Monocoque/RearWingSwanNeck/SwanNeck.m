clear
clc
close all

%% Layup
layup_s = [0 0 90 0 -45 45 0 -45 45 0 90 0 -45 45];
[A_0, B_0, D_0, ABD_0, Q_0, thickness_0] = ABD(layup_s);

percent0 = sum(layup_s==0) / length(layup_s)
percent45 = sum(layup_s==45) * 2 / length(layup_s)
percent90 = sum(layup_s==90) / length(layup_s)

thickness_0

L = 400e-3;
b = 100e-3;

E_f_x = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(1,1) / b;
E_f_y = (1 - A_0(1,2)^2 / (A_0(2,2) * A_0(1,1))) * A_0(2,2) / b;

ymax = b / 2; % Most stressed part

%% Moment of area calculation
I = thickness_0 * b ^ 3 / 12;

%% Max stress
MaxMoment = 80; % Nm
MaxStress = MaxMoment * ymax / I


Critical22t = 7.56e7;
SafetyFactor = Critical22t / MaxStress

%% Mass Calculation
volume = b * L * thickness_0;
density = 1570;
mass = volume * density

%% Cost Calculation
areatotal = L * b * length(layup_s) * 2;
costperm2 = 35;
cost = areatotal * costperm2