clear
clc

data = readmatrix('aeroconcepts.xlsx','Range','I3:T38');
df = data(:,8);
drag = data(:,12);
weight = data(:,3);
cost = data(:,4);
xcg = data(:,6);
zcg = data(:,7);
xcp = data(:,10);
zcp = data(:,11);


% Define file names
existing_csv = 'base.csv';   % CSV file to be updated

% Read the existing values from the existing CSV file
base = readmatrix('aero.csv','Range','B1:B17');
%%

base_temp(1,1) = "wheel_rad";
base_temp(1,2) = "mass";
base_temp(1,3) = "cog_height";
base_temp(1,4) = "cog_split";
base_temp(1,5) = "cog_LR_split";
base_temp(1,6) = "cop_height";
base_temp(1,7) = "cop_split";
base_temp(1,8) = "cop_LR_split";
base_temp(1,9) = "wheelbase";
base_temp(1,10) = "trackF";
base_temp(1,11) = "trackR";
base_temp(1,12) = "CLA";
base_temp(1,13) = "CDA";
base_temp(1,14) = "motor_ratio";
base_temp(1,15) = "toe";
base_temp(1,16) = "tyre_pressure";
base_temp(1,17) = "IA";
base_temp = base_temp';

base_temp(:,2) = base;

for i = 1:36
    base_temp(12,2) = -df(i);
    base_temp(13,2) = drag(i);
    base_temp(2,2) = 241 + weight(i);
    base_temp(3,2) = zcg(i);
    base_temp(4,2) = xcg(i);
    base_temp(5,2) = 0.5; 
    base_temp(6,2) = zcp(i);
    base_temp(7,2) = xcp(i);
    base_temp(8,2) = 0.5; 
    new_csv = sprintf('config_%d.csv', i);
    writematrix(base_temp, new_csv);
    disp(['Updated data has been saved to ', new_csv]);
end


% Save the updated data to the new CSV file


