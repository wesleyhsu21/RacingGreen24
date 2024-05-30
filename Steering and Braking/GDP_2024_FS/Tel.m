tel_dat = readtable("test_trial_lap.csv", 'NumHeaderLines',14);

time = tel_dat(:,"Time");
TireFz.fl = tel_dat(:,"TireLoadFL")
TireFz.fr = tel_dat(:,'TireLoadFR');
TireFz.rl = tel_dat(:,'TireLoadRL');
TireFz.rr = tel_dat(:,'TireLoadRR');


figure
hold on 
plot(table2array(time),table2array(TireFz.fl))
plot((TireFz.fr),time)
plot(TireFz.rl,time)
plot(TireFz.fr,time)
hold off

prettier