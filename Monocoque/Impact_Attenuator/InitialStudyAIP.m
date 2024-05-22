clear
clc
close all

%% Loading Parameters from InitalStudy_IA
load("IAParams.mat")
IA_Height = IAParams.Height;
IA_Width = IAParams.Width;

%% Parameters
AIP_Height = 0.2;% in m
AIP_Width = 0.3;% in m

%% Calculating bending moment
delta_H = AIP_Height - IA_Height;% Difference in the IA and AIP height in m
Load = 120000;% Total distributed load through the IA determined in the SES
M_max = Load / AIP_Height * IA_Height / 2 * (AIP_Height - delta_H) / 4 - Load / 2 * AIP_Height / 2;
M_max_abs = abs(M_max)