tic;

slipr = zeros(npoints,2,2);
slipa = zeros(npoints,2,2);



for i=1:npoints
    
    [x,y] = findslsa(sim.slog.Fx(i,:,:),sim.slog.Fy(i,:,:),sim.slog.Fz(i,:,:),model,carparams);

    slipr(i,:,:) = reshape(x,[1,2,2]);
    slipa(i,:,:) = reshape(y,[1,2,2]);


end



toc;
