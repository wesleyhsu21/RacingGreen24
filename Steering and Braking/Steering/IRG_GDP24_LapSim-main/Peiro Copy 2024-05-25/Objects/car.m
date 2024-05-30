classdef car

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
        ratios
        tyre_pressure
        IA
        brakeSystem

    end

    methods

        function obj = car()

            obj.wheel_rad = 0.2305;
            obj.mass = 80;
            obj.cog_height = 0.15;
            obj.cog_split = 0.5;        
            obj.cog_LR_split = 0.5;     
            obj.cop_height = 0.15;       
            obj.cop_split = 0.5;        
            obj.cop_LR_split = 0.5;     
            obj.wheelbase = 1.25;       
            obj.trackF = 1.245;           
            obj.trackR = 1.235;           
            obj.track = (obj.trackF + obj.trackR)/2; 
            obj.CLA = -0.25;            
            obj.CDA = 0.10; 
            obj.stiffnesses = [35000,35000,1400*180/pi, 0];

            K_FL = obj.stiffnesses(1);    %wheel rate front left (N/m)
            K_FR = K_FL;                  %wheel rate front right (N/m)
            K_R = obj.stiffnesses(2);    %wheel rate rear (N/m)
            K_RollF = obj.stiffnesses(3); %roll rate front (Nm/rad)
            K_RollR = obj.stiffnesses(4); %roll rate rear (Nm/rad)
            wBase = obj.wheelbase;
            trackF = obj.trackF;
            trackR = obj.trackR;

            obj.K = [(K_RollF+K_RollR)   ,0                                              ,0;
            0                   ,wBase^2/4*(K_FL + K_FR + K_R)   ,wBase/2*(-K_FL - K_FR + K_R);
            0                   ,wBase/2 *(K_R - K_FL -K_FR)     ,(K_FL +K_FR +K_R)];

            obj.F = inv(obj.K);

            U = obj.F * [0; 0; obj.mass*9.81]; 
            obj.unloadedGroundClearance = 0.01 + U(3);

            obj.K_max_roll = [  -K_RollF/trackF                ,-wBase*K_FL/2          ,- K_FL;
                                -K_RollR/trackR                ,+wBase*K_R/2          ,- K_R;
                                +K_RollF/trackF+K_RollR/trackR ,wBase*(K_FR - K_R)    ,-(K_FR + K_R)];

            obj.F_max_roll = inv(obj.K_max_roll);

            obj.K_Fz = [   -K_RollF/trackF,    -wBase*K_FL/2, -K_FL;
                           -K_RollR/trackR,     +wBase*K_R/2  , -K_R;
                           +K_RollF/trackF,    -wBase*K_FR/2, -K_FR;
                           0,                   0 ,             0; ];
    

            obj.motor_power = 160;       
            obj.motor_ratio = 12;        
            obj.motor_torque = 0.25;     
            obj.motor_RPM_Limit = 5900;    
            obj.ratios = obj.motor_ratio ;
            obj.motor_model = [ 0	, 0;
                                286.684830937120	, 9.7960;
                                738.053909467948	, 25.5784;
                                1293.14429212700	, 43.5376;
                                1823.79827700275	, 62.5854;
                                2372.76355384189	, 81.6331;
                                2854.64078139561	, 97.9597;
                                3269.42995966394	, 111.5652;
                                3653.73233074149	, 123.5381;
                                4092.93656496098	, 137.1436;
                                4452.87723466767	, 146.3953;
                                4776.25934594399	, 152.3817;
                                5087.48728382503	, 155;
                                5496.35410367862	, 160;] ;

            obj.tyre_pressure = 6;    
            obj.IA = 0;   
            obj.brakeSystem = car_brakes();

        end

    end


    

end