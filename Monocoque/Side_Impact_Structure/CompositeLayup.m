clear
clc

load('Wingparams.mat')
load('vnParameters.mat')
load('static_stab.mat')
load('weights.mat')
load("HTPchord.mat")
load("coord008.mat")
load("wingbox_centre.mat")

%Max Length of HTP
MaxL = 4.43;                            %[m]

MTOW = 42300 * 9.81 * 0.8;
MaxHTPWeight = weights.htailW * 9.81 / 2;

L_section = MaxL / 500;
TorqueSum = sum(L_section .* (HTPchord.c .^2));
WeightPerSection = MaxHTPWeight / TorqueSum .* L_section .* (HTPchord.c .^2);
c_root = 3.28;

%% Aero Structural Analysis

Discretisepoints = 500;
y = linspace(0,MaxL,Discretisepoints);  %[m]

v_cruise = 281.37;
rho_cruise = 0.225;

LF = 3.75;  %1.5 safety factor accounted for here

%Total lift from the empennage
HTP_Lift_A = (MTOW * LF * (static_stab.x_cg_Cruise - static_stab.x_acW) - static_stab.C_M0W * 0.5 * rho_cruise * vn.va_true_ms^2 * Wingparams.Sref * static_stab.cbar)/(static_stab.x_ach - static_stab.x_acW) + MaxHTPWeight;
HTP_Lift_D = (MTOW * LF * (static_stab.x_cg_Cruise - static_stab.x_acW) - static_stab.C_M0W * 0.5 * rho_cruise * vn.vd_true_ms^2 * Wingparams.Sref * static_stab.cbar)/(static_stab.x_ach - static_stab.x_acW) + MaxHTPWeight;

%Brad's formula
L0_A = Lift_int(2 * MaxL, HTP_Lift_A);
L0_D = Lift_int(2 * MaxL, HTP_Lift_D);

L_A = L0_A .* (sqrt(1 - (y/(MaxL)).^2)) - WeightPerSection;
L_D = L0_D .* (sqrt(1 - (y/(MaxL)).^2)) - WeightPerSection;
W_inertial = -WeightPerSection;

DistLift_Poly_A = polyfit(y,L_A,6);
DistLift_Poly_D = polyfit(y,L_D,6);
DistLoad_Poly_inertial = polyfit(y,W_inertial,6);

syms x q_A(x) q_D(x) q_inertial(x)

% Define the distributed load function q(x)
q_A(x) = DistLift_Poly_A(1)*x^6 + DistLift_Poly_A(2)*x^5 + DistLift_Poly_A(3)*x^4 + DistLift_Poly_A(4)*x^3 + DistLift_Poly_A(5)*x^2 + DistLift_Poly_A(6)*x^1 + DistLift_Poly_A(7);
q_D(x) = DistLift_Poly_D(1)*x^6 + DistLift_Poly_D(2)*x^5 + DistLift_Poly_D(3)*x^4 + DistLift_Poly_D(4)*x^3 + DistLift_Poly_D(5)*x^2 + DistLift_Poly_D(6)*x^1 + DistLift_Poly_D(7);
q_inertial(x) = DistLoad_Poly_inertial(1)*x^6 + DistLoad_Poly_inertial(2)*x^5 + DistLoad_Poly_inertial(3)*x^4 + DistLoad_Poly_inertial(4)*x^3 + DistLoad_Poly_inertial(5)*x^2 + DistLoad_Poly_inertial(6)*x + DistLoad_Poly_inertial(7);

% Calculate shear force (V)
% Shear force is the integral of q(x) from 0 to x
V_A = int(q_A, x, 0, x);
V_D = int(q_D, x, 0, x);
V_inertial = int(q_inertial, x, 0, x);

% Calculate bending moment (M)
% Bending moment is the integral of V(x) from 0 to x, with a negative sign
% because the moment will act in the opposite direction to counteract the load
M_A = int(V_A, x, 0, x);
M_D = int(V_D, x, 0, x);
M_inertial = int(V_inertial, x, 0, x);

V_fun_A = matlabFunction(V_A);
M_fun_A = matlabFunction(M_A);
Lift_fun_A = matlabFunction(q_A);

V_fun_D = matlabFunction(V_D);
M_fun_D = matlabFunction(M_D);
Lift_fun_D = matlabFunction(q_D);

V_fun_inertial = matlabFunction(V_inertial);
M_fun_inertial = matlabFunction(M_inertial);
Load_fun_inertial = matlabFunction(q_inertial);

SF_A = V_fun_A(y);
BM_A = M_fun_A(y);
Lift_A = Lift_fun_A(y);

SF_D = V_fun_D(y);
BM_D = M_fun_D(y);
Lift_D = Lift_fun_D(y);

SF_inertial = V_fun_inertial(y);
BM_inertial = M_fun_inertial(y);
Load_inertial = Load_fun_inertial(y);

% Flipping to make it look right
SF_A = flip(SF_A);
BM_A = flip(BM_A);

SF_D = flip(SF_D);
BM_D = flip(BM_D);

Load_inertial = flip(Load_inertial);
BM_inertial = flip(BM_inertial);

