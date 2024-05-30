function [Fy] = Find_Fy(Fx,Fx_max,Fy_max)

Fy = (1 - (Fx/Fx_max).^2).^0.5 .* Fy_max;