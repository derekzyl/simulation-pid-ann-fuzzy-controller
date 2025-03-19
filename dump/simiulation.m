% This is the Simulink model saved as 'CoolingSystem.mdl'
% Below is the MATLAB code to programmatically create this Simulink model

function createCoolingSystemModel()
    % Create a new Simulink model
    modelName = 'CoolingSystem';
    
    % Close and delete any existing model with the same name
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    if exist([modelName, '.slx'], 'file')
        delete([modelName, '.slx']);
    end
    
    % Create a new model
    new_system(modelName);
    open_system(modelName);
    
    %% Add blocks for engine load
    add_block('simulink/Sources/Step', [modelName, '/EngineLoad']);
    set_param([modelName, '/EngineLoad'], ...
        'Time', '20', ...
        'After', '50000', ...
        'Before', '0', ...
        'SampleTime', '0');
    
    %% Add reference temperature
    add_block('simulink/Sources/Constant', [modelName, '/TargetTemp']);
    set_param([modelName, '/TargetTemp'], ...
        'Value', '90', ...
        'SampleTime', '0');
    
    %% Create PID Controller subsystem
    createPIDControllerSystem(modelName);
    
    %% Create Fuzzy Logic Controller subsystem
    createFLCControllerSystem(modelName);
    
    %% Create ANN Controller subsystem
    createANNControllerSystem(modelName);
    
    %% Create Engine and Radiator Thermal Model subsystem
    createThermalModelSystem(modelName);
    
    %% Create Water Pump Model subsystem
    createWaterPumpSystem(modelName);
    
    %% Connect blocks for PID controller
    % Connect reference temp to PID
    add_line(modelName, 'TargetTemp/1', 'PIDController/1', 'autorouting', 'on');
    
    % Connect engine temperature from thermal model to PID
    add_line(modelName, 'ThermalModel/1', 'PIDController/2', 'autorouting', 'on');
    
    % Connect PID output to water pump
    add_line(modelName, 'PIDController/1', 'WaterPumpModel/1', 'autorouting', 'on');
    
    % Connect engine load to thermal model
    add_line(modelName, 'EngineLoad/1', 'ThermalModel/1', 'autorouting', 'on');
    
    % Connect pump flow rate to thermal model
    add_line(modelName, 'WaterPumpModel/1', 'ThermalModel/2', 'autorouting', 'on');
    
    %% Connect blocks for Fuzzy Logic controller
    % Connect reference temp to FLC
    add_line(modelName, 'TargetTemp/1', 'FLCController/1', 'autorouting', 'on');
    
    % Connect engine temperature from thermal model to FLC
    add_line(modelName, 'ThermalModel/1', 'FLCController/2', 'autorouting', 'on');
    
    %% Connect blocks for ANN controller
    % Connect reference temp to ANN
    add_line(modelName, 'TargetTemp/1', 'ANNController/1', 'autorouting', 'on');
    
    % Connect engine temperature from thermal model to ANN
    add_line(modelName, 'ThermalModel/1', 'ANNController/2', 'autorouting', 'on');
    
    % Connect engine load to ANN
    add_line(modelName, 'EngineLoad/1', 'ANNController/3', 'autorouting', 'on');
    
    %% Add scopes and data logging
    % Add scope for engine temperature
    add_block('simulink/Sinks/Scope', [modelName, '/TemperatureScope']);
    set_param([modelName, '/TemperatureScope'], 'NumInputPorts', '3');
    
    % Add scope for pump speed
    add_block('simulink/Sinks/Scope', [modelName, '/PumpSpeedScope']);
    set_param([modelName, '/PumpSpeedScope'], 'NumInputPorts', '3');
    
    % Add To Workspace blocks for data logging
    addToWorkspaceBlock(modelName, 'engine_temp_pid', 'ThermalModel/1');
    addToWorkspaceBlock(modelName, 'engine_temp_flc', 'ThermalModel/2');
    addToWorkspaceBlock(modelName, 'engine_temp_ann', 'ThermalModel/3');
    addToWorkspaceBlock(modelName, 'pump_speed_pid', 'WaterPumpModel/1');
    addToWorkspaceBlock(modelName, 'pump_speed_flc', 'WaterPumpModel/2');
    addToWorkspaceBlock(modelName, 'pump_speed_ann', 'WaterPumpModel/3');
    
    % Save the model
    save_system(modelName);
    
    % Display a message
    disp('Cooling System model created successfully!');
