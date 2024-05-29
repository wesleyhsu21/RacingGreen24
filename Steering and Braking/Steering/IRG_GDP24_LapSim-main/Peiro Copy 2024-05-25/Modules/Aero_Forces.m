function [F_L, F_D, F_S] = Aero_Forces(v_x , car, U) 
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

    pitch = [-0.0500000000000000	-0.0400000000000000	-0.0300000000000000	-0.0200000000000000	-0.0100000000000000	0	0.0100000000000000	0.0200000000000000	0.0300000000000000	0.0400000000000000	0.0500000000000000];
    roll = [0	0.0100000000000000	0.0200000000000000	0.0300000000000000	0.0400000000000000	0.0500000000000000	0.0600000000000000	0.0700000000000000	0.0800000000000000	0.0900000000000000	0.100000000000000];
    vertical = [0	0.0100000000000000	0.0200000000000000	0.0300000000000000	0.0400000000000000	0.0500000000000000	0.0600000000000000	0.0700000000000000	0.0800000000000000	0.0900000000000000	0.100000000000000];
    
    pind = find(min(abs(pitch-U(1)))==abs(pitch-U(1)));

    rind = find(min(abs(roll-U(2)))==abs(roll-U(2)));

    vind = find(min(abs(vertical-U(3)))==abs(vertical-U(3)));

    % CDA = car.CDA(pind,rind,vind);
    % 
    % CLA = car.CLA(pind,rind,vind);
    CDA = car.CDA(end,end,1);
    CLA = car.CLA(end,end,1);

    CSA = car.CSA(pind,rind,vind);
    
    F_L = 0.5*rho*(v_x.^2)*CLA; % Calculate Lift Force
    F_D = 0.5*rho*(v_x.^2)*CDA; % Calculate Drag Force
    F_S = 0.5*rho*(v_x.^2)*CSA; 
end