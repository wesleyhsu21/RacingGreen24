
function time = optimiser(params,event)
    % params - [CLA,CDA,Weight]
    % event - race type
    addpath('Coordinates\')
    addpath('GUI data\')
    addpath("Modules\")
    addpath("Objects\")
    addpath("Tires\")
    addpath('PProcessing\')
    time=0;
    npoints = 1000;
    carparams = carFsAWD;
    s = size(carparams.CLA,3);
    t = size(carparams.CLA,2);
    carparams.CLA(end+1,:,:)=params(1).*ones(1,t,s);
    s = size(carparams.CDA,3);
    t = size(carparams.CDA,2);
    carparams.CDA(end+1,:,:)=params(2).*ones(1,t,s);
    carparams.mass = params(3);
    pp=0;
    try
        [sim] = runsim(carparams,npoints,pp,event);
        if event==3
            start1 = find(sim.x>23.8258);
                    start1 = start1(1);
                    end1 = find(sim.x<25.199);
                    end1 = end1(end);
                    time=time+(sim.time(end1)-sim.time(start1))/4;
        else
            time = time + sim.time(end);
        end
    catch
    end
    return
end