end

function createPIDControllerSystem(modelName)
    % Create the PID Controller subsystem
    pidSubsystemName = [modelName, '/PIDController'];
    add_block('simulink/Ports & Subsystems/Subsystem', pidSubsystemName);
    
    % Rename inport and outport
    delete_line(pidSubsystemName, 'In1/1', 'Out1/1');
    set_param([pidSubsystemName, '/In1'], 'Name', 'RefTemp');
    add_block('simulink/Ports & Subsystems/In1', [pidSubsystemName, '/EngineTemp']);
    set_param([pidSubsystemName, '/Out1'], 'Name', 'PumpSpeed');
    
    % Add PID Controller block
    add_block('simulink/Continuous/PID Controller', [pidSubsystemName, '/PID']);
    set_param([pidSubsystemName, '/PID'], ...
        'P', '10', ...
        'I', '0.5', ...
        'D', '1', ...
        'N', '100');
    
    % Add Sum block for error calculation
    add_block('simulink/Math Operations/Sum', [pidSubsystemName, '/Sum']);
    set_param([pidSubsystemName, '/Sum'], 'Inputs', '+-');
    
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [pidSubsystemName, '/Saturation']);
    set_param([pidSubsystemName, '/Saturation'], ...
        'UpperLimit', '100', ...
        'LowerLimit', '0');
    
    % Connect blocks
    add_line(pidSubsystemName, 'RefTemp/1', 'Sum/1', 'autorouting', 'on');
    add_line(pidSubsystemName, 'EngineTemp/1', 'Sum/2', 'autorouting', 'on');
    add_line(pidSubsystemName, 'Sum/1', 'PID/1', 'autorouting', 'on');
    add_line(pidSubsystemName, 'PID/1', 'Saturation/1', 'autorouting', 'on');
    add_line(pidSubsystemName, 'Saturation/1', 'PumpSpeed/1', 'autorouting', 'on');
end

function createFLCControllerSystem(modelName)
    % Create the Fuzzy Logic Controller subsystem
    flcSubsystemName = [modelName, '/FLCController'];
    add_block('simulink/Ports & Subsystems/Subsystem', flcSubsystemName);
    
    % Rename inport and outport
    delete_line(flcSubsystemName, 'In1/1', 'Out1/1');
    set_param([flcSubsystemName, '/In1'], 'Name', 'RefTemp');
    add_block('simulink/Ports & Subsystems/In1', [flcSubsystemName, '/EngineTemp']);
    set_param([flcSubsystemName, '/Out1'], 'Name', 'PumpSpeed');
    
    % Add Sum block for error calculation
    add_block('simulink/Math Operations/Sum', [flcSubsystemName, '/Sum']);
    set_param([flcSubsystemName, '/Sum'], 'Inputs', '+-');
    
    % Add Derivative block for error rate
    add_block('simulink/Continuous/Derivative', [flcSubsystemName, '/Derivative']);
    
    % Add Fuzzy Logic Controller block
    add_block('fuzzy/Fuzzy Logic Controller', [flcSubsystemName, '/FLC']);
    set_param([flcSubsystemName, '/FLC'], 'FIS', 'flc');
    
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [flcSubsystemName, '/Saturation']);
    set_param([flcSubsystemName, '/Saturation'], ...
        'UpperLimit', '100', ...
        'LowerLimit', '0');
    
    % Connect blocks
    add_line(flcSubsystemName, 'RefTemp/1', 'Sum/1', 'autorouting', 'on');
    add_line(flcSubsystemName, 'EngineTemp/1', 'Sum/2', 'autorouting', 'on');
    add_line(flcSubsystemName, 'Sum/1', 'FLC/1', 'autorouting', 'on');
    add_line(flcSubsystemName, 'Sum/1', 'Derivative/1', 'autorouting', 'on');
    add_line(flcSubsystemName, 'Derivative/1', 'FLC/2', 'autorouting', 'on');
    add_line(flcSubsystemName, 'FLC/1', 'Saturation/1', 'autorouting', 'on');
    add_line(flcSubsystemName, 'Saturation/1', 'PumpSpeed/1', 'autorouting', 'on');
