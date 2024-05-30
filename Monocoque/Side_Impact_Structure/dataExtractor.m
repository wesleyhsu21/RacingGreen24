clear
clc
close all

% Define the path to your Excel file
file_path = '50mmdata.xlsx';

% Specify the range of data to import
range = 'A1:B16';

% Read the data from the specified range
data = readmatrix(file_path, 'Range', range);

% Separate the data into x and y variables
Force = abs(data(:, 1));
Displacement = abs(data(:, 2));

dataExp = [Force Displacement]

ThreePointBend.TestData = dataExp;

save("ThreePointBendFEA.mat","ThreePointBend")