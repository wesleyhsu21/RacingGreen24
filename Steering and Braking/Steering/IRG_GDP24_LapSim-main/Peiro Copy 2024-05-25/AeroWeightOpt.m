
x0 = [-2.47, 1.01, 273.08];
Cost = @(x) ObjectiveFunction(x);
ub = [0, 2.5, 350];
lb = [-3.5, 0, 150];


options = optimoptions('fmincon','Display','iter','TolFun',1e-6,'TolX',1e-6,'MaxFunEvals',1000,'PlotFcn',{'optimplotfval','optimplotconstrviolation','optimplotfvalconstr'});
optimisedvars = fmincon(Cost, x0, [], [], [], [], lb, ub);

