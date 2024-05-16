function alpha_max = alpha_max_calc(delta_max,min_radius,x,l)
    syms y z
    eqnA = min_radius ^ 2 == (l / 2 - y) ^ 2 + (x / 2 + z) ^ 2;
    eqnB = tand(delta_max) == y / z;
    sols = solve(eqnA,eqnB);
    ysols = double(sols.y);
    zsols = double(sols.z);
    y = ysols(ysols >= 0);
    z = zsols(zsols >= 0);
    alpha_max = atand((l - y(1)) / z(1));
end