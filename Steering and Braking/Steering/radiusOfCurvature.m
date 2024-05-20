% Function to calculate radius of curvature
function R = radiusOfCurvature(x1, y1, x2, y2, x3, y3)
    % Vectors AB and AC
    AB = [x2 - x1, y2 - y1];
    AC = [x3 - x1, y3 - y1];

    % Cross product of vectors AB and AC
    area = 0.5 * abs(det([AB; AC]));

    if area == 0
        R = inf;
        return;
    end

    % Lengths of the sides of the triangle
    ab = norm(AB);
    bc = norm([x3 - x2, y3 - y2]);
    ac = norm(AC);

    % Radius of curvature formula
    R = (ab * bc * ac) / (4 * area);
end