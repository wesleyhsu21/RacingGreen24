%_________FUNCTION TO CALCULATE PACK VOLTAGE FROM SOC____________________
% ____________CONTACT: TOM HOLLAND, TJH17@IC.AC.UK_______________________
% Xuan, D. J. et al. (2020). ‘Real-time estimation of state-of-charge in lithium-ion batteries using
% improved central difference transform method’. In: Journal of Cleaner Production 252,
% p. 119787. issn: 09596526. doi: 10.1016/j.jclepro.2019.119787.

function [V] = StateOfCharge(SOC)

% calculates voltage as a function of the state of charge of the pack

b0 = 2.89;
b1 = 4.75;
b2 = -12.57;
b3 = -16.7;
b4 = 239.87;
b5 = -716.82;
b6 = 1015.8;
b7 = -706.86;
b8 = 193.76;

V = b0 + b1*SOC + b2*SOC^2 + b3*SOC^3 + b4*SOC^4 + b5*SOC^5 + b6*SOC^6 + b7*SOC^7 + b8*SOC^8;  