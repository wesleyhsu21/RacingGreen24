%______FUNCTION TO MODEL BATTERY PARAMETERS USING COLOUMB COUNTING________
% ____________CONTACT: TOM HOLLAND, TJH17@IC.AC.UK________________________

function [OCV I SOC E_gen Q_max] = Batt_Model(P, t)

% P = kw, t = time
%% Battery Data
Q_max = 2.7; % Ah - Cell capacity
r = 5e-2; % Ohms, Module internal resistance
r = 6*r; % Pack internal resistance

%% Initialisation

OCV = zeros(length(P),1);
I = zeros(length(P),1);
SOC = zeros(length(P),1);
Q = zeros(length(P),1); %tracks current capacity at given time
Q(1) = Q_max;
dQ = 0; % change in capacity
% P = P*1000; % convert to W
dt = diff(t); %change in time
P(isnan(P)) = 0;
P(isinf(P)) = 0;


%% Running
for i = 1:length(P)-1
    SOC(i) = Q(i)/Q_max;
    OCV(i) = 96*StateOfCharge(SOC(i)); % pack voltage from SOC relationship
    Eq_roots = roots([r -OCV(i) P(i)]); % solve for current
    I(i) = min(abs(Eq_roots)); % select solution
    
    
    dQ = dt(i)*I(i)/6; % used cell capacity
    dQ = dQ/(3600); % convert to Ah, per cell
    Q(i+1) = Q(i)-dQ; % ramaining cell capacity
end

SOC(end) = SOC(end-1);
    
E_gen = (I.^2)*r; % calculate pack heat generation
    