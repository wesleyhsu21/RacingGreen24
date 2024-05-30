classdef plog
    %Post processing log
    %   This object contains data extracted from the simulation for use in
    %   post processing. Serves as point of interaction with GUI
    properties
        OCV;
        I;
        SOC;
        E_gen;
        Q_max;
        T;
      
    end

    methods
        function obj = plog(n)
            %Creates object to store data form various post processing
            %functions

            obj.OCV = zeros(1,n);
            obj.I = zeros(1,n);
            obj.SOC = zeros(1,n);
            obj.E_gen = zeros(1,n);
            obj.Q_max = 0;
            obj.T = zeros(1,n);
        end


    end
end