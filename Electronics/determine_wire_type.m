function wire_type = determine_wire_type(component1)
    if contains(component1, 'LV Battery') || contains(component1, 'Power Distribution PCB')
        wire_type = 'LV System';
    elseif contains(component1, 'TS Accumulator') || contains(component1, 'Motor Controller Front') || contains(component1, 'Motor Controller Rear') || contains(component1, 'HVD')
        wire_type = 'HV System'; 
    elseif contains(component1, 'Precharge PCB') || contains(component1, 'BSPD') || contains(component1, 'MCU Relay')
        wire_type = 'Shutdown';
    elseif contains(component1, 'Telemetry Microcontroller')
        wire_type = 'Telemetry'; 
    else 
        wire_type = 'Shutdown'; % Default to shutdown for other connections
    end
end