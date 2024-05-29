classdef IRGPowertrainTestingParallel

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
        engine_fuel_model
        motor_efficiency
        battery_capacity

    end

    methods

        function obj = IRGPowertrainTestingParallel()

            obj.wheel_rad = 228.6E-3; %m
            obj.mass = 328; %kg
            obj.cog_height = 0.3; %Unknown currently, using the GDP 2022 values.
            obj.cog_split = 0.5;  %Unknown currently, using the GDP 2022 values.
            obj.cog_LR_split = 0.5;    
            obj.cop_height = 0.319; %Unknown currently, using the GDP 2022 values.
            obj.cop_split = 0.4572; %Unknown currently, using the GDP 2022 values.
            obj.cop_LR_split = 0.5; %Unknown currently, using the GDP 2022 values.     
            obj.wheelbase = 1525E-3; %m      
            obj.trackF = 1200E-3; %m           
            obj.trackR = 1200E-3; %m           
            obj.track = (obj.trackF + obj.trackR)/2; 
            obj.CLA = -2.26; %Unknown currently, using the GDP 2022 values.    
            obj.CDA = 1.09; %Unknown currently, using the GDP 2022 values.  
            obj.stiffnesses = [13218,20128,20000,30000];

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
            obj.motor_ratio = 16; %Unknown currently (to be tuned), from GDP 2022        
            obj.motor_torque = 100;
            obj.motor_efficiency = 0.9;
            obj.motor_RPM_Limit = 5900; %Currently extraneous, for cooling.
            obj.motor_cutoff = 3070; %Unknown currently (to be tuned), from GDP 2022
            obj.ratios = [2.615,1.857,1.565,1.35,1.238,1.136] ; %Unknown currently (to be tuned), from GDP 2022: 2.615,1.857,1.565,1.35,1.238,1.136
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

            obj.engine_fuel_model = [2400,0.81;
                2600,0.88;
                2900,1.15;
                3200,1.53;
                3600,1.74;
                4000,1.68;
                4500,1.67;
                4800,1.74;
                5100,1.94;
                5500,2.43;
                6000,2.43;
                6500,2.57;
                7000,2.78;
                7500,2.78;
                8000,2.87;
                8500,3.06;
                9000,3.60;
                1000,4.40;
                11500,5.04;
                12500,6.18;
                13500,6.27;
                14500,6.11]; %Note: currently based on provided iformation by Yicheng, IRG10.
         
            
            obj.motor_model_poly = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3);
            obj.engine_model_poly = polyfit(obj.engine_model(:,1), obj.engine_model(:,2),3);
            
            obj.motor_power_consumption = [obj.motor_model(:,1), obj.motor_model(:,2).*(1/obj.motor_efficiency)];
            obj.engine_fuel_RPM = polyfit(obj.engine_fuel_model(:,1), obj.engine_fuel_model(:,2),3); %update with fuel curve
            obj.motor_power_RPM = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3); 
            
            obj.tyre_pressure = 10;    
            obj.IA = 0;   
            obj.brakeSystem = car_brakes();

            obj.type = "hybrid";

            obj.battery_capacity = 4E+3;

        end

    end


    

end