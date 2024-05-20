clear
clc

%% Baseline corners

% Defining track constraints
d_min = 9; % minimum corner diameter is 9m from the rules
r_min = d_min / 2;
w_min = 3; % min corner width is 3m from rules
car_width = 1.5; % max width of the car

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
% Defining ellipse centre
elps_rl_cl = [0,-1];

% Determining classical racing line
pt_rl_cl1 = [-(r_min - car_width / 2), elps_rl_cl];
pt_rl_cl2 = [0, (r_min + car_width / 2 - w_min)];
pt_rl_cl3 = [(r_min - car_width / 2), elps_rl_cl];

% Classical racing line x and y points
[x_rl_cl, y_rl_cl] = ellipse(pt_rl_cl1, pt_rl_cl2, pt_rl_cl3,elps_rl_cl);

%% Late apex racing line

% Late apex point 1 is at end of straight/ beginning of the classical
% racing line
x_rl_la1 = x_rl_cl(end);
y_rl_la1 = y_rl_cl(end);

% Late apex point 2 is a percentage of outer circle
la2_ratio = 0.6; % Define this as a percentage of outer car circle point from right
la2_ratio2 = 0.7; % Reducing y component of far point to reduce tightness of alternative racing line 
x_rl_la2 = x_out_car(round(la2_ratio * length(x_out_car)));
y_rl_la2 = la2_ratio2 * y_out_car(round(la2_ratio * length(x_out_car)));

% Late apex point 3 is a percentage of classical racing line
la3_ratio = 0.37; % Define this as a percentage of classical racing line
x_rl_la3 = x_rl_cl(round(la3_ratio * length(x_rl_cl)));
y_rl_la3 = y_rl_cl(round(la3_ratio * length(y_rl_cl)));

% Late apex point 4 is a percentage of outer circle
la4_ratio = 0.15; % Define this as a percentage of outer car circle point from right
la4_ratio2 = 0.88; % Reducing y component of far point to reduce tightness of alternative racing line 
x_rl_la4 = la4_ratio2 * x_rl_cl(round(la4_ratio * length(x_rl_cl)));
y_rl_la4 = y_rl_cl(round(la4_ratio * length(y_rl_cl)));

% Late apex point 5 is a percentage of final straight length
la5_ratio = 0.5; % Define this as a percentage of final straight length on outside
x_rl_la5 = r_min - car_width / 2;
y_rl_la5 = la5_ratio * -2;

% Combining points for la
x_rl_la = [x_rl_la1, x_rl_la2, x_rl_la3, x_rl_la4,x_rl_la5];
y_rl_la = [y_rl_la1, y_rl_la2, y_rl_la3, y_rl_la4, y_rl_la5];

% Late apex polyfit
x_rl_la_range = linspace(min(x_rl_la), max(x_rl_la), 100); % creating range for polyfit
p_rl_la = polyfit(x_rl_la, y_rl_la, 4);
v_rl_la = polyval(p_rl_la, x_rl_la_range);

%% Plots
% Plotting all points 
figure
hold on 
% Outside of track
plot(x_out, y_out, 'black', 'LineWidth', 1.5)
% Inside of track
plot(x_in, y_in, 'black', 'LineWidth', 1.5)
% Outside of car
plot(x_out_car, y_out_car, 'blue', 'LineWidth', 1.5)
% Inside of car
plot(x_in_car, y_in_car, 'blue', 'LineWidth', 1.5)

% Plotting vertical track parts
plot([-out_tr_rad, -out_tr_rad], [-2, 0], 'black', 'LineWidth', 1.5)
plot([-in_tr_rad, -in_tr_rad], [-2, 0], 'black', 'LineWidth', 1.5)
plot([in_tr_rad, in_tr_rad], [-2, 0], 'black', 'LineWidth', 1.5)
plot([out_tr_rad, out_tr_rad], [-2, 0], 'black', 'LineWidth', 1.5)

% Plotting vertical car parts
plot([-out_cr_rad, -out_cr_rad], [-2, 0], 'blue', 'LineWidth', 1.5)
plot([-in_cr_rad, -in_cr_rad], [-2, 0], 'blue', 'LineWidth', 1.5)
plot([in_cr_rad, in_cr_rad], [-2, 0], 'blue', 'LineWidth', 1.5)
plot([out_cr_rad, out_cr_rad], [-2, 0], 'blue', 'LineWidth', 1.5)

% Plotting classical racing line
plot(x_rl_cl, y_rl_cl, 'red', 'LineWidth', 1.5)

% Plotting late apex racing line
plot(x_rl_la_range, v_rl_la, 'green', 'LineWidth', 1.5)

% Plotting la racing line points
plot(x_rl_la1, y_rl_la1, 'o',color="black")
plot(x_rl_la2, y_rl_la2, 'o', color="black")
plot(x_rl_la3, y_rl_la3, 'o', color="black")
plot(x_rl_la4, y_rl_la4, 'o', color="black")
plot(x_rl_la5, y_rl_la5, 'o', color="black")
hold off
grid on 
ylim([-2, 5])
xlim([-5, 5])

