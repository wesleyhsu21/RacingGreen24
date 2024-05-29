classdef IRG2023Car

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
        ubCLA
        lbCLA
       
        CDA
        ubCDA
        lbCDA

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
        engine_heat_model
        engine_heat_model_poly
        energy_generated

    end

    methods

        function obj = IRG2023Car()

             obj.wheel_rad = 205.74-3; %m
            obj.mass = 300; %kg
            obj.cog_height = 0.312;
            obj.cog_split = 0.6; 
            obj.cog_LR_split = 0.5;    
            obj.cop_height = 0.319; %Unknown currently, using the GDP 2022 values.
            obj.cop_split = 0.4572; %Unknown currently, using the GDP 2022 values.
            obj.cop_LR_split = 0.5; %Unknown currently, using the GDP 2022 values.     
            obj.wheelbase = 1525E-3; %m      
            obj.trackF = 1200E-3; %m           
            obj.trackR = 1200E-3; %m           
            obj.track = (obj.trackF + obj.trackR)/2; 
            obj.CLA = -2.8;
            obj.ubCLA = -3.5; %Upper bound of sensitivity on CL
            obj.lbCLA = -1.5; %Lower bound of sensitivity on CL
%             obj.pCLA = 3; %No. of tesing points of sensitivity on CL, higher means more detailed but takes longer to run.
            obj.CDA = 1.09; %Unknown currently, using the GDP 2022 values.  
            obj.ubCDA = 0.5; %Upper bound of sensitivity on CD
            obj.lbCDA = 1.5; %Lower bound of sensitivity on CD
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
    

            obj.motor_power = 30000;       
            obj.motor_ratio = 5.6; %Unknown currently (to be tuned), from GDP 2022        
            obj.motor_torque = 51.26;
            obj.motor_efficiency = 0.95;
            obj.motor_RPM_Limit = 8000; %Currently extraneous, for cooling.
            obj.motor_cutoff = 3070; %Unknown currently (to be tuned), from GDP 2022
            obj.ratios = [15.36,10.75,8.19,6.73,5.88,5.34] ; %Unknown currently (to be tuned), from GDP 2022: 2.615,1.857,1.565,1.35,1.238,1.136
            obj.motor_model = [0,	0
                                2755.4039,	14755.3859;
                                3104.6616,	14498.199;
                                3410.262,   14026.6895;
                                3672.2052,	13340.8576;
                                3890.4913,	12397.8388;
                                4152.4345,	11326.2264;
                                4370.7205,	10083.1561;
                                4545.3493,	9011.5437;
                                4719.9782,	7811.3379;
                                4894.607,	5839.5712;
                                5069.2358,	4939.4168;
                                5287.5218,	2796.1921;
                                5549.4651,	52.8645];   % Alien 

%             obj.motor_model = [0,	0;
%                             6046.606,32847;
%                             6249.24,33861.5;
%                             6451.874,34650.6;
%                             6605.876,34650.6;
%                             6743.668,34312.4;
%                             6897.67,33861.5;
%                             7051.672,33523.3;
%                             7254.306,33185.2;
%                             7432.624,32959.7;
%                             7586.626,32734.3;
%                             7708.207,32734.3;
%                             7829.787,32621.6;
%                             8000,32621.6]; %Emrax.
            
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
                                  13984, 82655.90919];  %Daytona 675

%             obj.engine_model = [2137.4795,7.1792E+3;
%                                 3008.1833,15.555E+3;
%                                 4646.4812,27.520E+3;
%                                 5356.7921,36.238E+3;
%                                 5597.3813,37.605E+3;
%                                 6009.82,40.682E+3;
%                                 6330.6056,45.468E+3;
%                                 6605.5646,48.545E+3;
%                                 6983.6334,50.084E+3;
%                                 7567.9214,51.4511E+3;
%                                 7865.9214,50.257E+3;
%                                 8301.1457,52.306E+3;
%                                 8576.1047,50.938E+3;
%                                 8759.4108,51.109E+3]; %KTM, from Yicheng, IRG10.

