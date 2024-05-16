function centre_placement(theta,xlims,alpha_max,l,y,x)
    % ANGLE CALCULATION THROUGH CENTRE PLACEMENT

    if theta == 0
        % Steering angles representation AWS
        plot(xlims,[l,l],'g')
        plot(xlims,[0,0],'g')
    else
        if theta < 0
            alpha = - theta / 180 * alpha_max;
            z = (l - y) / tand(alpha);
            beta = atand((l - y) / (z + x));
            delta = atand(y / z);
            gamma = atand(y / (z + x));
        elseif theta > 0
            beta = - theta / 180 * alpha_max;
            z = (l - y) / tand(beta);
            alpha = atand((l - y) / (z + x));
            delta = atand(y / z);
            gamma = atand(y / (z + x));
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