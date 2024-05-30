function [time] = distanceTime(v, dist)
    % Obtains time array given vehicle velocity and the distance
    % discretisation
    %
    % Input: v    - car velocity at each point
    %        dist - distance vector
    %
    % Ouput: time - time at each point

    time = 0;
    for i = 2 : length(dist)
        time(i) = time(i-1) + 2 * (dist(i) - dist(i-1))/ (v(i) + v(i-1)); % solve t = 2s/(v+u)
    end
end

