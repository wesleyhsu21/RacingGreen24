function [maxRoll, maxPitch, minPitch] = MaxMomentsCalc(Fz_sum, car) 
%   Author:     Jakub Horsky
%               jakub.horsky.cz@gmail.com
%
%   Calculates the coordinates in roll moment v pitch moment space of the
%   vertices of an deltoid that contains the area where the car will not roll
%   over
%
%   Arguments:
%       Fz_sum -- total downforce of the car
%       car {structure} -- includes all car constants
%
%   Returns:
%       maxRoll {1x2 vector} -- coordinates of the deltios vertex where roll moment is max possible
%       maxPitch {1x2 vector} -- coordinates of the deltios vertex where pitch moment is max possible
%       minPutch {1x2 vector} -- coordinates of the deltios vertex where pitch moment is min possible
%
%   Physical Modelling Assumptions:
%       The angular deflection will be small -> small angle approximation
%     
    
    F = [0;0;Fz_sum]; %In max roll all Fz will be on left tires
% F = [Fz Front Left; Fz Rear Left; Fz Front Right; Fz Rear Right]
    U = car.F_max_roll*F;
% U = [roll angle; pitch angle; vertical displacement]
    M = car.K*U;
% M = [roll ,oment, pitch moment, total vertical force]
    
    maxRoll = M(1:2); %[M_roll_maxRoll,M_pitch_maxRoll]    
    maxPitch = [0,Fz_sum*car.wheelbase/2]; %[M_roll_maxPitch,M_pitch_maxPitch]
    minPitch = [0,-Fz_sum*car.wheelbase/2]; %[M_roll_minPitch,M_pitch_minPitch]
end

