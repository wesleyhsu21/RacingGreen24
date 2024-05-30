classdef slog

    properties

        ax
        ax_itt
        itt
        ay
        Fz
        Fy
        Fx
        Tire_Fx
        Motor_Fx
        F_L
        F_D
        R
        limiting_factor
        U
        err
        v1
        v2
        v3
        ax_log
        sl
        sa
        rpm
        fuel_consumed
        power_consumed
        overallFuel
        overallEnergy
        engine_heat_power
        motor_heat_power
        brake_heat_energy_change
        braking_force
        vel_select

        rpm_elec
        RPM_limit_hit


    end

    methods
        
        function obj = slog(n)

            obj.ax = zeros(1,n);
            obj.ax_itt = zeros(n,10);
            obj.itt = zeros(n,1);
            obj.ay = zeros(n,1);
            obj.Fz = zeros(n,2,2);
            obj.Fy = zeros(n,2,2);
            obj.Fx = zeros(n,2,2);
            obj.Tire_Fx = zeros(n,2,2);
            obj.Motor_Fx = zeros(n,2,2);
            obj.F_L = zeros(n,1);
            obj.F_D = zeros(n,1);
            obj.R = zeros(n,1);
            obj.limiting_factor = zeros(n,1);
            obj.U = zeros(n,3);
            obj.err = zeros(n,1);
            obj.v1 = zeros(n,1);
            obj.v2 = zeros(n,1);
            obj.v3 = zeros(n,1);
            obj.ax_log = zeros(1,n);
            obj.sa = zeros(n,2,2);
            obj.sl = zeros(n,2,2);
            obj.rpm = zeros(n,4);
            obj.fuel_consumed = zeros(n,4);
            obj.power_consumed = zeros(n,4);
            obj.overallFuel = 0;
            obj.overallEnergy = 0;
            obj.engine_heat_power = zeros(n,4);
            obj.motor_heat_power = zeros(n,1);
            obj.brake_heat_energy_change = zeros(n,2,2);
            obj.braking_force = zeros(n,2,2);
            obj.vel_select = zeros(n,1);
            obj.rpm_elec = zeros(n,4);
            obj.RPM_limit_hit = zeros(n,1);
            


        end


    end






end