%% Radius of Curvature for Classical Racing Line

syms x_cl_curve

% Extract coordinates from input points
x1 = pt_rl_cl1(1);
y1 = pt_rl_cl1(2);
x2 = pt_rl_cl2(1);
y2 = pt_rl_cl2(2);
x3 = pt_rl_cl3(1);
y3 = pt_rl_cl3(2);

% Calculate semi-major axis
a = (x3 - x1) / 2;

% Calculate semi-minor axis
b = y2 - elps_rl_cl(2);

% Equation of ellipse
y_cl_curve = elps_rl_cl(2) + (b * sqrt(1 - (((x_cl_curve - elps_rl_cl(1))^2) / a^2)));


% Defining derivatives of ellipse equation 
d1y_cl_curve = diff(y_cl_curve, x_cl_curve);
d2y_cl_curve = diff(d1y_cl_curve, x_cl_curve);

% Initialize array to store radius of curvature values
r_cl = zeros(1, length(x_rl_cl));

% Iterating to find the location of minimum curvature
for j = 1:length(x_rl_cl)
    x_val = x_rl_cl(j);
    if abs(abs(x_val) - a) > 0.0001
        % Calculate the first and second derivatives at the given x value
        d1y_cl_curve_val = double(subs(d1y_cl_curve, x_cl_curve, x_val));
        d2y_cl_curve_val = double(subs(d2y_cl_curve, x_cl_curve, x_val));
        % Calculate the radius of curvature
        r_cl(j) = ((1 + d1y_cl_curve_val^2)^(3/2)) / abs(d2y_cl_curve_val);
    else 
        % When the point being analyzed is at the ends of the ellipse (semi-major axis)
        r_cl(j) = a^2 / b;
    end
end

min_r_cl = min(r_cl)


%% Radius of Curvature for Late Apex Line

% Polynomial order of late apex racing line
n_poly = length(p_rl_la);

% Assigning coefficients from poly order to symbolic equation 
syms x_la_curve y_la_curve

% Initialize y_la_curve as equation 1
y_la_curve = 0;

% Constructing the polynomial equation
for i = 1:n_poly
    y_la_curve = y_la_curve + (p_rl_la(i) * x_la_curve^(n_poly - i));
end

% Defining derivatives of the curve equation 
d1y_la_curve = diff(y_la_curve, x_la_curve);
d2y_la_curve = diff(d1y_la_curve, x_la_curve);

% Iterating to find the radius of curvature
r_la = zeros(1, length(x_rl_la_range));  % Pre-allocate radius array
head_ang = zeros(1, length(x_rl_la_range));  % Pre-allocate heading angle array
head_angd = zeros(1, length(x_rl_la_range));  % Pre-allocate heading angle in degrees array

for j = 1:length(x_rl_la_range)
    d1y_la_curve_val = double(subs(d1y_la_curve, x_la_curve, x_rl_la_range(j)));
    d2y_la_curve_val = double(subs(d2y_la_curve, x_la_curve, x_rl_la_range(j)));
    r_la(j) = ((1 + d1y_la_curve_val^2)^(3/2)) / abs(d2y_la_curve_val);
    
    % Heading angle calculation
    head_ang(j) = atan(d1y_la_curve_val);
    head_angd(j) = rad2deg(head_ang(j));
end

min_r_la = min(r_la);  % Find the minimum radius of curvature
max_head_ang = max(head_angd);  % Find the maximum heading angle in degrees

% Display the results
min_r_la = double(min_r_la)
max_head_ang = double(max_head_ang)

%% Alternative Method for Radius of Curvature for Late Apex Line

% Number of points
n_la = length(x_rl_la_range);

% Pre-allocate the array for radius of curvature
r_la2 = zeros(1, n_la-2);

% Iterate over each triplet of points
for i = 1:n_la-2
    % Coordinates of the three consecutive points
    x1 = x_rl_la_range(i);
    y1 = v_rl_la(i);
    x2 = x_rl_la_range(i+1);
    y2 = v_rl_la(i+1);
    x3 = x_rl_la_range(i+2);
    y3 = v_rl_la(i+2);

    % Calculate the radius of curvature for these three points
    r_la2(i) = radiusOfCurvature(x1, y1, x2, y2, x3, y3);
end

% Find the minimum radius of curvature
r_la2_min = min(r_la2)

%% Alternative Method for Radius of Curvature for Classical Racing Line

% Number of points
n_cl = length(x_rl_cl);

% Pre-allocate the array for radius of curvature
r_cl2 = zeros(1, n_cl-2);

% Iterate over each triplet of points
for i = 1:n_cl-2
    % Coordinates of the three consecutive points
    x1 = x_rl_cl(i);
    y1 = y_rl_cl(i);
    x2 = x_rl_cl(i+1);
    y2 = y_rl_cl(i+1);
    x3 = x_rl_cl(i+2);
    y3 = y_rl_cl(i+2);

    % Calculate the radius of curvature for these three points
    r_cl2(i) = radiusOfCurvature(x1, y1, x2, y2, x3, y3);
end

r_cl2_min = min(r_cl2)