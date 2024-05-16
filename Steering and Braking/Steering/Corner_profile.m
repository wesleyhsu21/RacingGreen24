clear
clc

%% Baseline corners

% Defining track constraints
d_min = 9; % minimum corner diameter is 9m from the rules
r_min = d_min/2;
w_min = 3; % min corner width is 3m from rules
car_width = 1.5; % max width of the car

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


%% Classical racing line

% Determining classical racing line
pt_rl_cl1 = [-(r_min - car_width/2),0];
pt_rl_cl2 = [0,(r_min+car_width/2-w_min)];
pt_rl_cl3 = [(r_min - car_width/2),0];


% Clasical racing line x and y points
[x_rl_cl,y_rl_cl] = ellipse(pt_rl_cl1,pt_rl_cl2,pt_rl_cl3);

% x_rl_cl = [-(r_min - car_width/2),0,(r_min - car_width/2)];
% y_rl_cl = [0,(r_min+car_width/2-w_min),0];
% xx_rl_cl = -(r_min - car_width/2):0.1:(r_min - car_width/2);
% yy_rl_cl = spline(x_rl_cl,y_rl_cl,xx_rl_cl);

%% Late apex racing line

% Late apex point 1 is at end of straight/ beginign of outer circle radius
x_rl_la1 = x_out_car(length(x_out_car));
y_rl_la1 = y_out_car(length(x_out_car));

% Late apex point 2 is a percentage of outer circle 
la2_ratio = 0.65; % Define this as a percentage of outer car circle point from right
x_rl_la2 = x_out_car(round(la2_ratio*length(x_out_car)));
y_rl_la2 = y_out_car(round(la2_ratio*length(x_out_car)));

% Late apex point 3 is a percentage of classical racing line
la3_ratio = 0.40; % Define this as a percentage of clasical racing line
x_rl_la3 = x_rl_cl(round(la3_ratio*length(x_rl_cl)));
y_rl_la3 = y_rl_cl(round(la3_ratio*length(y_rl_cl)));

% Late apex point 4 is a percentage of final straight length
la4_ratio = 0.5; % Define this as a percentage of final straight length on outside
x_rl_la4 = r_min - car_width/2;
y_rl_la4 = la4_ratio*-2;

% Combining points for la
x_rl_la = [x_rl_la1,x_rl_la2,x_rl_la3,x_rl_la4];
y_rl_la = [y_rl_la1,y_rl_la2,y_rl_la3,y_rl_la4];

% Late apex polyfit
x_rl_la_range = linspace(min(x_rl_la), max(x_rl_la),50); % creating range for polyfit
p_rl_la = polyfit(x_rl_la,y_rl_la,3);
v_rl_la = polyval(p_rl_la, x_rl_la_range);

%%
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


% Plotting classical racing line
plot(x_rl_cl,y_rl_cl,color="red",LineWidth=1.5)

% Plotting late apex racing line
plot(x_rl_la_range,v_rl_la,color="green",LineWidth=1.5)

% Plotting la racing line points
plot(x_rl_la1,y_rl_la1,"o",color="black")
plot(x_rl_la2,y_rl_la2,"o",color="black")
plot(x_rl_la3,y_rl_la3,"o",color="black")
plot(x_rl_la4,y_rl_la4,"o",color="black")

%% Iterating to find minimum radius of curvature



hold off
grid on 
ylim([-2,5])
xlim([-5,5])