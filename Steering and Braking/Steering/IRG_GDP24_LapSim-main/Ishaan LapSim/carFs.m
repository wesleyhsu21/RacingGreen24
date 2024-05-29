classdef carFs

    properties
        
        wheel_rad
        mass
        cog_height
        cog_split
        cog_LR_split
        cop_height
        cop_split
        cop_LR_split
        wheelbase
        trackF
        trackR
        track
        CLA
        CDA
        stiffnesses
        K
        F
        unloadedGroundClearance
        K_max_roll
        F_max_roll
        K_Fz
        motor_power
        motor_ratio
        motor_torque
        motor_RPM_Limit
        motor_model
        engine_model
        motor_cutoff
        ratios
        tyre_pressure
        type
        IA
        brakeSystem
        motor_model_poly
        engine_model_poly
        motor_power_consumption
        engine_fuel_RPM
        motor_power_RPM
        motor_efficiency
        battery_capacity

    end

    methods

        function obj = carFs()

            obj.wheel_rad = 0.232;
            obj.mass = 278;
            obj.cog_height = 0.3;
            obj.cog_split = 0.5;        
            obj.cog_LR_split = 0.5;     
            obj.cop_height = 0.3;       
            obj.cop_split = 0.5;        
            obj.cop_LR_split = 0.5;     
            obj.wheelbase = 1.55;       
            obj.trackF = 1.245;           
            obj.trackR = 1.235;           
            obj.track = (obj.trackF + obj.trackR)/2; 
            obj.CLA = -2.25;            
            obj.CDA = 0.675; 
            obj.stiffnesses = [26500,26500,1400*180/pi, 1260*180/pi];

            K_FL = obj.stiffnesses(1);    %wheel rate front left (N/m)
            K_FR = K_FL;        %wheel rate front right (N/m)
            K_RL = obj.stiffnesses(2);    %wheel rate rear left (N/m)
            K_RR = K_RL;        %wheel rate rear right (N/m)
            K_RollF = obj.stiffnesses(3); %roll rate front (Nm/rad)
            K_RollR = obj.stiffnesses(4); %roll rate rear (Nm/rad)
            wBase = obj.wheelbase;
            trackF = obj.trackF;
            trackR = obj.trackR;

            obj.K = [   (K_RollF+K_RollR)   ,0                                              ,0;
            0                   ,wBase^2/4*(K_FL + K_FR + K_RL +K_RR)   ,wBase/2*(-K_FL - K_FR + K_RL + K_RR);
            0                   ,wBase/2 *(K_RL +K_RR - K_FL -K_FR)     ,(K_FL +K_FR +K_RL +K_RR)];
            obj.F = inv(obj.K);

            U = obj.F * [0; 0; obj.mass*9.81]; 
            obj.unloadedGroundClearance = 0.04 + U(3);

            obj.K_max_roll = [  -K_RollF/trackF                ,-wBase*K_FL/2          ,- K_FL;
                                -K_RollR/trackR                ,+wBase*K_RL/2          ,- K_RL;
                                +K_RollF/trackF+K_RollR/trackR ,wBase*(K_FR - K_RR)    ,-(K_FR + K_RR)];

            obj.F_max_roll = inv(obj.K_max_roll);

         obj.K_Fz = [   -K_RollF/trackF,    -wBase*K_FL/2, -K_FL;
        -K_RollR/trackR,    +wBase*K_RL/2, -K_RL;
        +K_RollF/trackF,    -wBase*K_FR/2, -K_FR;
        +K_RollR/trackR,    +wBase*K_RR/2, -K_RR];
    

            obj.motor_power = 60000;       
            obj.motor_ratio = 1;        
            obj.motor_torque = 230;
            obj.motor_efficiency = 0.9;
            obj.motor_RPM_Limit = 5900;  
            obj.motor_cutoff = 5000;
            obj.ratios = [6, 5, 4, 3, 2, 1] ;
            obj.motor_model = [0.0, 0.0;
                            6286.2944, 34038.8;
                            6375.6345, 34491.1;
                            6497.4619, 34604.2;
                            6578.6802, 34717.3;
                            6643.6548, 34717.3;
                            6749.2386, 34264.9;
                            6846.7005, 34038.8;
                            6960.4061, 33812.6;
                            7065.9898, 33586.4;
                            7285.2792, 33247.2;
                            7512.6904, 32907.9;
                            7683.2487, 32907.9;
                            7991.8782, 32794.8] ;
            
            obj.engine_model = [ 2414, 8085.921992;
                                  3217, 17482.78436;
                                  3703, 21068.48219;
                                  4248, 23296.33513;
                                  8157, 51335.99258;
                                  9005, 60272.90726;
                                  9412, 64947.02863;
                                  9839, 69371.41511;
                                  10331, 72816.77223;
                                  10875, 75101.59664;
                                  11849, 82142.27112;
                                  12376, 84784.73319;
                                  13200, 86164.6508;
                                  13984, 82655.90919]; 
            
            obj.motor_model_poly = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3);
            obj.engine_model_poly = polyfit(obj.engine_model(:,1), obj.engine_model(:,2),3);
            
            obj.motor_power_consumption = [obj.motor_model(:,1), obj.motor_model(:,2).*(1/obj.motor_efficiency)];
            obj.engine_fuel_RPM = polyfit(obj.engine_model(:,1), obj.engine_model(:,2),3); %update with fuel curve
            obj.motor_power_RPM = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3);
            
            obj.tyre_pressure = 10;    
            obj.IA = 0;   
            obj.brakeSystem = car_brakes();

            obj.type = "hybrid";

            obj.battery_capacity = 4E+3;

        end

    end


    

end