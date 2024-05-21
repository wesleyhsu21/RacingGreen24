clear 
clc

% PIVOTAL ACKERMAN POSITIONING FOR FRONT STEERING

syms d phi k eta alpha beta alpha_max
% alpha = 30;
alpha_max = 30;
l = 1.5;
x = 1;
y = 0.213054565678029;
z = (l - y) / tand(alpha);
% beta = atand((l - y) / (z + x));
beta = asind(z * sind(alpha) / (x + z));
eqnA = x == d * (cosd(phi - alpha) + cosd(beta + phi)) + k * cosd(eta);
eqnB = 0 == d * (sind(phi - alpha) + sind(beta + phi)) + k * sind(eta);
% phi = acosd((- d ^ 2 + x ^ 2 + (d + k) ^ 2) / (2 * x * (d + k))) + alpha_max;
sols = solve(eqnA,eqnB);




