classdef car_brakes

    properties

        front_main_dia
        rear_main_dia
        front_main_A
        rear_main_A
        front_pist_no
        rear_pist_no
        front_dep_A
        rear_dep_A
        front_mu
        rear_mu
        front_rotor_rad
        rear_rotor_rad
        balancebias
        front_unit_torque
        rear_unit_torque
        brake_bias


    end
    
     methods

        function obj = car_brakes()
            
            obj.front_main_dia = 14;    
            obj.rear_main_dia = 22.2;  
            
            obj.front_main_A = pi()/4 *obj.front_main_dia^2 *10e-6; 
            obj.rear_main_A = pi()/4 *obj.rear_main_dia^2 *10e-6;   
            
            obj.front_pist_no = 2;      
            obj.rear_pist_no = 2;      
            
            obj.front_dep_A = 0.00079;   
            obj.rear_dep_A = 0.00079;    
            
            obj.front_mu = 0.35;          
            obj.rear_mu = 0.3;          
            
            obj.front_rotor_rad = 277E-3/2;     
            obj.rear_rotor_rad = 254E-3/2;      

            obj.balancebias = 0.5; 

            obj.front_unit_torque = obj.balancebias * (2 * obj.front_pist_no * obj.front_dep_A * obj.front_mu*  obj.front_rotor_rad)/obj.front_main_A;
            obj.rear_unit_torque= (1-obj.balancebias) * (2 * obj.rear_pist_no * obj.rear_dep_A * obj.rear_mu*  obj.rear_rotor_rad)/obj.rear_main_A;

            obj.brake_bias = obj.front_unit_torque/ (obj.rear_unit_torque+ obj.front_unit_torque);

        end


     end




end