%% Torque
polyin = polyshape(coord0008(:,1)/100,coord0008(:,2)/100);
[wing_cgx,~] = centroid(polyin);
wing_cgz = 0;
wingbox_centre_x = wingbox_centre.centre(1);

moment_arm_lift = wingbox_centre_x - 0.25;
moment_arm_weight = wingbox_centre_x - wing_cgx;

sectional_lift_A = L0_A .* (sqrt(1 - (y/(MaxL)).^2)) * (MaxL / 500);
sectional_lift_D = L0_D .* (sqrt(1 - (y/(MaxL)).^2)) * (MaxL / 500);

sectional_moment_A = (sectional_lift_A .* moment_arm_lift + WeightPerSection .* moment_arm_weight) .* c;
sectional_moment_D = (sectional_lift_D .* moment_arm_lift + WeightPerSection .* moment_arm_weight) .* c;

for i = 1:length(y)
    torque_A(i) = sum(sectional_moment_A(i:length(y)));
    torque_D(i) = sum(sectional_moment_D(i:length(y)));
end
%% Saving Params
HTPLoad.SF_D = SF_D;
HTPLoad.torque_D = torque_D;
HTPLoad.y = y;

save("HTPLoad.mat")
%% Plotting V_A
% load("HTP_V_A.mat")
% 
% AeroLoading = figure;
% hold on
% plot(y, L_A)
% plot(results.ystation(41:end),results.ForcePerMeter(41:end))
% xlabel("Span Station / m")
% ylabel("Aero Loading / N/m")
% title("Span Load V_A")
% legend("Theoretical","XFLR VLM")
% grid on
% betterPlot(AeroLoading)
% hold off
% 
% ShearForce = figure;
% hold on
% plot(y,SF_A)
% plot(results.ystation(41:end),-results.shear(41:end))
% xlabel("Span Station / m")
% ylabel("Shear Force / N")
% title("Shear Force V_A")
% legend("Theoretical","XFLR VLM")
% grid on
% betterPlot(ShearForce)
% hold off
% 
% BendingMoment = figure;
% hold on
% plot(y,BM_A)
% plot(results.ystation(41:end),-results.bend(41:end))
% xlabel("Span Station / m")
% ylabel("Bending Moment / Nm")
% title("Bending Moment V_A")
% legend("Theoretical","XFLR VLM")
% grid on
% betterPlot(BendingMoment)
% hold off
% 
% TorquePlot = figure;
% hold on
% plot(y,torque_A)
% %plot(results.twist(41:end),-results.twist(41:end))
% xlabel("Span Station / m")
% ylabel("Torque / Nm")
% title("Torque V_A")
% legend("Theoretical","XFLR VLM")
% grid on
% betterPlot(TorquePlot)
% hold off

%% Plotting V_D
load("HTP_V_D.mat")

AeroLoading = figure;
hold on
plot(y, L_D)
plot(results.ystation(41:end),results.ForcePerMeter(41:end))
xlabel("Span Station / m")
ylabel("Loading / N")
title("Span Load V_D")
legend("Aero Load","VLM")
grid on
betterPlot(AeroLoading)
hold off

ShearForce = figure;
hold on
plot(y,SF_D)
%plot(results.ystation(41:end),-results.shear(41:end))
xlabel("Span Station / m")
ylabel("Shear Force / N")
title("Shear Force V_D")
%legend("Theoretical","XFLR VLM")
grid on
betterPlot(ShearForce)
legend off
hold off

BendingMoment = figure;
hold on
plot(y,BM_D)
%plot(results.ystation(41:end),-results.bend(41:end))
xlabel("Span Station / m")
ylabel("Bending Moment / Nm")
title("Bending Moment V_D")
%legend("Theoretical","XFLR VLM")
grid on
betterPlot(BendingMoment)
legend off
hold off

TorquePlot = figure;
hold on
plot(y,torque_D)
%plot(results.twist(41:end),-results.twist(41:end))
xlabel("Span Station / m")
ylabel("Torque / Nm")
title("Torque V_D")
%legend("Theoretical","XFLR VLM")
grid on
betterPlot(TorquePlot)
legend off
hold off
%% Plotting Inertial Forces
InertialPlot1 = figure;
hold on
plot(y,Load_inertial)
xlabel("Span Station / m")
ylabel("Inertial Loading / N")
title   ("Inertial Loading")
grid on
betterPlot(InertialPlot1)
legend off
hold off

InertialPlot2 = figure;
hold on
plot(y,SF_inertial)
xlabel("Span Station / m")
ylabel("Shear Force / N")
title("Inertial Shear")
grid on
betterPlot(InertialPlot2)
hold off

InertialPlot3 = figure;
hold on
plot(y,BM_inertial)
xlabel("Span Station / m")
ylabel("Bending Moment / Nm")
title("Inertial Bending Moment")
grid on
betterPlot(InertialPlot3)
hold off

%% Laminae Data - IM7/8552
rho_nominal = 1.57e3;   % Nominal Density [kg/m3]

