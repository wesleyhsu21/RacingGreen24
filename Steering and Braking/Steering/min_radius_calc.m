function min_radius = min_radius_calc(heading_angle,delta_max,x,l)
    syms y z
    eqnA = tand(heading_angle) == (l / 2 - y) / (x / 2 + z);
    eqnB = tand(delta_max) == y / z;
    sols = solve(eqnA,eqnB);
    ysols = double(sols.y);
    zsols = double(sols.z);
    y = ysols(ysols >= 0);
    z = zsols(zsols >= 0);
    min_radius = sqrt(((z) + (x / 2)) ^ 2+((l / 2) ^ 2));
end