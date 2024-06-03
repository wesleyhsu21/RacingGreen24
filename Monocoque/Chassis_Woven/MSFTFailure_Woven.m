function [] = MSFTFailure_Woven(LocalStress_45,LocalStress_90,LocalStress_0)
% Function to determine if, where and how a ply fails
%
% Inputs:
% LocalStress_45    = Local Stress in the 45 deg plies
% LocalStress_90    = Local Stress in the 90 deg plies
% LocalStress_0     = Local Stress in the 0 deg plies

sigma_11c_crit = 615e6;   % Critical 11 compressive stress [Pa]
sigma_11t_crit = 645e6;   % Critical 11 tensile stress [Pa]
sigma_22t_crit = 645e6;    % Critical 22 tensile stress [Pa]
sigma_22c_crit = 615e6;    % Critical 22 compressive stress [Pa]
tau_12_crit = 69.8e6;     % Critical 12 shear stress [Pa]

if LocalStress_45(1) < 0
    if LocalStress_45(1) < -sigma_11c_crit
        disp("45 deg plies fail in 11 compression")
    end
end

if LocalStress_45(1) > 0
    if LocalStress_45(1) > sigma_11t_crit
        disp("45 deg plies fail in 11 tension")
    end
end

if LocalStress_45(2) < 0
    if LocalStress_45(2) < -sigma_22c_crit
        disp("45 deg plies fail in 22 compression")
    end
end

if LocalStress_45(2) > 0
    if LocalStress_45(2) > sigma_22t_crit
        disp("45 deg plies fail in 22 tension")
    end
end

if abs(LocalStress_45(3)) > tau_12_crit
        disp("45 deg plies fail in 12")
end



if LocalStress_0(1) < 0
    if LocalStress_0(1) < -sigma_11c_crit
        disp("0 deg plies fail in 11 compression")
    end
end

if LocalStress_0(1) > 0
    if LocalStress_0(1) > sigma_11t_crit
        disp("0 deg plies fail in 11 tension")
    end
end

if LocalStress_0(2) < 0
    if LocalStress_0(2) < -sigma_22c_crit
        disp("0 deg plies fail in 22 compression")
    end
end

if LocalStress_0(2) > 0
    if LocalStress_0(2) > sigma_22t_crit
        disp("0 deg plies fail in 22 tension")
    end
end

if abs(LocalStress_0(3)) > tau_12_crit
        disp("0 deg plies fail in 12")
end



if LocalStress_90(1) < 0
    if LocalStress_90(1) < -sigma_11c_crit
        disp("90 deg plies fail in 11 compression")
    end
end

if LocalStress_90(1) > 0
    if LocalStress_90(1) > sigma_11t_crit
        disp("90 deg plies fail in 11 tension")
    end
end

if LocalStress_90(2) < 0
    if LocalStress_90(2) < -sigma_22c_crit
        disp("90 deg plies fail in 22 compression")
    end
end

if LocalStress_90(2) > 0
    if LocalStress_90(2) > sigma_22t_crit
        disp("90 deg plies fail in 22 tension")
    end
end

if abs(LocalStress_90(3)) > tau_12_crit
        disp("90 deg plies fail in 12")
end