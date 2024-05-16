clear
clc

% Defining track constraints
d_min = 9; % minimum corner diameter is 9m from the rules
w_min = 3; % min corner width is 3m from rules
car_width = 1; % max width of the car

% Outside track x and y points
out_tr_rad = d_min/2;
[x_out, y_out] = circle(0,0,out_tr_rad,0,pi);

% Inside of track x and y points
in_tr_rad = ((d_min-(2*w_min))/2);
[x_in, y_in] = circle(0,0,in_tr_rad,0,pi);

% Outside car x and y points
out_cr_rad = d_min/2 - (car_width/2);
[x_out_car, y_out_car] = circle(0,0,out_cr_rad,0,pi);

% Inside of car x and y points
in_cr_rad = ((d_min-(2*w_min))/2) + (car_width/2);
[x_in_car, y_in_car] = circle(0,0,in_cr_rad,0,pi);

% Determining classical racing line
x_rl_cl = [-4,0,4];
y_rl_cl = [0,2,0];


% Plotting all points 
figure
hold on 
% Outside of track
plot(x_out,y_out,color="black",LineWidth=1.5)
% Inside of track
plot(x_in,y_in,color="black",LineWidth=1.5)
% Outside of car
plot(x_out_car,y_out_car,color="blue",LineWidth=1.5)
% Inside of car
plot(x_in_car,y_in_car,color="blue",LineWidth=1.5)
% plotting vertical track parts 
plot(x_out,y_out,color="black",LineWidth=1.5)

% Plotting vertical track parts
plot([-out_tr_rad,-out_tr_rad],[-2,0],color="black",LineWidth=1.5)
plot([-in_tr_rad,-in_tr_rad],[-2,0],color="black",LineWidth=1.5)
plot([in_tr_rad,in_tr_rad],[-2,0],color="black",LineWidth=1.5)
plot([out_tr_rad,out_tr_rad],[-2,0],color="black",LineWidth=1.5)

% Plotting vertical car parts
plot([-out_cr_rad,-out_cr_rad],[-2,0],color="blue",LineWidth=1.5)
plot([-in_cr_rad,-in_cr_rad],[-2,0],color="blue",LineWidth=1.5)
plot([in_cr_rad,in_cr_rad],[-2,0],color="blue",LineWidth=1.5)
plot([out_cr_rad,out_cr_rad],[-2,0],color="blue",LineWidth=1.5)


% Plotting racing line

plot(x_rl_cl,y_rl_cl,color="red",LineWidth=1.5)




hold off
grid on 
ylim([-2,5])
xlim([-5,5])