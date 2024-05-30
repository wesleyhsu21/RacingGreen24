clear
clc
close all

% Define parameters
L = 1.5; % Length in meters
W = 300; % Width in mm
t = 0.001572; % Thickness of facesheet in meters
c = 52;  % Thickness of core in mm
cell_size = 6.4; % Size of hexagonal cell in mm
wall_thickness = 0.07; % Wall thickness of hexagonal cell in mm

% Convert to mm
L = L * 1000;
t = t * 1000;

% Create vertices for the facesheets
facesheet1_vertices = [0 0 0;
                       L 0 0;
                       L W 0;
                       0 W 0;
                       0 0 t;
                       L 0 t;
                       L W t;
                       0 W t];

facesheet2_vertices = [0 0 (t + c);
                       L 0 (t + c);
                       L W (t + c);
                       0 W (t + c);
                       0 0 (2*t + c);
                       L 0 (2*t + c);
                       L W (2*t + c);
                       0 W (2*t + c)];

% Define the faces of the boxes using the vertices
faces = [1 2 3 4; 
         5 6 7 8; 
         1 2 6 5; 
         2 3 7 6; 
         3 4 8 7; 
         4 1 5 8];

% Create the figure
composite_structure = figure;
hold on;

% Plot the first facesheet
patch('Vertices', facesheet1_vertices, 'Faces', faces, 'FaceColor', 'blue', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Plot the second facesheet
patch('Vertices', facesheet2_vertices, 'Faces', faces, 'FaceColor', 'blue', 'EdgeColor', 'black', 'FaceAlpha', 0.5);

% Create and plot the hexagonal core
plot_hexagonal_core(L, W, t, c, cell_size, wall_thickness);

% Set the axes properties
xlabel('Length / mm')
ylabel('Width / mm')
zlabel('Height / mm')
axis equal
grid on
view(3)

% Add title
%title('Composite Sandwich Structure with Hexagonal Core')
betterPlot(composite_structure)
legend("off")
hold off;

% Save the figure
saveas(composite_structure, "composite_sandwich_structure.png")

% Function to plot the hexagonal core
function plot_hexagonal_core(L, W, t, c, cell_size, wall_thickness)
    % Calculate the number of hexagons needed
    hex_height = cell_size * sqrt(3);
    num_hex_rows = ceil(W / hex_height);
    num_hex_cols = ceil(L / (1.5 * cell_size));

    for row = 0:num_hex_rows-1
        for col = 0:num_hex_cols-1
            x_offset = col * 1.5 * cell_size;
            y_offset = row * hex_height + mod(col, 2) * (hex_height / 2);
            plot_hexagon(x_offset, y_offset, t, c, cell_size, wall_thickness);
        end
    end
end

% Function to plot a single hexagon
function plot_hexagon(x_offset, y_offset, t, c, cell_size, wall_thickness)
    % Create hexagon vertices
    theta = (0:6) * 2 * pi / 6;
    x_hex = cell_size * cos(theta) + x_offset;
    y_hex = cell_size * sin(theta) + y_offset;

    % Create the faces of the hexagon core
    for i = 1:6
        x1 = x_hex(i);
        y1 = y_hex(i);
        x2 = x_hex(i+1);
        y2 = y_hex(i+1);

        % Draw the walls of the hexagon
        fill3([x1 x2 x2 x1], [y1 y2 y2 y1], [t t (t + c) (t + c)], 'yellow', 'EdgeColor', 'black', 'FaceAlpha', 0.5);
    end
end
