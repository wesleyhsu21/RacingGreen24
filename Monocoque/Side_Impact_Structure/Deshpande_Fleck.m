clear
clc
close all

alpha = 2.12; % Estimation if nu^pl = 0
sigma_y_ratio = sqrt(alpha^2 / (1 + (alpha / 3)^2))

epsilon_d = 0.7;% Densification strain
E_c = psiToPa(65e3);
sigma_critical_core = psiToPa(625);% Critical stress same due to isotropic
sigma_critical_core_true = sigma_critical_core * (1 + epsilon_d)
epsilon_d_true = log(1 + epsilon_d)