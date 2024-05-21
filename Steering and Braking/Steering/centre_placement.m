function [alpha,beta,delta,gamma,ba_anti] = centre_placement(theta,xlims,alpha_max,l,y,x)
    % ANGLE CALCULATION THROUGH CENTRE PLACEMENT

    if theta == 0
        % Steering angles representation AWS
        plot(xlims,[l,l],'g')
        plot(xlims,[0,0],'g')
        alpha = 0;
        beta = 0;
        delta = 0;
        gamma = 0;
    else
        if theta < 0
            alpha = - theta / 180 * alpha_max;
            z = (l - y) / tand(alpha);
            beta = atand((l - y) / (z + x));
            ba_anti = atand((l - y) / (z - x));
            delta = atand(y / z);
            gamma = atand(y / (z + x));
            xint = x - l / tand(ba_anti);
            plot([xint,x],[0,l],'m')
        elseif theta > 0
            beta = - theta / 180 * alpha_max;
            z = (l - y) / tand(- beta);
            alpha = - atand((l - y) / (x + z));
            ba_anti = - atand((l - y) / (z - x));
            gamma = - atand(y / z);
            delta = - atand(y / (z + x));
            z = - z - x;
            xint = - l / tand(ba_anti);
            plot([xint,0],[0,l],'m')
        end
        % Centre of rotation AWS
        plot(-z,y,'gx',LineWidth=3)
        % Steering angles representation AWS
        plot([-z,x],[y,l],'g')
        plot([-z,0],[y,l],'g')
        plot([-z,0],[y,0],'g')
        plot([-z,x],[y,0],'g')
        % Turning radius representation AWS
        plot([-z,x/2],[y,l/2],'g')
    end

end