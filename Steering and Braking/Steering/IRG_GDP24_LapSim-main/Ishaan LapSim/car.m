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

            obj.wheel_rad = 0.232;
            obj.mass = 80;
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
            obj.CLA = -0.25;            
            obj.CDA = 0.25; 
            obj.stiffnesses = [26500,26500,1400*180/pi, 0];

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
                           -K_RollR/trackR,     +wBase*K_R , -K_R;
                           +K_RollF/trackF,    -wBase*K_FR/2, -K_FR;
                           0,                   0 ,             0; ];
    

            obj.motor_power = 160;       
            obj.motor_ratio = 12;        
            obj.motor_torque = 0.25;     
            obj.motor_RPM_Limit = 5900;    
            obj.ratios = obj.motor_ratio ;
            obj.motor_model = [ 0	, 0;
                                286.684830937120	, 3776.22377622375;
                                738.053909467948	, 9860.13986013984;
                                1293.14429212700	, 16783.2167832168;
                                1823.79827700275	, 24125.8741258741;
                                2372.76355384189	, 31468.5314685315;
                                2854.64078139561	, 37762.2377622377;
                                3269.42995966394	, 43006.9930069930;
                                3653.73233074149	, 47622.3776223776;
                                4092.93656496098	, 52867.1328671329;
                                4452.87723466767	, 56433.5664335664;
                                4776.25934594399	, 58741.2587412587;
                                5087.48728382503	, 60000.0000000000;
                                5496.35410367862	, 61678.3216783217;] ;

            obj.tyre_pressure = 2.25;    
            obj.IA = 0;   
            obj.brakeSystem = car_brakes();

        end

    end


    

end