classdef IRG2023Brakes

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
        effective_rad_front
        effective_rad_rear
        front_unit_torque
        rear_unit_torque
        rolling_rad
        brake_bias



    end
    
     methods

        function obj = IRG2023Brakes()
            
%             obj.front_main_dia = 14;    
%             obj.rear_main_dia = 22.2;  
%             
%             obj.front_main_A = pi()/4 *obj.front_main_dia^2 *10e-6; 
%             obj.rear_main_A = pi()/4 *obj.rear_main_dia^2 *10e-6;   

            obj.front_main_A = 0.000626; %Cylinder areas
            obj.rear_main_A = 0.000626;
            
            obj.front_pist_no = 4; %Piston numbers
            obj.rear_pist_no = 2;      
            
            obj.front_dep_A = 0.004; %Pad areas * piston number. Note: previous version of torque calculation used pad area per piston.
            obj.rear_dep_A = 0.0019;    
            
            obj.front_mu = 0.5; %Coefficients of friction
            obj.rear_mu = 0.5;          
            
            obj.front_rotor_rad = 254E-3/2; %Rotor radii     
            obj.rear_rotor_rad = 254E-3/2;    

            obj.effective_rad_front = 0.1; %Effective radii
            obj.effective_rad_rear = 0.1;

            obj.rolling_rad = 0.203; %Rolling radius, calculated by Braking team. Calculated in Rolling Radius calculator by Braking.

            obj.balancebias = 0.4161; %Balance bias
% 
%           obj.front_unit_torque = obj.balancebias * (2 * obj.front_pist_no * obj.front_dep_A * obj.front_mu*  obj.front_rotor_rad)/obj.front_main_A;
%           obj.rear_unit_torque= (1-obj.balancebias) * (2 * obj.rear_pist_no * obj.rear_dep_A * obj.rear_mu*  obj.rear_rotor_rad)/obj.rear_main_A;

%             obj.front_unit_torque = obj.balancebias * (2 * obj.front_dep_A * obj.front_mu*  obj.front_rotor_rad)/obj.front_main_A;
%             obj.rear_unit_torque = (1-obj.balancebias) * (2 * obj.rear_dep_A * obj.rear_mu*  obj.rear_rotor_rad)/obj.rear_main_A;

            obj.front_unit_torque = (obj.balancebias * (2*obj.front_dep_A*obj.front_mu*obj.effective_rad_front)/obj.front_main_A) * (obj.front_rotor_rad/obj.rolling_rad); %Method for calculating front torque on brakes from Braking team.
            obj.rear_unit_torque = ((1-obj.balancebias) * (2*obj.rear_dep_A*obj.rear_mu*obj.effective_rad_rear)/obj.rear_main_A) * (obj.rear_rotor_rad/obj.rolling_rad); %Method for calculating rear torque on brakes from Braking team.

           obj.brake_bias = obj.front_unit_torque / (obj.rear_unit_torque+ obj.front_unit_torque);
%             obj.brake_bias = 0.5;
        end


     end




end