% Failure Data
t = 0.131e-3;               % Laminate Thickness [m]
sigma_11c_crit = 1.780e9;   % Critical 11 compressive stress [Pa]
sigma_11t_crit = 2.811e9;   % Critical 11 tensile stress [Pa]
tau_12_crit = 0.1143e9;     % Critical 12 shear stress [Pa]
sigma_22t_crit = 7.56e7;    % Critical 22 tensile stress [Pa]
sigma_22c_crit = 1.78e8;    % Critical 22 compressive stress [Pa]
T_Curing = 180;             % Curing temperature [deg C]

 %Stiffness Data
E_11 = 1.63e11;
E_22 = 1e10;
G12 = 5.59e9;
nu_12 = 0.32;
CTE_11 = -1e-7;     % CTE for 11 []
CTE_22 = 3.1e-5;    % CTE for 22 []
Vf_Nominal = 0.577;
Vf_Actual = 0.577;

resin_E = 3.39e9;   % Not from datasheet
resin_nu = 0.3;     % Not from datasheet
Beta_11 = 0.011;    % Not from datasheet
Beta_22 = 0.63;     % Not from datasheet

% Panel Parameters
% Per semispan
no_panels = 2;

% Dimensions
a = 0.3 * c_root;        %Panel Length [m]
b = 0.05 * c_root;       %Panel Width [m]
c = 0.485 * c_root;      %Wingbox Width [m]
h = 0.06242 * c_root;    %Wingbox Height [m]

T_cure = 177 + 173;     % K

% Internal Loads by Station, x from outboard heading inboard
N_xx = BM_D ./ (h * c);           %[N/m]



%% Min Required laminae for Cover
%Assume compressive case is most limiting due to smallest sigma_crit
%Total number of angle plies in the whole laminate

% 0 Degree
min_0deg_cover = N_xx ./ (t * sigma_11c_crit);          %Rounds up layer requirement
max_0deg_cover_maxlayers = ceil(max(min_0deg_cover));    %Highest number in layer requirement

% 90 Degree
min_90deg_cover = ceil(0.1 * min_0deg_cover);           %10 percent should be 90 deg, 70 percent 0s so 1/7 of 0 plies
min_90deg_cover_maxlayers = ceil(max(min_90deg_cover));

% +- 45 Degree plies
min_45deg_cover = ceil(0.1 * min_0deg_cover);            %Need *2 to balance, unless at mid plane
min_45deg_cover_maxlayers = ceil(max(min_45deg_cover));      %This number is for the number of +- 45 deg plies in total

% Estimated Cover Layup
Layup_Cover_S_root = [45 -45 0 0 90 0 0 45 -45 0 0 90 0];             %Need to check loads
Layup_Cover = cat(2, Layup_Cover_S_root, flip(Layup_Cover_S_root, 2));

Thickness_cover = length(Layup_Cover) * t;

[A_cover, B_cover, D_cover, ABD_cover,~] = ABD(Layup_Cover_S_root);

%% Min Required laminae for Webs

% +- 45 Degree
%Note  *0.5 due to -45 taking care of the other half of loads
min_45deg_web = ceil(2 * abs(SF_D) / (t * tau_12_crit * h));
min_45deg_web_maxlayers = ceil(max(min_45deg_web));

% 90 Degree
min_90_deg_web = ceil(0.1 * min_45deg_web);
min_90_deg_web_maxlayers = ceil(max(min_90_deg_web));

% 0 Degree
min_0_deg_web = ceil(0.1 * min_45deg_web);
min_0_deg_web_maxlayers = ceil(max(min_0_deg_web));

% Estimated Web Layup
Layup_web_S_root = [-45 45 0 -45 45 90 -45 45 0 -45 45 90 -45 45];             % Need to check loads
Layup_web = cat(2, Layup_web_S_root, flip(Layup_web_S_root, 2));

Thickness_web = length(Layup_web) * t;

[A_web, B_web, D_web, ABD_web,~] = ABD(Layup_web_S_root);

%% Spar Buckling Analysis
% Not aiming for any ply drops
% Want Yield Stress = Buckling Stress, or N_xx_y = N_xB
% Most constraining load case is at V_D
% Height of front spar is 0.06242c
FSpar_Height = c_root * 0.06242;
RSpar_Height = c_root * 0.05486;

a_spar = MaxL;  %

%% Min Required laminae for Flanges

% 0 Degree
%min_0_deg_flange = ceil()

%% Front and Rear Spar Load Distribution
% According to slide 56 in AVD Wing Design
Fspar_shear_flow = SF_D / 2 + torque_D; % [N/m]
Rspar_shear_flow = SF_D / 2 - torque_D; % [N/m]

% Shear flow is Shear force per unit length so to find shear stress need to
% divide by thickness of ply
Fspar_shear_stress = Fspar_shear_flow / Thickness_web;
Rspar_shear_stress = Rspar_shear_flow / Thickness_web;
max_Fspar_shear_stress = max(Fspar_shear_stress);
max_Rspar_shar_stress = max(Rspar_shear_stress);

% syms tweb
% tweb = t * no45;

%% Comment out to keep graphs
% close all