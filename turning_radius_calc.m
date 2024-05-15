clear 
clc


% FRONT WHEEL STEERING ONLY

syms x_f l_f alpha_f beta_f z_f radius_f
 
% Defining constants in equations
x_f = 1;
l_f = 1.5;
alpha_f = 30;
 
% Setting up system of equations for front wheel steering only
eqn1_f = z_f == l_f/(tand(beta_f)) - x_f;
eqn2_f = z_f == l_f/(tand(alpha_f));
 
% Solving values from equation
S_f = solve(eqn1_f, eqn2_f);
 
% Obtain the unknown variables
z_f = S_f.z_f;
beta_f = S_f.beta_f;
radius_f = sqrt(((z_f)+(x_f/2))^2+((l_f/2)^2));

% Convert to doubles
z_f = double(z_f);
beta_f = double(beta_f);
radius_f = double(radius_f);


 

% INCLUDING REAR WHEELS FOR STEERING


syms X Y gamma beta radius

% Defining constants in equations
alpha = 30;
delta = 6;
l = 1.5;
x = 1;

% Setting up system of equations
eqn1 = Y == tand(alpha) * X + l;
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






% Plotting
figure
xlim([-3,2])
ylim([-0.5,2])
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
plot([-(z_f),x_f],[0,l_f],Color="red")
plot([-(z_f),0],[0,l_f],Color="red")
plot([-(z_f),x_f],[0,0],Color="red")
% Turning radius representation front only
plot([-(z_f),x_f/2],[0,l_f/2],Color="red")

% Centre of rotation AWS
plot(-z,y,'bx',LineWidth=3)
% Steering angles representation AWS
plot([-z,x],[y,l],'b')
plot([-z,0],[y,l],'b')
plot([-z,0],[y,0],'b')
plot([-z,x],[y,0],'b')
% Turning radius representation AWS
plot([-z,x/2],[y,l/2],'b')

hold off