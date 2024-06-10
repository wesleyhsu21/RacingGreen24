function [LocalStress_45,LocalStress_90,LocalStress_0] = CompositeLocalStress(ABD,Q,Loading)
% Function to calculate the local stresses in a lamina containing just +45,
% -45, 0 and 90 degree plies
%
% Inputs:
% ABD               = ABD matrix of the laminate
% Q                 = Stiffness matrix of a ply
% Loading           = 6x1 loading matrix (N_xx; N_yy; N_xy; M_xx; M_yy; M_xy)
%
% Outputs:
% LocalStress_45    = Local stresses in the +-45 degree laminates
% LocalStress_90    = Local stresses in the 90 degree laminates
% LocalStress_0     = Local stresses in the 0 degree laminates

cp45 = cosd(45);
sp45 = sind(45);
cm45 = cosd(-45);
sm45 = sind(-45);
c90 = cosd(90);
s90 = sind(90);

T_epsilon_p45 = [cp45^2 sp45^2 cp45*sp45;
                 sp45^2 cp45^2 -cp45*sp45
                 -2*cp45*sp45 2*cp45*sp45 cp45^2-sp45^2];

T_epsilon_m45 = [cm45^2 sm45^2 cm45*sm45;
                 sm45^2 cm45^2 -cm45*sm45
                 -2*cm45*sm45 2*cm45*sm45 cm45^2-sm45^2];

T_epsilon_90 = [c90^2 s90^2 c90*s90;
                 s90^2 c90^2 -c90*s90
                 -2*c90*s90 2*c90*s90 c90^2-s90^2];

GlobalStrains = inv(ABD) * Loading;

LocalStrains_45 = T_epsilon_p45 * GlobalStrains(1:3);
LocalStrains_90 = T_epsilon_90 * GlobalStrains(1:3);
LocalStrains_0 = GlobalStrains(1:3);

LocalStress_45 = Q * LocalStrains_45;
LocalStress_90 = Q * LocalStrains_90;
LocalStress_0 = Q * LocalStrains_0;
