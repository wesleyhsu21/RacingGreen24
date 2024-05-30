function [Fx, Fy] = combinedPacejkaFix(SA, SL, latParams, longParams, FZ)
    % Parameters  = [B, E, mu, CS]
    SA_n =  tan(SA) .* latParams(4) ./(FZ .* latParams(3));
    SL_n =  SL * longParams(4)./(FZ .* longParams(3));
    
    % Owen's method of non-dimensionalising slip:
%     Sx = SL ./ (1 + SL);
%     Sy = tan(SA) ./ (1+SL);
    
    S = sqrt(SA_n.^2 + SL_n.^2);
    %S = sqrt(SA.^2 + SL.^2) * sqrt((latParams(4)./(FZ * latParams(3))).^2 + (longParams(4)./ (FZ * longParams(3))).^2);
    
    [Fy0 , ~] = MagicOutputFix(MagicFormula([latParams(1), latParams(2)], S), S, latParams(3), FZ, latParams(4), 1);
    [Fx0 , ~] = MagicOutputFix(MagicFormula([longParams(1), longParams(2)], S) ,S ,longParams(3),FZ,longParams(4),2);
  
    % Owen's method of non-dimensionalising slip:
    %thetaS = atan2(Sy, Sx);
    

    thetaS = atan2(SA_n * latParams(4), SL_n * longParams(4));
    
    Ft = sqrt(Fy0.^2 .* Fx0.^2./(Fy0.^2.*cos(thetaS).^2 + Fx0.^2.*sin(thetaS).^2));
    Ft(isnan(Ft)) = 0;
    Fx = Ft .* cos(thetaS);
    Fy = Ft .* sin(thetaS);
end