end

function createANNControllerSystem(modelName)
    % Create the ANN Controller subsystem
    annSubsystemName = [modelName, '/ANNController'];
    add_block('simulink/Ports & Subsystems/Subsystem', annSubsystemName);
    
    % Rename inport and outport
    delete_line(annSubsystemName, 'In1/1', 'Out1/1');
    set_param([annSubsystemName, '/In1'], 'Name', 'RefTemp');
    add_block('simulink/Ports & Subsystems/In1', [annSubsystemName, '/EngineTemp']);
    add_block('simulink/Ports & Subsystems/In1', [annSubsystemName, '/EngineLoad']);
    set_param([annSubsystemName, '/Out1'], 'Name', 'PumpSpeed');
    
    % Add Sum block for error calculation
    add_block('simulink/Math Operations/Sum', [annSubsystemName, '/Sum']);
    set_param([annSubsystemName, '/Sum'], 'Inputs', '+-');
    
    % Add Derivative block for error rate
    add_block('simulink/Continuous/Derivative', [annSubsystemName, '/Derivative']);
    
    % Add Neural Network block
    add_block('simulink/Neural Network/Neural Network Predictive Controller', [annSubsystemName, '/ANN']);
    
    % Add Mux to combine inputs
    add_block('simulink/Signal Routing/Mux', [annSubsystemName, '/Mux']);
    set_param([annSubsystemName, '/Mux'], 'Inputs', '3');
    
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [annSubsystemName, '/Saturation']);
    set_param([annSubsystemName, '/Saturation'], ...
        'UpperLimit', '100', ...
        'LowerLimit', '0');
    
    % Connect blocks
    add_line(annSubsystemName, 'RefTemp/1', 'Sum/1', 'autorouting', 'on');
    add_line(annSubsystemName, 'EngineTemp/1', 'Sum/2', 'autorouting', 'on');
    add_line(annSubsystemName, 'Sum/1', 'Mux/1', 'autorouting', 'on');
    add_line(annSubsystemName, 'Sum/1', 'Derivative/1', 'autorouting', 'on');
    add_line(annSubsystemName, 'Derivative/1', 'Mux/2', 'autorouting', 'on');
    add_line(annSubsystemName, 'EngineLoad/1', 'Mux/3', 'autorouting', 'on');
    add_line(annSubsystemName, 'Mux/1', 'ANN/1', 'autorouting', 'on');
    add_line(annSubsystemName, 'ANN/1', 'Saturation/1', 'autorouting', 'on');
    add_line(annSubsystemName, 'Saturation/1', 'PumpSpeed/1', 'autorouting', 'on');
end

