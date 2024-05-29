classdef IRG2024CarBase

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
        ubCLA % Useful
        lbCLA % Useful
       
        CDA
        ubCDA % Useful
        lbCDA % Useful

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

        engine_model % HEV
        motor_cutoff % Have to investigate what this is, could be a HEV thing for motor -> engine transition
        ratios
        tyre_pressure
        type
        IA
        brakeSystem
        motor_model_poly % Polyfits of motor model
        engine_model_poly % HEV
        motor_power_consumption % Polyfit of motor model considering motor efficiency
        engine_fuel_RPM % HEV
        motor_power_RPM % Identical to motor model ??
        engine_fuel_model % HEV
        motor_efficiency % Scale for power consumption
        battery_capacity % Useful
        battery_charging_limit % Useful
        regen_efficiency % Useful
        engine_heat_model % HEV
        engine_heat_model_poly % HEV
        energy_generated % Initialised as 0 

        LF_front % Locking force front 
        LF_rear % Locking force rear
    end

    methods

        function obj = IRG2024CarBase()

            obj.wheel_rad = 232.41E-3; %m
            obj.mass = 241; %kg
            obj.cog_height = 0.32668; %Unknown currently, using the GDP 2022 values.
            obj.cog_split = 0.514;  %Unknown currently, using the GDP 2022 values.
            obj.cog_LR_split = 0.5;    
            obj.cop_height = 0.18833; %Unknown currently, using the GDP 2022 values.
            obj.cop_split = 0.5136; %Unknown currently, using the GDP 2022 values.
            obj.cop_LR_split = 0.5; %Unknown currently, using the GDP 2022 values.     
            obj.wheelbase = 1544E-3; %m      
            obj.trackF = 1242E-3; %m           
            obj.trackR = 1233E-3; %m           
            obj.track = (obj.trackF + obj.trackR)/2; 
            obj.CLA = 0.036281;
            
%             obj.pCLA = 3; %No. of tesing points of sensitivity on CL, higher means more detailed but takes longer to run.
            obj.CDA = 0.43537; %Unknown currently, using the GDP 2022 values.  
         
            obj.stiffnesses = [34551.2,42054.4,19678.4,22912.3];

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
    


        obj.motor_power = 34650;       
        % obj.motor_power = 34650;       
        obj.motor_ratio = 4.3846; %Unknown currently (to be tuned), from GDP 2022        
            obj.motor_torque = 51.88;
            obj.motor_efficiency = 0.95;
            obj.motor_RPM_Limit = 8000; %Currently extraneous, for cooling.
            obj.motor_cutoff = 4800; %Unknown currently (to be tuned), from GDP 2022
            obj.ratios = obj.motor_ratio;
            % obj.ratios = [13.86,9.702,7.392,6.072,5.303,4.821];
%             obj.motor_model = [0,	0
%                                 2755.4039,	14755.3859;
%                                 3104.6616,	14498.199;
%                                 3410.262,   14026.6895;
%                                 3672.2052,	13340.8576;
%                                 3890.4913,	12397.8388;
%                                 4152.4345,	11326.2264;
%                                 4370.7205,	10083.1561;
%                                 4545.3493,	9011.5437;
%                                 4719.9782,	7811.3379;
%                                 4894.607,	5839.5712;
%                                 5069.2358,	4939.4168;
%                                 5287.5218,	2796.1921;
%                                 5549.4651,	52.8645];   % Alien 
obj.motor_model = [0,	0;
                               286.684830937120,	918.367346938769;
                               738.053909467948,	2500.95918367346;
                               1293.14429212700,	5500.63265306123;
                               1823.79827700275,	7000;
                               2372.76355384189,	8000;
                               2854.64078139561,	9183.67346938774;
                               3269.42995966394,	10459.1836734694;
                               3653.73233074149,	11581.6326530612;
                               4092.93656496098,	12857.1428571429;
                               4452.87723466767,	13724.4897959184;
                               4776.25934594399,	14285.7142857143;
                               5087.48728382503,	14591.8367346939;
                               5900            ,	15000           ;    ] ;
            obj.motor_model(:,2) = obj.motor_model(:,2)*4;  
