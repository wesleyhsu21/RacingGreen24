function[A, B, D, ABD, Q, thickness] = ABD(layup_s)
% Function to calculate the ABD matrix of an IM7/8552 laminate from the
% symmetric layup. Adapted from Sujit
% Inputs:
% layup_s           =   Matrix containing the angled plies of a laminate
%                       e.g. [0 0 0 45 -45 90]
% Outputs:
% A                 =   The A matrix
% B                 =   The B matrix
% D                 =   The D matrix
% ABD               =   The full ABD matrix

thetadb = [layup_s flip(layup_s)];
Nplies = length(thetadb);

t = 0.131e-3;
thickness = t * Nplies;
h      = Nplies * t ;

zbar = zeros(1,Nplies);

for i = 1:Nplies
  zbar(i) = - (h + t)/2 + i*t;
end

% Ply engineering properties XC130
E1   = 55.2e9; % Pa
nu12 = 0.32 ;
E2   = 55.2e9; % Pa
G12  = 5.59e9  ; % Pa
nu21 = nu12 * E2 / E1 ;

a1 = -1e-7 ; % coefficients of thermal expansion
a2 = 3.1e-5 ;
deltaT = 1 ;
T_Cure = 177 + 173; % K

% Q matrix (material coordinates)
 denom = 1 - nu12 * nu21 ;
Q11 = E1 / denom        ;
Q12 = nu12 * E2 / denom ;
Q22 = E2 / denom        ;
Q66 = G12               ;

Q = [ Q11 Q12 0; Q12 Q22 0; 0 0 Q66] ;
%Q=[20 .7 0; .7 2 0; 0 0 .7]
a = [a1 a2 0]' ;

% Qbar matrices (laminate coordinates) and contributions to
% ABD matrices

A = zeros(3,3);
B = zeros(3,3);
D = zeros(3,3);

NT = zeros(3,1);
MT = zeros(3,1);

for i = 1:Nplies
  theta  = thetadb(i) * pi / 180; % ply i angle in radians, from bottom
  m = cos(theta) ;
  n = sin(theta) ;
  T = [ m^2 n^2 2*m*n; n^2 m^2 -2*m*n; -m*n m*n (m^2 - n^2)];
  Qbar = inv(T) * Q * (inv(T))' ;
  
   abar = T' * a ;
  
  A = A + Qbar * t;
  B = B + Qbar * t * zbar(i); 
  D = D + Qbar * (t * zbar(i)^2  + t^3 / 12);
  
   NT = NT + Qbar * abar * t * deltaT ;
  MT = MT + Qbar * abar * t * zbar(i) * deltaT ; 
end

ABD    = [A B; B D] ;
