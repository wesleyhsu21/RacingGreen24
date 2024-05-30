function [F_L, F_D] = Aero_Forces(v_x , CLA, CDA) 
    % This contains the full aero force models
    % Input: v_x - current car velocity
    %        CLA - Coefficient of Lift per m^2 
    %        CDA - Coefficient of Drag per m^2
    %
    % Output: Lift +ve upwards
    %         Drag +ve rearwards
    % 
    % To Do:
    % 1. Add a simplistic aero model (start with Reynolds sensitivity)

    rho = 1.19;         % Air density (should be taken from CFD but alternatively could be scaling factor
    
    CLA = CLA + 0 .* v_x;  % Super Simplistic fit for lift based on velocity
    CDA = CDA + 0 .* v_x;  % Ditto
    
    F_L = 0.5*rho*(v_x.^2)*CLA; % Calculate Lift Force
    F_D = 0.5*rho*(v_x.^2)*CDA; % Calculate Drag Force
end