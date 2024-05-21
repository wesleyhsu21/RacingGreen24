clear
clc

%% Baseline corners

% Defining track constraints
d_min = 9; % minimum corner diameter is 9m from the rules
r_min = d_min / 2;
w_min = 3; % min corner width is 3m from rules
car_width = 1.5; % max width of the car

% Function to create a circle
function [x, y] = circle(xc, yc, r, theta_start, theta_end)
    theta = linspace(theta_start, theta_end, 100);
    x = xc + r * cos(theta);
    y = yc + r * sin(theta);
end

% Outside track x and y points
out_tr_rad = d_min / 2;
[x_out, y_out] = circle(0, 0, out_tr_rad, 0, pi);

% Inside of track x and y points
in_tr_rad = ((d_min - (2 * w_min)) / 2);
[x_in, y_in] = circle(0, 0, in_tr_rad, 0, pi);

% Outside car x and y points
out_cr_rad = d_min / 2 - (car_width / 2);
[x_out_car, y_out_car] = circle(0, 0, out_cr_rad, 0, pi);

% Inside of car x and y points
in_cr_rad = ((d_min - (2 * w_min)) / 2) + (car_width / 2);
[x_in_car, y_in_car] = circle(0, 0, in_cr_rad, 0, pi);

%% Classical racing line

% Determining classical racing line
pt_rl_cl1 = [-(r_min - car_width / 2), 0];
pt_rl_cl2 = [0, (r_min + car_width / 2 - w_min)];
pt_rl_cl3 = [(r_min - car_width / 2), 0];

% Classical racing line x and y points
[x_rl_cl, y_rl_cl] = ellipse(pt_rl_cl1, pt_rl_cl2, pt_rl_cl3);

%% Late apex racing line

% Late apex point 1 is at end of straight/beginning of outer circle radius
x_rl_la1 = x_out_car(end);
y_rl_la1 = y_out_car(end);

% Late apex point 2 is a percentage of outer circle 
la2_ratio = 0.65; % Define this as a percentage of outer car circle point from right
x_rl_la2 = x_out_car(round(la2_ratio * length(x_out_car)));
y_rl_la2 = y_out_car(round(la2_ratio * length(x_out_car)));

% Late apex point 3 is a percentage of classical racing line
la3_ratio = 0.40; % Define this as a percentage of classical racing line
x_rl_la3 = x_rl_cl(round(la3_ratio * length(x_rl_cl)));
y_rl_la3 = y_rl_cl(round(la3_ratio * length(y_rl_cl)));

% Late apex point 4 is a percentage of final straight length
la4_ratio = 0.5; % Define this as a percentage of final straight length on outside
x_rl_la4 = r_min - car_width / 2;
y_rl_la4 = la4_ratio * -2;

% Combining points for late apex
x_rl_la = [x_rl_la1, x_rl_la2, x_rl_la3, x_rl_la4];
y_rl_la = [y_rl_la1, y_rl_la2, y_rl_la3, y_rl_la4];

% Late apex polyfit
x_rl_la_range = linspace(min(x_rl_la), max(x_rl_la), 50); % creating range for polyfit
p_rl_la = polyfit(x_rl_la, y_rl_la, 3);
v_rl_la = polyval(p_rl_la, x_rl_la_range);

%% Plots
% Plotting all points 
figure
hold on 
% Outside of track
plot(x_out, y_out, 'k-', 'LineWidth', 1.5)
% Inside of track
plot(x_in, y_in, 'k-', 'LineWidth', 1.5)
% Outside of car
plot(x_out_car, y_out_car, 'b-', 'LineWidth', 1.5)
% Inside of car
plot(x_in_car, y_in_car, 'b-', 'LineWidth', 1.5)

% Plotting vertical track parts 
plot([-out_tr_rad, -out_tr_rad], [-2, 0], 'k-', 'LineWidth', 1.5)
plot([-in_tr_rad, -in_tr_rad], [-2, 0], 'k-', 'LineWidth', 1.5)
plot([in_tr_rad, in_tr_rad], [-2, 0], 'k-', 'LineWidth', 1.5)
plot([out_tr_rad, out_tr_rad], [-2, 0], 'k-', 'LineWidth', 1.5)

% Plotting vertical car parts
plot([-out_cr_rad, -out_cr_rad], [-2, 0], 'b-', 'LineWidth', 1.5)
plot([-in_cr_rad, -in_cr_rad], [-2, 0], 'b-', 'LineWidth', 1.5)
plot([in_cr_rad, in_cr_rad], [-2, 0], 'b-', 'LineWidth', 1.5)
plot([out_cr_rad, out_cr_rad], [-2, 0], 'b-', 'LineWidth', 1.5)

% Plotting classical racing line
plot(x_rl_cl, y_rl_cl, 'r-', 'LineWidth', 1.5)

% Plotting late apex racing line
plot(x_rl_la_range, v_rl_la, 'g-', 'LineWidth', 1.5)

% Plotting late apex racing line points
plot(x_rl_la1, y_rl_la1, 'ko')
plot(x_rl_la2, y_rl_la2, 'ko')
plot(x_rl_la3, y_rl_la3, 'ko')
plot(x_rl_la4, y_rl_la4, 'ko')
hold off
grid on 
ylim([-2, 5])
xlim([-5, 5])

%% Setting up equations to find radius of curvature for classical racing line
syms x_cl_curve y_cl_curve

% Extract coordinates from input points
x1 = pt_rl_cl1(1);
y1 = pt_rl_cl1(2);
x2 = pt_rl_cl2(1);
y2 = pt_rl_cl2(2);
x3 = pt_rl_cl3(1);
y3 = pt_rl_cl3(2);

% Calculates semi-major axis
a = (x3 - x1) / 2;

% Calculates semi-minor axis
b = y2;

% Equation of ellipse
y_cl_curve = ((b^2) * (1 - (x_cl_curve^2) / (a^2)))^(1/2);

% Defining derivatives of ellipse equation 
d1y_cl_curve = diff(y_cl_curve);
d2y_cl_curve = diff(d1y_cl_curve);

% Iterating to find location of min curvature
for j = 1:length(x_rl_cl)
    if abs(abs(x_rl_cl(j)) - a) > 0.001 
        d1y_cl_curve_val = subs(d1y_cl_curve, x_cl_curve, x_rl_cl(j));
        d2y_cl_curve_val = subs(d2y_cl_curve, x_cl_curve, x_rl_cl(j));
        r_cl(j) = ((1 + (d1y_cl_curve_val)^
