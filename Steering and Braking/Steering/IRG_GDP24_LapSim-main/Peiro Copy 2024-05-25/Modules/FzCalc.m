function [Fz, U] = FzCalc(M_roll, M_pitch, Fz_total, car)
%   Author:     Jakub Horsky
%               jakub.horsky.cz@gmail.com
%
%   Calculates normal tire and car deflections forces given roll moment, 
%   pitch moment and total downforce using suspension flexible matrix
%
%   Arguments:
%       M_roll {double} -- roll moment on the car
%       M_ptch {double} -- pitch moment on the car (positive nose up)
%       Fz_total {double} -- total downforce of the car
%       car {structure} -- includes all car constants
%
%   Returns:
%       Fz {2x2 matrix} -- normal tire forces ([front left, front right, rear left, rear right])
%       U {3x1 vector} -- car deflections ([roll (rad), pitch (rad, positive pitch up), ground cleaaence (m)])
%
%   Physical Modelling Assumptions:
%       The angular deflection will be small -> small angle approximation
% 
    Fz_total = -Fz_total;
    
    U = car.F * [M_roll; M_pitch; Fz_total]; 

    Fz = car.K_Fz*U;
    Fz = reshape(Fz,[2,2]);

    U(3) = car.unloadedGroundClearance + U(3);
    
end

