classdef simulation


    properties

        x
        y
        dist
        curve
        radius
        delta_heading
        delta_heading_corner_max
        v
        time
        slog


    end


    methods


        function obj = simulation(n)

            obj.x = zeros(1,n);
            obj.y = zeros(1,n);
            obj.dist = zeros(1,n);
            obj.curve = zeros(1,n);
            obj.radius = zeros(1,n);
            obj.delta_heading = zeros(1,n);
            obj.delta_heading_corner_max = 0;
            obj.v = zeros(1,n);
            obj.time = zeros(1,n);
            obj.slog = slog(n);

            

        end


    end
    






end