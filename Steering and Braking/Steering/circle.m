% Function to generate circle points
function [x_plot, y_plot] = circle(x, y, r, theta_min, theta_max)
    th = theta_min:pi/1000:theta_max;
    x_plot = r * cos(th) + x;
    y_plot = r * sin(th) + y;
end