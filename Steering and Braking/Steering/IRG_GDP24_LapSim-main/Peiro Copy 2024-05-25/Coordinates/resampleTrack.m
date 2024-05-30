function [x_s,y_s,distance,curvature_filtered,radius_d] = resampleTrack(x,y,n)

    pp = cscvn([x';y']); % Fit spline to track
    t = cumsum([0, (diff(x').^2 + diff(y').^2).^(1/4)]); % Calculate spline parameter total length of track
    t_s =linspace(min(t),max(t) ,n); % create new spline parameter spacing with new point count
    [p_s] = fnval(pp,t_s); % evalute track spline at all new parameter points
    x_s = p_s(1,:); % extract new x points RETURNED
    y_s = p_s(2,:); % extract new y points RETURNED
    
    Spacing = ((diff(x_s)).^2 + (diff(y_s)).^2).^0.5;    	% Magnitude distance between successive coordinates
    distance = [0,cumsum(Spacing)];                         % Assemble new pythagorian distance between points RETURNED
    theta_s = atan2(gradient(y_s),gradient(x_s));           % Calculate orientation of car at each xy point
    % because of nature of atan2, theta_s should be unwraped (ie not bounded by
    % +/- 2 pi()
    theta_s = unwrap(theta_s);                              % Unwrap the atan2 function to remove discontinuinites around +/- 2 pi
    curvature = gradient(theta_s)./gradient(distance);      % Calculate curvature of new track

    %% Filter Results
    windowSize = round(length(x) / 500);
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    theta_filtered = filter(b,a,theta_s);
    windowSize = round(length(x) / 50);
    b = (1/windowSize)*ones(1,windowSize);
    curvature_filtered = filter(b,a,curvature);             % Filtered curvature RETURNED
    radius_d = 1./ curvature_filtered;                      % Calculate radius of curvature RETURNED
end