function createThermalModelSystem(modelName)
    % Create the Thermal Model subsystem
    thermalSubsystemName = [modelName, '/ThermalModel'];
    add_block('simulink/Ports & Subsystems/Subsystem', thermalSubsystemName);
    
    % Rename inport and outport
    delete_line(thermalSubsystemName, 'In1/1', 'Out1/1');
    set_param([thermalSubsystemName, '/In1'], 'Name', 'EngineLoad');
    add_block('simulink/Ports & Subsystems/In1', [thermalSubsystemName, '/PumpFlow']);
    set_param([thermalSubsystemName, '/Out1'], 'Name', 'EngineTemp');
    
    % Add Constant block for ambient temperature
    add_block('simulink/Sources/Constant', [thermalSubsystemName, '/AmbientTemp']);
    set_param([thermalSubsystemName, '/AmbientTemp'], 'Value', '25');
    
    % Add Transfer Function block for engine thermal dynamics
    add_block('simulink/Continuous/Transfer Fcn', [thermalSubsystemName, '/EngineThermalModel']);
    set_param([thermalSubsystemName, '/EngineThermalModel'], ...
        'Numerator', '1', ...
        'Denominator', '[5000 1]');
    
    % Add Product block for cooling effect
    add_block('simulink/Math Operations/Product', [thermalSubsystemName, '/CoolingEffect']);
    
    % Add Gain block for cooling capacity
    add_block('simulink/Math Operations/Gain', [thermalSubsystemName, '/CoolingCapacity']);
    set_param([thermalSubsystemName, '/CoolingCapacity'], 'Gain', '500');
    
    % Add Sum block for net heat flow
    add_block('simulink/Math Operations/Sum', [thermalSubsystemName, '/NetHeatFlow']);
    set_param([thermalSubsystemName, '/NetHeatFlow'], 'Inputs', '+-');
    
    % Add Sum block for temperature rise
    add_block('simulink/Math Operations/Sum', [thermalSubsystemName, '/TotalTemp']);
    set_param([thermalSubsystemName, '/TotalTemp'], 'Inputs', '++');
    
    % Connect blocks
    add_line(thermalSubsystemName, 'EngineLoad/1', 'NetHeatFlow/1', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'PumpFlow/1', 'CoolingCapacity/1', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'CoolingCapacity/1', 'CoolingEffect/1', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'EngineTemp/1', 'CoolingEffect/2', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'CoolingEffect/1', 'NetHeatFlow/2', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'NetHeatFlow/1', 'EngineThermalModel/1', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'EngineThermalModel/1', 'TotalTemp/1', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'AmbientTemp/1', 'TotalTemp/2', 'autorouting', 'on');
    add_line(thermalSubsystemName, 'TotalTemp/1', 'EngineTemp/1', 'autorouting', 'on');
end

function createWaterPumpSystem(modelName)
    % Create the Water Pump subsystem
    pumpSubsystemName = [modelName, '/WaterPumpModel'];
    add_block('simulink/Ports & Subsystems/Subsystem', pumpSubsystemName);
    
    % Rename inport and outport
    delete_line(pumpSubsystemName, 'In1/1', 'Out1/1');
    set_param([pumpSubsystemName, '/In1'], 'Name', 'PumpSpeedCommand');
    set_param([pumpSubsystemName, '/Out1'], 'Name', 'FlowRate');
    
    % Add Transfer Function block for pump dynamics
    add_block('simulink/Continuous/Transfer Fcn', [pumpSubsystemName, '/PumpDynamics']);
    set_param([pumpSubsystemName, '/PumpDynamics'], ...
        'Numerator', '0.8', ...
        'Denominator', '[0.5 1]');
    
    % Add Gain block for flow conversion
    add_block('simulink/Math Operations/Gain', [pumpSubsystemName, '/FlowConversion']);
    set_param([pumpSubsystemName, '/FlowConversion'], 'Gain', '0.01');
    
    % Connect blocks
    add_line(pumpSubsystemName, 'PumpSpeedCommand/1', 'PumpDynamics/1', 'autorouting', 'on');
    add_line(pumpSubsystemName, 'PumpDynamics/1', 'FlowConversion/1', 'autorouting', 'on');
    add_line(pumpSubsystemName, 'FlowConversion/1', 'FlowRate/1', 'autorouting', 'on');
end

function addToWorkspaceBlock(modelName, variableName, sourceBlockPort)
    % Add To Workspace block
    add_block('simulink/Sinks/To Workspace', [modelName, '/', variableName]);
    set_param([modelName, '/', variableName], ...
        'VariableName', variableName, ...
        'SampleTime', '-1');
    
    % Connect the block to the source
    add_line(modelName, sourceBlockPort, [variableName, '/1'], 'autorouting', 'on');
end