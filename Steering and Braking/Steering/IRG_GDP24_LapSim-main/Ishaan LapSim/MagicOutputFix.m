% Copyright 2017 The MathWorks, Inc.

function [Force,Slip_vect] = MagicOutput(F,Slip,mu,FZ,CS,mode)
%[Force,Slip_vect] = MagicOutput(F,Slip,mu,FZ,CS,mode)
%==============================
%This function takes non-dimensional quantities from the magic formula and
%expands them to their correct dimensionalised forms.
%==============================
%INPUT ARGUMENTS
%==============================
%F = non-dimensionalised force
%Slip = non-dimensionalised slip quantity
%mu = maximum coefficient of friction (determined from NonDimTrans.m)
%FZ = Vertical load (N)
%CS = Slip Stiffness (determined from NonDimTrans.m) in N/rad
%mode = int input of:
%                       1 = Pure Lateral
%                       2 = Pure Longitudinal
%==============================
%OUTPUT ARGUMENTS
%==============================
%Force = Force vector (N);
%Slip_vect = Slip vector (degrees or dimensionless)
%=============================
if mode == 1
    Force = F.*mu.*FZ;
    %Slip_vect = atan(Slip.*mu.*FZ./(CS*180/pi))*180/pi;
    Slip_vect = atan(Slip.*mu.*FZ./(CS));
elseif mode == 2
    Force = F.*mu.*FZ;
    Slip_vect = Slip.*mu.*FZ./CS;
end