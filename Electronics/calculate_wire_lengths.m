% function total_wire_lengths = calculate_wire_lengths()
% % Calculate Wire Lengths for IRG24
clear
clc
% Component Positions 
component_positions = {
    'LV Battery', [1890, 0, 196];
    'Power Distribution PCB', [2510, 0, 196];
    'MCU', [2510, 0, 196];
    'MCU Relay', [2510, 0, 196];
    'AMS/IMD', [2510, 0, 196];
    'BSPD', [2510, 0, 196];
    'Telemetry Microcontroller', [2510, 0, 196];
    'Inertia Sensor', [2510, 0, 196];
    'Cockpit Shutdown', [1200,0,570];
    'Right Shutdown', [1200,300,570];
    'Left Shutdown', [1200,-300,570];
    'BOTS', [350, 0, 120];
    'Wheel FL', [670, -600, 228.5];  % Front Left Wheel 
    'Wheel FR', [670, 600, 228.5]; % Front Right Wheel 
    'Wheel RL', [2195, -600, 228.5]; % Rear Left Wheel 
    'Wheel RR', [2195, 600, 228.5];% Rear Right Wheel 
    'Brake Temperature Sensor FL', [670, -600, 228.5];
    'Brake Temperature Sensor FR', [670, 600, 228.5];
    'Brake Temperature Sensor RL', [2195, -600, 228.5];
    'Brake Temperature Sensor RR', [2195, 600, 228.5];
    'Tyre Temperature Sensor FL', [670, 600, 228.5];
    'Tyre Temperature Sensor FR', [670, 600, 228.5];
    'Tyre Temperature Sensor RL', [2195, -600, 228.5];
    'Tyre Temperature Sensor RR', [2195, 600, 228.5];
    'Tyre Pressure Sensor FL', [670, 600, 228.5];
    'Tyre Pressure Sensor FR', [670, 600, 228.5];
    'Tyre Pressure Sensor RL', [2195, -600, 228.5];
    'Tyre Pressure Sensor RR', [2195, 600, 228.5];
    'Brake Pedal', [350, 0, 120]; % Brake Pedal (Travel Sensor)
    'TS Accumulator', [2200,0,116]; % Tractive System Accumulator (Temp Sensor)
    'Motor Controller Rear', [2100, 50, 260]; % Rear Motor Controller
    'Motor Rear', [2100, 50, 230];
    'Motor Controller Front', [670, 0, 228.5]; % Front Motor Controller
    'HVD', [2200,0,200];
    'Precharge PCB', [2510, 0, 196];
    'Precharge Relay', [2510, 0, 196];
    'AIR+', [2200,20,116];
    'AIR-', [2200,-20,116];
    'TSMS', [2200,0,200];
    'Brake Pressure Sensor', [350, 0, 120];
    'Throttle Position Sensor', [350, 0, 120]; % Same as throttle pedal
    'Coolant Temp Sensor', [2200,0,116]; % In TS Accumulator
    'Pump 1', [2460,210.5,147]; % Cooling Pump 1
    'Pump 2', [2460,210.5,147]; % Cooling Pump 2
    'Pump 3', [2460,210.5,147]; % Cooling Pump 3
    'Dashboard', [1200,0,570];
    'Speed Sensor electronic', [2510, 0, 196]; %GPS based
    'Speed Sensor RPM', [670, -600, 228.5]; %Front left wheel
    'Charger Shutdown', [1200,-300,570];
    'Rotary Actuator', [2479,0,362.6];
    'Steering Angle Sensor', [1500,0,530];
    'TS Current Sensor', [2200,0,116]; %same as TS Accumulator
    'TS Temperature Sensor', [2200,0,116]; %same as TS Accumulator
    'Motor Temperature FL', [670, -600, 228.5]; %same as FL wheel
    'Motor Temperature FR', [670, 600, 228.5]; %same as FR wheel
    'Motor Temperature Rear', [2100, 50, 230]; %same as rear motor
    'EMRAX Pressure Sensor', [2460,210.5,147];
    'Front Motors Pressure Sensor', [2460,210.5,147];
    'Rear Motors Pressure Sensor', [2460,210.5,147];
    'Ground Measurement Sensor', [1500,0,180];
    % ... (Add more telemetry sensors as needed)
};

% Wire Types (Type, mass per metre, cost per metre)
wire_types = {
    'HV System', 1.15, 20;     % High Voltage Tractive System (AWG 10)
    'LV System', 0.01, 0.3;       % Low Voltage System (AWG 18)
    'Shutdown', 0.01, 0.3;       % Shutdown System (AWG 16)
    'Telemetry', 0.003, 0.2;       % Telemetry (AWG 22)
};

% Initialize total wire lengths
total_wire_lengths = containers.Map(wire_types(:,1), zeros(size(wire_types,1),1));

