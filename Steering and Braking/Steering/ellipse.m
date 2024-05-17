function [x_ellipse, y_ellipse] = ellipse(p1, p2, p3)
    % Extract coordinates from input points
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    x3 = p3(1);
    y3 = p3(2);

    % Calculates semi-major axis
    a = (x3-x1)/2;

    % Calculates semi-minor axis
    b = y2;

    % Defines theta range
    theta = 0: pi/100 : pi;

    % Works out x and y coordinates of ellipse
    x_ellipse = a.*cos(theta);
    y_ellipse = b.*sin(theta);
end