%             obj.motor_model = [0,0;
% 6046.6059,32847;
% 6249.2401,33861.5;
% 6451.8744,34650.6;
% 6605.8764,34650.6;
% 6743.6677,34312.4;
% 6897.6697,33861.5;
% 7051.6717,33523.3;
% 7254.306,33185.2;
% 7432.6241,32959.7;
% 7586.6261,32734.3;
% 7708.2067,32734.3;
% 7829.7872,32621.6;
% 8000,32621.6];   % Emrax, 30kW, from Yicheng, IRG10.
            
%             obj.engine_model = [ 2414, 8085.921992;
%                                   3217, 17482.78436;
%                                   3703, 21068.48219;
%                                   4248, 23296.33513;
%                                   8157, 51335.99258;
%                                   9005, 60272.90726;
%                                   9412, 64947.02863;
%                                   9839, 69371.41511;
%                                   10331, 72816.77223;
%                                   10875, 75101.59664;
%                                   11849, 82142.27112;
%                                   12376, 84784.73319;
%                                   13200, 86164.6508;
%                                   13984, 82655.90919];  %Daytona 675

obj.engine_model = [2137.4795,7179.225518;
3008.1833,15555.00105;
4646.4812,27520.35206;
5356.7921,36238.03098;
5597.3813,37605.4954;
6009.82,40682.32765;
6330.6056,45468.45314;
6605.5646,48545.28538;
6983.6334,50083.66421;
7567.9214,51451.12864;
7865.7938,50254.65319;
8301.1457,52305.84983;
8576.1047,50938.38541;
8759.4108,51109.29982]; %KTM, based on provided information by Yicheng, IRG10.




    obj.engine_fuel_model = [1900,0.635670635;
                                2100,0.6955;
                                2300,0.757630952;
                                2600,0.865015873;
                                2750,0.917212302;
                                2900,0.965861111;
                                3200,1.104253968;
                                3500,1.217916667;
                                4000,1.427619048;
                                4250,1.549900794;
                                4500,1.649107143;
                                5000,1.990079365;
                                5500,2.263293651;
                                6000,2.576190476;
                                6500,2.811507937;
                                7000,2.559803922;
                                7500,3.351190476;
                                8000,3.473015873;
                                8500,3.642857143;

                                9000,3.8571428];


         

obj.engine_heat_model = [1900,0.250259538;
                        2100,0.223966093;
                        2300,0.284339502;
                        2600,0.310343385;
                        2750,0.343269553;
                        2900,0.343136463;
                        3200,0.351154666;
                        3500,0.357840696;
                        4000,0.358672187;
                        4250,0.357103512;
                        4500,0.36375691;
                        5000,0.356389522;
                        5500,0.370476928;
                        6000,0.350566237;
                        6500,0.375449624;
                        7000,0.388050555;
                        7500,0.341194116;
                        8000,0.324454423;
                        8500,0.314786072;

                        9000,0.29]; %KTM, from data provided by Yicheng, IRG10.


            obj.motor_model_poly = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3);
            obj.engine_model_poly = polyfit(obj.engine_model(:,1), obj.engine_model(:,2),3);
            
            obj.motor_power_consumption = [obj.motor_model(:,1), obj.motor_model(:,2).*(1/obj.motor_efficiency)];
            obj.engine_fuel_RPM = polyfit(obj.engine_fuel_model(:,1), obj.engine_fuel_model(:,2),3); %update with fuel curve
            obj.motor_power_RPM = polyfit(obj.motor_model(:,1), obj.motor_model(:,2),3); 
            obj.engine_heat_model_poly = polyfit(obj.engine_heat_model(:,1),obj.engine_heat_model(:,2),2); 
            
            obj.tyre_pressure = 10;    
            obj.IA = 0; %NOTE: this is camber 
            obj.brakeSystem = IRG2023Brakes();

            obj.type = "electric";

            obj.battery_capacity = 4E+3;
            obj.regen_efficiency  = 0.9; 
            obj.energy_generated = 0; %NOTE: put energy in kWh.
            obj.battery_charging_limit = 19.5E+3;

            obj.LF_front = 2.1168E+3; %Locking force, from Braking team.
            obj.LF_rear = 1.4112E+3;

        end

    end


    

end