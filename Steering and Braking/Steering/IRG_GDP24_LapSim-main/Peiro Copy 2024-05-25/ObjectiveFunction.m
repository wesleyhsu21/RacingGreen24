function Cost = ObjectiveFunction(x)

sprintTime = optimiser(x, 1); 
accelTime = optimiser(x, 2); 
skidPadTime = optimiser(x, 3); 

skidPadMin = 3;
skidPadMax = 1.25*skidPadMin;
skidPadPoints = 70*((skidPadMax/skidPadTime)^2 - 1)/((skidPadMax/skidPadMin)^2 - 1);

accelMin = 3; 
accelMax = 1.5*accelMin; 
accelPoints = 65*(accelMax/accelTime -1)/(accelMax/accelMin - 1);

sprintMin = 50; 
sprintMax = 1.45*sprintMin;
sprintPoints = 95*(sprintMax/sprintTime -1)/(sprintMax/sprintMin - 1);


Cost = 1/(skidPadPoints + accelPoints + sprintPoints);

disp('Cl, Cd, Mass')
disp(x)
disp(['SprintTime = ', num2str(sprintTime)])
disp(['AccelTime = ', num2str(accelTime)])
disp(['skidPadTime = ', num2str(skidPadTime)])


end

