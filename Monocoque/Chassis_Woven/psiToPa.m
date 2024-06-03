function [Pa] = psiToPa(psi)
% Function to convert psi to Pascals
%
% Input:
% psi = Pressure in Pounds per Square Inch
%
% Output:
% Pa = Pressure in Pascals

Pa = 6894.76 * psi;
end