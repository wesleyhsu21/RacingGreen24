clear 
clc




% ALPHA MAX CALCULATION BY USING MINIMUM RADIUS OF TURN

syms x l alpha_max
 
% Defining constants in equations
x = 1;
l = 1.5;
delta_max = 6;
min_radius = 3;
alpha_max = alpha_max_calc(delta_max,min_radius,x,l);




% FRONT WHEEL STEERING ONLY

syms beta_f z_f radius_f

% Setting up system of equations for front wheel steering only
eqn1_f = z_f == l/(tand(beta_f)) - x;
eqn2_f = z_f == l/(tand(alpha_max));

% Solving values from equation
S_f = solve(eqn1_f, eqn2_f);

% Obtain the unknown variables
z_f = S_f.z_f;
beta_f = S_f.beta_f;
radius_f = sqrt(((z_f)+(x/2))^2+((l/2)^2));

% Convert to doubles
z_f = double(z_f);
beta_f = double(beta_f);
radius_f = double(radius_f);
y_f = 0;




% INCLUDING REAR WHEELS FOR STEERING

syms X Y gamma beta radius

% Defining constants in equations
delta = delta_max;

% Setting up system of equations
eqn1 = Y == tand(alpha_max) * X + l;
eqn2 = Y == - tand(delta) * X;

% Solving values from equation
solC = solve(eqn1,eqn2);

% Obtain the unknown variables
z = - 1 * solC.X;
y = solC.Y;
beta = atand((l - y)/(z + x));
gamma = atand(y / (z + x));
radius = sqrt((z + x/2) ^ 2 + (l/2 - y) ^ 2);

% Convert to doubles
z = double(z);
y = double(y);
beta = double(beta);
gamma = double(gamma);
radius = double(radius);




% PLOTTING

figure
xlims = [-3,2];
ylims = [-0.5,2];
xlim(xlims)
ylim(ylims)
hold on
grid on

% Car geometry
plot(0,0,'k|',LineWidth=4)
plot(x,0,'k|',LineWidth=4)
plot(x,l,'k|',LineWidth=4)
plot(0,l,'k|',LineWidth=4)
plot(x/2,l/2,'kx',LineWidth=3)

% Centre of rotation front only
plot(-(z_f),0,"x",Color="red", LineWidth=3)
% Steering angles representation front only
plot([-(z_f),x],[0,l],Color="red")
plot([-(z_f),0],[0,l],Color="red")
plot([-(z_f),x],[0,0],Color="red")
% Turning radius representation front only
plot([-(z_f),x/2],[0,l/2],Color="red")

% Centre of rotation AWS
plot(-z,y,'bx',LineWidth=3)
% Steering angles representation AWS
plot([-z,x],[y,l],'b')
plot([-z,0],[y,l],'b')
plot([-z,0],[y,0],'b')
plot([-z,x],[y,0],'b')
% Turning radius representation AWS
plot([-z,x/2],[y,l/2],'b')

% Centre line steering representation
plot(xlims,[y,y],'g--')




% ANGLE CALCULATION THROUGH CENTRE PLACEMENT

theta = - 150; % Steering wheel angle (values between -180 (full left) and 180)
centre_placement(theta,xlims,alpha_max,l,y,x)
hold off






