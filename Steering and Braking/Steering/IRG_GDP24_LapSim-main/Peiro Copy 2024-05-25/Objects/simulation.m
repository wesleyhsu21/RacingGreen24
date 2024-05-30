classdef simulation


    properties

        x
        y
        dist
        curve
        radius
        v
        time
        slog
        plog
        error


    end


    methods


        function obj = simulation(n)

            obj.x = zeros(1,n);
            obj.y = zeros(1,n);
            obj.dist = zeros(1,n);
            obj.curve = zeros(1,n);
            obj.radius = zeros(1,n);
            obj.v = zeros(1,n);
            obj.time = zeros(1,n);
            obj.slog = slog(n);
            obj.plog = plog(n);
            obj.error = "";

            

        end


    end
    






end