%             obj.engine_fuel_model = [2400,0.81;
%                 2600,0.88;
%                 2900,1.15;
%                 3200,1.53;
%                 3600,1.74;
%                 4000,1.68;
%                 4500,1.67;
%                 4800,1.74;
%                 5100,1.94;
%                 5500,2.43;
%                 6000,2.43;
%                 6500,2.57;
%                 7000,2.78;
%                 7500,2.78;
%                 8000,2.87;
%                 8500,3.06;
%                 9000,3.60;
%                 10000,4.40;
%                 11500,5.04;
%                 12500,6.18;
%                 13500,6.27;
%                 14500,6.11]; %Note: currently based on provided information by Yicheng, IRG10.


    obj.engine_fuel_model = [1900,	0.476752976;
                                        2100,	0.521625;
                                        2300,	0.568223214;
                                        2600,	0.648761905;
                                        2750,	0.687909226;
                                        2900,	0.724395833;
                                        3200,	0.828190476;
                                        3500,	0.9134375;
                                        4000,	1.070714286;
                                        4250,	1.162425595;
                                        4500,	1.236830357;
                                        5000,	1.492559524;
                                        5500,	1.697470238;
                                        6000,	1.932142857;
                                        6500,	2.108630952;
                                        7000,	2.33125;
                                        7500,	2.513392857;
                                        8000,	2.604761905;
                                        8500,	2.732142857;
                                        9000,	2.892857143]; %KTM, from Yicheng, IRG10.
         
%             obj.engine_heat_model = [2400,0.245;
%                 2600,0.283;
%                 2900,0.275;
%                 3200,0.247;
%                 3600,0.260;
%                 4000,0.310;
%                 4500,0.362;
%                 4800,0.373;
%                 5100,0.358;
%                 5500,0.348;
%                 6000,0.344;
%                 6500,0.358;
%                 7000,0.384;
%                 7500,0.395;
%                 8000,0.415;
%                 8500,0.422;
%                 9000,0.387;
%                 10000,0.363;
%                 11500,0.369;
%                 12500,0.316;
%                 13500,0.309;
%                 14500,0.288]; %Note: currently based on provided information by Yicheng, IRG10. Daytona.

                obj.engine_heat_model = [1900,	0.33;
                                        2100,	0.30;
                                        2300,	0.38;
                                        2600,	0.41;
                                        2750,	0.46;
                                        2900,	0.46;
                                        3200,	0.47;
                                        3500,	0.48;
                                        4000,	0.48;
                                        4250,	0.48;
                                        4500,	0.49;
                                        5000,	0.48;
                                        5500,	0.49;
                                        6000,	0.47;
                                        6500,	0.50;
                                        7000,	0.48;
                                        7500,	0.45;
                                        8000,	0.43;
                                        8500,	0.42;
                                        9000,	0.3965]; %KTM, from Yicheng, IRG10.

            obj.motor_model_poly = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3);
            obj.engine_model_poly = polyfit(obj.engine_model(:,1), obj.engine_model(:,2),3);
            
            obj.motor_power_consumption = [obj.motor_model(:,1), obj.motor_model(:,2).*(1/obj.motor_efficiency)];
            obj.engine_fuel_RPM = polyfit(obj.engine_fuel_model(:,1), obj.engine_fuel_model(:,2),3); %update with fuel curve
            obj.motor_power_RPM = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3); 
            obj.engine_heat_model_poly = polyfit(obj.engine_heat_model(:,1),obj.engine_heat_model(:,2),2); 
            
            obj.tyre_pressure = 10;    
            obj.IA = 0; %NOTE: this is camber. 
            obj.brakeSystem = IRG2023Brakes();

            obj.type = "hybrid";

            obj.battery_capacity = 2.45E+3;
            obj.energy_generated = 0; %NOTE: put energy in kWh.

        end

    end


    

end