% Connection Logic 
connections = {
    'LV Battery', {'Power Distribution PCB'};
    'Power Distribution PCB', {'MCU','MCU Relay','Ground Measurement Sensor','EMRAX Pressure Sensor','Front Motors Pressure Sensor','Rear Motors Pressure Sensor','TS Temperature Sensor','Motor Temperature FL','Motor Temperature FR','Motor Temperature Rear', 'AMS/IMD','TS Current Sensor', 'BSPD', 'Inertia Sensor','Telemetry Microcontroller','Precharge Relay','Dashboard','Coolant Temp Sensor','Throttle Position Sensor','Brake Pressure Sensor','Speed Sensor RPM','Speed Sensor electronic','Brake Temperature Sensor FL','Brake Temperature Sensor FR','Brake Temperature Sensor RL','Brake Temperature Sensor RR','Tyre Temperature Sensor FL','Tyre Temperature Sensor FR','Tyre Temperature Sensor RL','Tyre Temperature Sensor RR','Tyre Pressure Sensor FL','Tyre Pressure Sensor FR','Tyre Pressure Sensor RL','Tyre Pressure Sensor RR','Steering Angle Sensor'};
    'Telemetry Microcontroller', {'Coolant Temp Sensor','EMRAX Pressure Sensor','Front Motors Pressure Sensor','TS Temperature Sensor','Rear Motors Pressure Sensor','Motor Temperature FL','Motor Temperature FR','Motor Temperature Rear','TS Current Sensor','Throttle Position Sensor','Brake Pressure Sensor','Dashboard','Speed Sensor RPM','Speed Sensor electronic','Brake Temperature Sensor FL','Brake Temperature Sensor FR','Brake Temperature Sensor RL','Brake Temperature Sensor RR','Tyre Temperature Sensor FL','Tyre Temperature Sensor FR','Tyre Temperature Sensor RL','Tyre Temperature Sensor RR','Tyre Pressure Sensor FL','Tyre Pressure Sensor FR','Tyre Pressure Sensor RL','Tyre Pressure Sensor RR','Steering Angle Sensor'};
    'BSPD', {'Throttle Position Sensor','Brake Pressure Sensor','AMS/IMD'};
    'AMS/IMD', {'MCU Relay','TS Temperature Sensor','TS Current Sensor','Ground Measurement Sensor'};
    'MCU Relay', {'Inertia Sensor'};
    'Inertia Sensor', {'BOTS'};
    'BOTS', {'Right Shutdown'};
    'Right Shutdown', {'Cockpit Shutdown'};
    'Cockpit Shutdown', {'Left Shutdown'};
    'Left Shutdown', {'Charger Shutdown'};
    'Charger Shutdown', {'TSMS'};
    'TSMS', {'Precharge PCB'};
    'Precharge PCB', {'HVD','Wheel FL','Wheel FR','AIR+','AIR-','Precharge Relay'};
    'AIR+',{'TS Accumulator'};
    'AIR-',{'TS Accumulator'};
    'Precharge Relay', {'AIR+','AIR-'};
    'TS Accumulator', {'HVD'};
    'HVD',{'Motor Controller Front', 'Motor Controller Rear', 'Pump 1', 'Pump 2', 'Pump 3','Rotary Actuator'};
    'MCU', {'Motor Controller Front', 'Motor Controller Rear'};
    'Motor Controller Front', {'Wheel FL', 'Wheel FR'};
    'Motor Controller Rear', {'Motor Rear'};
    % ... (Add more connections as needed)
};

% Calculate Wire Lengths
for i = 1:size(connections,1)
    source = connections{i,1};
    targets = connections{i,2};
    for j = 1:numel(targets)
        target = targets{j};
        pos1 = component_positions{strcmp(component_positions(:,1), source), 2};
        pos2 = component_positions{strcmp(component_positions(:,1), target), 2};

        % Determine wire type based on components
        wire_type = determine_wire_type(source);

        % Calculate Euclidean distance
        distance = norm(pos1 - pos2);

        % Add to total wire length for the determined type
        total_wire_lengths(wire_type) = total_wire_lengths(wire_type) + distance;
    end
end

% Display Results
for wire_type = keys(total_wire_lengths)
    fprintf('Total length of %s wire: %.2f meters\n', wire_type{1}, total_wire_lengths(wire_type{1})/1000);
end
fprintf('Total length of wire: %.2f meters\n', (total_wire_lengths(wire_types{1,1})/1000+total_wire_lengths(wire_types{2,1})/1000+total_wire_lengths(wire_types{3,1})/1000+total_wire_lengths(wire_types{4,1})/1000));
fprintf('\n')
m=1;
for wire_type = keys(total_wire_lengths)
    fprintf('Total mass of %s wire: %.2f kilograms\n', wire_type{1}, total_wire_lengths(wire_type{1})*(1/1000)*wire_types{m,2});
    m=m+1;
end
fprintf('Total mass of wire: %.2f kilograms\n', (total_wire_lengths(wire_types{1,1})*(1/1000)*wire_types{1,2}+total_wire_lengths(wire_types{2,1})*(1/1000)*wire_types{2,2}+total_wire_lengths(wire_types{3,1})*(1/1000)*wire_types{3,2}+total_wire_lengths(wire_types{4,1})*(1/1000)*wire_types{4,2}));
fprintf('\n')
c=1;
for wire_type = keys(total_wire_lengths)
    fprintf('Total cost of %s wire: £%.2f \n', wire_type{1}, total_wire_lengths(wire_type{1})*(1/1000)*wire_types{c,3});
    c=c+1;
end
fprintf('Total cost of wire: £%.2f \n', (total_wire_lengths(wire_types{1,1})*(1/1000)*wire_types{1,3}+total_wire_lengths(wire_types{2,1})*(1/1000)*wire_types{2,3}+total_wire_lengths(wire_types{3,1})*(1/1000)*wire_types{3,3}+total_wire_lengths(wire_types{4,1})*(1/1000)*wire_types{4,3}));
% end
