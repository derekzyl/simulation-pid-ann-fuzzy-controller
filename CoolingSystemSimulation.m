function buildCoolingSystemSimulinkModel()
    % Creates a Simulink model for the automotive cooling system with
    % PID, Fuzzy Logic, and ANN controllers
    
    % Create a new Simulink model
    modelName = 'CoolingSystemComparison';
    
    % Close and delete any existing model with the same name
    if bdIsLoaded(modelName)
        close_system(modelName, 0);
    end
    if exist([modelName '.slx'], 'file')
        delete([modelName '.slx']);
    end
    
    % Create a new model
    new_system(modelName);
    open_system(modelName);
    
    % Set simulation parameters
    set_param(modelName, 'StopTime', '600');
    set_param(modelName, 'FixedStep', '0.1');
    set_param(modelName, 'SolverType', 'Fixed-step');
    set_param(modelName, 'Solver', 'ode4');
    
    %% Create the main subsystems
    
    % Add Input Signals subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Input Signals']);
    buildInputSignalsSubsystem(modelName);
    
    % Add System Parameters subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/System Parameters']);
    buildSystemParametersSubsystem(modelName);
    
    % Add Engine & Cooling System subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Engine & Cooling System (PID)']);
    buildEngineCoolingSystemSubsystem(modelName, 'PID');
    
    % Add Engine & Cooling System subsystem for Fuzzy controller
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Engine & Cooling System (Fuzzy)']);
    buildEngineCoolingSystemSubsystem(modelName, 'Fuzzy');
    
    % Add Engine & Cooling System subsystem for ANN controller
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Engine & Cooling System (ANN)']);
    buildEngineCoolingSystemSubsystem(modelName, 'ANN');
    
    % Add PID Controller subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/PID Controller']);
    buildPIDControllerSubsystem(modelName);
    
    % Add Fuzzy Controller subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Fuzzy Controller']);
    buildFuzzyControllerSubsystem(modelName);
    
    % Add ANN Controller subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/ANN Controller']);
    buildANNControllerSubsystem(modelName);
    
    % Add Performance Metrics subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Performance Metrics']);
    buildPerformanceMetricsSubsystem(modelName);
    
    %% Connect the subsystems
    
    % Connect Input Signals to Controllers
    add_line(modelName, 'Input Signals/1', 'Engine & Cooling System (PID)/4', 'autorouting', 'on');  % Load profile
    add_line(modelName, 'Input Signals/2', 'Engine & Cooling System (PID)/5', 'autorouting', 'on');  % Ambient temperature
    
    add_line(modelName, 'Input Signals/1', 'Engine & Cooling System (Fuzzy)/4', 'autorouting', 'on');  % Load profile
    add_line(modelName, 'Input Signals/2', 'Engine & Cooling System (Fuzzy)/5', 'autorouting', 'on');  % Ambient temperature
    
    add_line(modelName, 'Input Signals/1', 'Engine & Cooling System (ANN)/4', 'autorouting', 'on');  % Load profile
    add_line(modelName, 'Input Signals/2', 'Engine & Cooling System (ANN)/5', 'autorouting', 'on');  % Ambient temperature
    
    % Connect System Parameters to Engine & Cooling System
    add_line(modelName, 'System Parameters/1', 'Engine & Cooling System (PID)/3', 'autorouting', 'on');
    add_line(modelName, 'System Parameters/1', 'Engine & Cooling System (Fuzzy)/3', 'autorouting', 'on');
    add_line(modelName, 'System Parameters/1', 'Engine & Cooling System (ANN)/3', 'autorouting', 'on');
    
    % Connect Engine temperature to Controllers
    add_line(modelName, 'Engine & Cooling System (PID)/1', 'PID Controller/1', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (Fuzzy)/1', 'Fuzzy Controller/1', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (ANN)/1', 'ANN Controller/1', 'autorouting', 'on');
    
    % Connect System Parameters to Controllers (for optimal temperature)
    add_line(modelName, 'System Parameters/2', 'PID Controller/2', 'autorouting', 'on');
    add_line(modelName, 'System Parameters/2', 'Fuzzy Controller/2', 'autorouting', 'on');
    
    % Connect ANN controller's additional inputs
    add_line(modelName, 'Input Signals/1', 'ANN Controller/3', 'autorouting', 'on');  % Load profile
    add_line(modelName, 'Input Signals/2', 'ANN Controller/4', 'autorouting', 'on');  % Ambient temperature
    
    % Connect Controllers to Engine & Cooling System
    add_line(modelName, 'PID Controller/1', 'Engine & Cooling System (PID)/2', 'autorouting', 'on');
    add_line(modelName, 'Fuzzy Controller/1', 'Engine & Cooling System (Fuzzy)/2', 'autorouting', 'on');
    add_line(modelName, 'ANN Controller/1', 'Engine & Cooling System (ANN)/2', 'autorouting', 'on');
    
    % Connect outputs to Performance Metrics
    add_line(modelName, 'Engine & Cooling System (PID)/1', 'Performance Metrics/1', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (Fuzzy)/1', 'Performance Metrics/2', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (ANN)/1', 'Performance Metrics/3', 'autorouting', 'on');
    
    add_line(modelName, 'Engine & Cooling System (PID)/2', 'Performance Metrics/4', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (Fuzzy)/2', 'Performance Metrics/5', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (ANN)/2', 'Performance Metrics/6', 'autorouting', 'on');
    
    add_line(modelName, 'System Parameters/2', 'Performance Metrics/7', 'autorouting', 'on');
    
    % Add Scopes for visualization
    add_block('simulink/Sinks/Scope', [modelName '/Temperature Scope']);
    set_param([modelName '/Temperature Scope'], 'NumInputPorts', '3');
    
    add_block('simulink/Sinks/Scope', [modelName '/Control Signal Scope']);
    set_param([modelName '/Control Signal Scope'], 'NumInputPorts', '3');
    
    add_block('simulink/Sinks/Scope', [modelName '/Power Consumption Scope']);
    set_param([modelName '/Power Consumption Scope'], 'NumInputPorts', '3');
    
    % Connect outputs to scopes
    add_line(modelName, 'Engine & Cooling System (PID)/1', 'Temperature Scope/1', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (Fuzzy)/1', 'Temperature Scope/2', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (ANN)/1', 'Temperature Scope/3', 'autorouting', 'on');
    
    add_line(modelName, 'PID Controller/1', 'Control Signal Scope/1', 'autorouting', 'on');
    add_line(modelName, 'Fuzzy Controller/1', 'Control Signal Scope/2', 'autorouting', 'on');
    add_line(modelName, 'ANN Controller/1', 'Control Signal Scope/3', 'autorouting', 'on');
    
    add_line(modelName, 'Engine & Cooling System (PID)/2', 'Power Consumption Scope/1', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (Fuzzy)/2', 'Power Consumption Scope/2', 'autorouting', 'on');
    add_line(modelName, 'Engine & Cooling System (ANN)/2', 'Power Consumption Scope/3', 'autorouting', 'on');
    
    % Position the blocks
    positionBlocks(modelName);
    
    % Save the model
    save_system(modelName);
    
    fprintf('Simulink model "%s" has been created successfully.\n', modelName);
end

%% Helper functions to build each subsystem
%% Helper functions to build each subsystem
function buildInputSignalsSubsystem(modelName)
    subsystemPath = [modelName '/Input Signals'];

    % Delete default blocks
    try
        delete_line(subsystemPath, 'In1/1', 'Out1/1');
        delete_block([subsystemPath '/In1']);
        delete_block([subsystemPath '/Out1']);
    catch ME
        disp(['Warning: Default blocks not found or already deleted. ' ME.message]);
    end

    % Add output ports
    add_block('simulink/Ports & Subsystems/Out1', [subsystemPath '/Load Profile']);
    add_block('simulink/Ports & Subsystems/Out1', [subsystemPath '/Ambient Temperature']);

    % Add time source
    add_block('simulink/Sources/Clock', [subsystemPath '/Clock']);

    % Add MATLAB Function blocks
    load_profile_block = [subsystemPath '/Load Profile Generator'];
    temp_profile_block = [subsystemPath '/Ambient Temp Generator'];
    
    add_block('simulink/User-Defined Functions/MATLAB Function', load_profile_block);
    set_param(load_profile_block, 'Position', [200, 50, 300, 100]);
    
    add_block('simulink/User-Defined Functions/MATLAB Function', temp_profile_block);
    set_param(temp_profile_block, 'Position', [200, 150, 300, 200]);

    % Connect blocks
    add_line(subsystemPath, 'Clock/1', 'Load Profile Generator/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Clock/1', 'Ambient Temp Generator/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Load Profile Generator/1', 'Load Profile/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Ambient Temp Generator/1', 'Ambient Temperature/1', 'autorouting', 'on');

    % Set up the MATLAB Function for load profile
    loadProfileFcn = ['function load = fcn(t)\n',...
        '    % Default load\n',...
        '    load = 1.0;\n',...
        '    \n',...
        '    % Higher load (150%)\n',...
        '    if t >= 100 && t < 200\n',...
        '        load = 1.5;\n',...
        '    end\n',...
        '    \n',...
        '    % Lower load (70%)\n',...
        '    if t >= 300 && t < 400\n',...
        '        load = 0.7;\n',...
        '    end\n',...
        '    \n',...
        '    % Very high load (180%)\n',...
        '    if t >= 500 && t < 550\n',...
        '        load = 1.8;\n',...
        '    end\n',...
        'end'];

    ambientTempFcn = ['function temp = fcn(t)\n',...
        '    % Default ambient temperature\n',...
        '    base_temp = 25;\n',...
        '    temp = base_temp;\n',...
        '    \n',...
        '    % Hot day scenario\n',...
        '    if t >= 200 && t < 350\n',...
        '        temp = base_temp + 15;\n',...
        '    end\n',...
        '    \n',...
        '    % Cold day scenario\n',...
        '    if t >= 450 && t < 550\n',...
        '        temp = base_temp - 10;\n',...
        '    end\n',...
        'end'];

    % Set the MATLAB Function content using the correct approach
    try
        % Find the actual MATLAB Function block inside the container
        load_fcn_block = find_system(load_profile_block, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'BlockType', 'SubSystem');
        temp_fcn_block = find_system(temp_profile_block, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'BlockType', 'SubSystem');
        
        % Alternative 1: Use Simulink.ModelWorkspace to set the function content
        % This is safer as it directly modifies the model
        model_ws = get_param(modelName, 'ModelWorkspace');
        
        % For Load Profile
        set_param(load_profile_block, 'UserData', struct('functionText', loadProfileFcn));
        % For Ambient Temperature
        set_param(temp_profile_block, 'UserData', struct('functionText', ambientTempFcn));
        
        % Open and close the blocks to apply the changes
        open_system(load_profile_block);
        pause(1);
        close_system(load_profile_block);
        
        open_system(temp_profile_block);
        pause(1);
        close_system(temp_profile_block);
        
    catch ME
        disp(['Error setting MATLAB Function parameters: ' ME.message]);
        rethrow(ME);
    end
end


function buildSystemParametersSubsystem(modelName)
    subsystemPath = [modelName '/System Parameters'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add output ports
    add_block('simulink/Ports & Subsystems/Out1', [subsystemPath '/System Parameters']);
    add_block('simulink/Ports & Subsystems/Out1', [subsystemPath '/Optimal Temperature']);
    
    % Add Constant block for optimal temperature
    add_block('simulink/Sources/Constant', [subsystemPath '/Optimal Temp']);
    set_param([subsystemPath '/Optimal Temp'], 'Value', '90');
    
    % Add MATLAB Function block for parameters
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Parameters Setup']);
    
    % Connect blocks
    add_line(subsystemPath, 'Parameters Setup/1', 'System Parameters/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Optimal Temp/1', 'Optimal Temperature/1', 'autorouting', 'on');
    
    % Set up the MATLAB Function for parameters
    paramsFcn = ['function params = fcn()\n',...
        '    % Engine and cooling system parameters\n',...
        '    params = struct();\n',...
        '    params.engine.mass = 150;                  % Engine mass (kg)\n',...
        '    params.engine.specific_heat = 450;         % Specific heat capacity of engine material (J/kg·K)\n',...
        '    params.engine.heat_generation_nom = 30000; % Nominal heat generation rate (W)\n',...
        '    params.engine.optimal_temp = 90;           % Optimal engine temperature (°C)\n',...
        '    params.engine.max_temp = 110;              % Maximum allowable engine temperature (°C)\n',...
        '    params.engine.ambient_temp = 25;           % Ambient temperature (°C)\n',...
        '    \n',...
        '    % Water pump parameters\n',...
        '    params.pump.max_flow_rate = 2.5;           % Maximum flow rate (kg/s)\n',...
        '    params.pump.min_flow_rate = 0.2;           % Minimum flow rate (kg/s)\n',...
        '    params.pump.max_speed = 3000;              % Maximum pump speed (RPM)\n',...
        '    params.pump.time_constant = 0.5;           % Pump response time constant (s)\n',...
        '    \n',...
        '    % Radiator parameters\n',...
        '    params.radiator.efficiency = 0.85;         % Radiator heat transfer efficiency\n',...
        '    params.radiator.heat_transfer_coeff = 800; % Heat transfer coefficient (W/K)\n',...
        '    \n',...
        '    % Coolant parameters\n',...
        '    params.coolant.density = 1000;             % Coolant density (kg/m³)\n',...
        '    params.coolant.specific_heat = 4186;       % Specific heat capacity of coolant (J/kg·K)\n',...
        '    params.coolant.volume = 5;                 % Coolant volume in system (L)\n',...
        'end'];
    
    % Set the MATLAB Function content
    set_param([subsystemPath '/Parameters Setup'], 'Script', paramsFcn);
end

function buildEngineCoolingSystemSubsystem(modelName, controllerType)
    subsystemPath = [modelName '/Engine & Cooling System (' controllerType ')'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add input ports
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Engine Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Pump Speed']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Parameters']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Load Profile']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Ambient Temperature']);
    
    % Add output ports
    add_block('simulink/Ports & Subsystems/Out Port', [subsystemPath '/Engine Temperature Out']);
    add_block('simulink/Ports & Subsystems/Out Port', [subsystemPath '/Power Consumption']);
    
    % Add integrator for engine temperature
    add_block('simulink/Continuous/Integrator', [subsystemPath '/Engine Temperature Integrator']);
    set_param([subsystemPath '/Engine Temperature Integrator'], 'InitialCondition', '25');
    
    % Add integrator for coolant temperature
    add_block('simulink/Continuous/Integrator', [subsystemPath '/Coolant Temperature Integrator']);
    set_param([subsystemPath '/Coolant Temperature Integrator'], 'InitialCondition', '25');
    
    % Add MATLAB Function block for engine dynamics
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Engine Dynamics']);
    
    % Add MATLAB Function block for coolant dynamics
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Coolant Dynamics']);
    
    % Add MATLAB Function block for pump dynamics
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Pump Dynamics']);
    
    % Add MATLAB Function block for power consumption
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Power Consumption']);
    
    % Connect blocks
    add_line(subsystemPath, 'Engine Temperature Integrator/1', 'Engine Temperature Out/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Engine Temperature Integrator/1', 'Engine Temperature/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Engine Temperature Integrator/1', 'Engine Dynamics/1', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Coolant Temperature Integrator/1', 'Coolant Dynamics/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Coolant Temperature Integrator/1', 'Engine Dynamics/2', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Pump Speed/1', 'Pump Dynamics/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Pump Dynamics/1', 'Engine Dynamics/3', 'autorouting', 'on');
    add_line(subsystemPath, 'Pump Dynamics/1', 'Coolant Dynamics/2', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Parameters/1', 'Engine Dynamics/4', 'autorouting', 'on');
    add_line(subsystemPath, 'Parameters/1', 'Coolant Dynamics/3', 'autorouting', 'on');
    add_line(subsystemPath, 'Parameters/1', 'Pump Dynamics/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Parameters/1', 'Power Consumption/2', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Load Profile/1', 'Engine Dynamics/5', 'autorouting', 'on');
    add_line(subsystemPath, 'Ambient Temperature/1', 'Engine Dynamics/6', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Engine Dynamics/1', 'Engine Temperature Integrator/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Coolant Dynamics/1', 'Coolant Temperature Integrator/1', 'autorouting', 'on');
    
    add_line(subsystemPath, 'Pump Speed/1', 'Power Consumption/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Power Consumption/1', 'Power Consumption/1', 'autorouting', 'on');
    
    % Set up the MATLAB Function for engine dynamics
    engineDynamicsFcn = ['function dT_engine = fcn(T_engine, T_coolant, flow_rate, params, load, ambient_temp)\n',...
        '    % Parse parameters\n',...
        '    engine_mass = params.engine.mass;\n',...
        '    engine_specific_heat = params.engine.specific_heat;\n',...
        '    heat_generation_nom = params.engine.heat_generation_nom;\n',...
        '    radiator_efficiency = params.radiator.efficiency;\n',...
        '    heat_transfer_coeff = params.radiator.heat_transfer_coeff;\n',...
        '    \n',...
        '    % Calculate heat generated\n',...
        '    heat_gen = heat_generation_nom * load;\n',...
        '    \n',...
        '    % Calculate heat dissipated\n',...
        '    heat_diss = heat_transfer_coeff * (T_coolant - ambient_temp) * flow_rate * radiator_efficiency;\n',...
        '    heat_diss = max(0, heat_diss); % Cannot be negative\n',...
        '    \n',...
        '    % Calculate engine temperature change\n',...
        '    dT_engine = (heat_gen - heat_diss * radiator_efficiency) / (engine_mass * engine_specific_heat);\n',...
        'end'];
    
    coolantDynamicsFcn = ['function dT_coolant = fcn(T_coolant, flow_rate, params)\n',...
        '    % Parse parameters\n',...
        '    coolant_density = params.coolant.density;\n',...
        '    coolant_volume = params.coolant.volume;\n',...
        '    coolant_specific_heat = params.coolant.specific_heat;\n',...
        '    \n',...
        '    % Calculate coolant temperature change\n',...
        '    % This is a simplified model - in reality, this would depend on heat exchange with engine\n',...
        '    coolant_heat_absorbed = 0; % This would be calculated based on engine heat and radiator dissipation\n',...
        '    \n',...
        '    dT_coolant = coolant_heat_absorbed / (coolant_density * coolant_volume * 0.001 * coolant_specific_heat);\n',...
        'end'];
    
    pumpDynamicsFcn = ['function flow_rate = fcn(pump_speed, params)\n',...
        '    % Parse parameters\n',...
        '    max_flow_rate = params.pump.max_flow_rate;\n',...
        '    max_speed = params.pump.max_speed;\n',...
        '    \n',...
        '    % Calculate flow rate from pump speed\n',...
        '    flow_rate_target = (pump_speed / max_speed) * max_flow_rate;\n',...
        '    \n',...
        '    % In a more complex model, we would apply pump dynamics here\n',...
        '    flow_rate = flow_rate_target;\n',...
        'end'];
    
    powerConsumptionFcn = ['function power = fcn(pump_speed, params)\n',...
        '    % Parse parameters\n',...
        '    max_speed = params.pump.max_speed;\n',...
        '    \n',...
        '    % Calculate power consumption (proportional to cube of speed)\n',...
        '    power = 0.001 * (pump_speed / max_speed)^3 * 1000; % In kW\n',...
        'end'];
    
    % Set the MATLAB Function content
    set_param([subsystemPath '/Engine Dynamics'], 'FunctionName', 'fcn');
    set_param([subsystemPath '/Engine Dynamics'], 'FunctionContents', engineDynamicsFcn);
    set_param([subsystemPath '/Coolant Dynamics'], 'FunctionName', 'fcn');
    set_param([subsystemPath '/Coolant Dynamics'], 'FunctionContents', coolantDynamicsFcn);
    set_param([subsystemPath '/Pump Dynamics'], 'FunctionName', 'fcn');
    set_param([subsystemPath '/Pump Dynamics'], 'FunctionContents', pumpDynamicsFcn);
    set_param([subsystemPath '/Power Consumption'], 'FunctionName', 'fcn');
    set_param([subsystemPath '/Power Consumption'], 'FunctionContents', powerConsumptionFcn);
end

function buildPIDControllerSubsystem(modelName)
    subsystemPath = [modelName '/PID Controller'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add input ports
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Engine Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Optimal Temperature']);
    
    % Add output port
    add_block('simulink/Ports & Subsystems/Out Port', [subsystemPath '/Pump Speed']);
    
    % Add PID Controller block
    add_block('simulink/Continuous/PID Controller', [subsystemPath '/PID']);
    set_param([subsystemPath '/PID'], 'P', '150');
    set_param([subsystemPath '/PID'], 'I', '15');
    set_param([subsystemPath '/PID'], 'D', '10');
    
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [subsystemPath '/Pump Speed Limiter']);
    set_param([subsystemPath '/Pump Speed Limiter'], 'UpperLimit', '3000');
    set_param([subsystemPath '/Pump Speed Limiter'], 'LowerLimit', '0');
    
    % Add Sum block for error calculation
    add_block('simulink/Math Operations/Sum', [subsystemPath '/Error']);
    set_param([subsystemPath '/Error'], 'Inputs', '+-');
    
    % Connect blocks
    add_line(subsystemPath, 'Optimal Temperature/1', 'Error/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Engine Temperature/1', 'Error/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Error/1', 'PID/1', 'autorouting', 'on');
    add_line(subsystemPath, 'PID/1', 'Pump Speed Limiter/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Pump Speed Limiter/1', 'Pump Speed/1', 'autorouting', 'on');
end

function buildFuzzyControllerSubsystem(modelName)
    subsystemPath = [modelName '/Fuzzy Controller'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add input ports
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Engine Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Optimal Temperature']);
    
    % Add output port
    add_block('simulink/Ports & Subsystems/Out Port', [subsystemPath '/Pump Speed']);
    
    % Add unit delay for calculating error rate
    add_block('simulink/Discrete/Unit Delay', [subsystemPath '/Previous Temperature']);
    set_param([subsystemPath '/Previous Temperature'], 'InitialCondition', '25');
    
    % Add Sum blocks for error calculation
    add_block('simulink/Math Operations/Sum', [subsystemPath '/Error']);
    set_param([subsystemPath '/Error'], 'Inputs', '+-');
    
    add_block('simulink/Math Operations/Sum', [subsystemPath '/Previous Error']);
    set_param([subsystemPath '/Previous Error'], 'Inputs', '+-');
    
    % Add Fuzzy Logic Controller block
    add_block('simulink/Fuzzy Logic Toolbox/Fuzzy Logic Controller', [subsystemPath '/Fuzzy Controller']);
    
    % Add Gain block to scale output to pump speed
    add_block('simulink/Math Operations/Gain', [subsystemPath '/Scale to Pump Speed']);
    set_param([subsystemPath '/Scale to Pump Speed'], 'Gain', '3000');
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [subsystemPath '/Pump Speed Limiter']);
    set_param([subsystemPath '/Pump Speed Limiter'], 'UpperLimit', '3000');
    set_param([subsystemPath '/Pump Speed Limiter'], 'LowerLimit', '0');
    
    % Connect blocks
    add_line(subsystemPath, 'Optimal Temperature/1', 'Error/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Engine Temperature/1', 'Error/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Optimal Temperature/1', 'Previous Error/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Previous Temperature/1', 'Previous Error/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Engine Temperature/1', 'Previous Temperature/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Error/1', 'Fuzzy Controller/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Previous Error/1', 'Fuzzy Controller/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Fuzzy Controller/1', 'Scale to Pump Speed/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Scale to Pump Speed/1', 'Pump Speed Limiter/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Pump Speed Limiter/1', 'Pump Speed/1', 'autorouting', 'on');
    
    % Create and set Fuzzy Logic Controller
    fis = createFuzzySystem();
    writeFIS(fis, 'cooling_system_fis');
    set_param([subsystemPath '/Fuzzy Controller'], 'FISFile', 'cooling_system_fis');
end

function buildANNControllerSubsystem(modelName)
    subsystemPath = [modelName '/ANN Controller'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add input ports
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Engine Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Optimal Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Load Profile']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Ambient Temperature']);
    
    % Add output port
    add_block('simulink/Ports & Subsystems/Out Port', [subsystemPath '/Pump Speed']);
    
    % Add Neural Network block
    add_block('simulink/Neural Network Toolbox/Neural Network Predictors/Neural Network Predictors with Two Inputs', ...
        [subsystemPath '/ANN Model']);
    
    % Add Saturation block to limit pump speed
    add_block('simulink/Discontinuities/Saturation', [subsystemPath '/Pump Speed Limiter']);
    set_param([subsystemPath '/Pump Speed Limiter'], 'UpperLimit', '3000');
    set_param([subsystemPath '/Pump Speed Limiter'], 'LowerLimit', '0');
    
    % Add Mux block for all inputs
    add_block('simulink/Signal Routing/Mux', [subsystemPath '/Mux']);
    set_param([subsystemPath '/Mux'], 'Inputs', '4');
    
    % Connect blocks
    add_line(subsystemPath, 'Engine Temperature/1', 'Mux/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Optimal Temperature/1', 'Mux/2', 'autorouting', 'on');
    add_line(subsystemPath, 'Load Profile/1', 'Mux/3', 'autorouting', 'on');
    add_line(subsystemPath, 'Ambient Temperature/1', 'Mux/4', 'autorouting', 'on');
    add_line(subsystemPath, 'Mux/1', 'ANN Model/1', 'autorouting', 'on');
    add_line(subsystemPath, 'ANN Model/1', 'Pump Speed Limiter/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Pump Speed Limiter/1', 'Pump Speed/1', 'autorouting', 'on');
end

function buildPerformanceMetricsSubsystem(modelName)
    subsystemPath = [modelName '/Performance Metrics'];
    
    % Delete default blocks
    delete_line(subsystemPath, 'In1/1', 'Out1/1');
    delete_block([subsystemPath '/In1']);
    delete_block([subsystemPath '/Out1']);
    
    % Add input ports
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/PID Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Fuzzy Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/ANN Temperature']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/PID Power']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Fuzzy Power']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/ANN Power']);
    add_block('simulink/Ports & Subsystems/In Port', [subsystemPath '/Optimal Temperature']);
    
    % Add MATLAB Function block for metrics calculation
    add_block('simulink/User-Defined Functions/MATLAB Function', [subsystemPath '/Calculate Metrics']);
    
    % Add To Workspace blocks to save data for post-processing
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/PID Temp Data']);
    set_param([subsystemPath '/PID Temp Data'], 'VariableName', 'T_engine_pid');
    set_param([subsystemPath '/PID Temp Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/Fuzzy Temp Data']);
    set_param([subsystemPath '/Fuzzy Temp Data'], 'VariableName', 'T_engine_fuzzy');
    set_param([subsystemPath '/Fuzzy Temp Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/ANN Temp Data']);
    set_param([subsystemPath '/ANN Temp Data'], 'VariableName', 'T_engine_ann');
    set_param([subsystemPath '/ANN Temp Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/PID Power Data']);
    set_param([subsystemPath '/PID Power Data'], 'VariableName', 'power_consumption_pid');
    set_param([subsystemPath '/PID Power Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/Fuzzy Power Data']);
    set_param([subsystemPath '/Fuzzy Power Data'], 'VariableName', 'power_consumption_fuzzy');
    set_param([subsystemPath '/Fuzzy Power Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/ANN Power Data']);
    set_param([subsystemPath '/ANN Power Data'], 'VariableName', 'power_consumption_ann');
    set_param([subsystemPath '/ANN Power Data'], 'SaveFormat', 'Array');
    
    add_block('simulink/Sinks/To Workspace', [subsystemPath '/Time Data']);
    set_param([subsystemPath '/Time Data'], 'VariableName', 'time');
    set_param([subsystemPath '/Time Data'], 'SaveFormat', 'Array');
    
    % Add Clock for time data
    add_block('simulink/Sources/Clock', [subsystemPath '/Clock']);
    
    % Connect blocks
    add_line(subsystemPath, 'PID Temperature/1', 'PID Temp Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Fuzzy Temperature/1', 'Fuzzy Temp Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'ANN Temperature/1', 'ANN Temp Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'PID Power/1', 'PID Power Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Fuzzy Power/1', 'Fuzzy Power Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'ANN Power/1', 'ANN Power Data/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Clock/1', 'Time Data/1', 'autorouting', 'on');
    
    % Connect inputs to metrics calculation function
    add_line(subsystemPath, 'PID Temperature/1', 'Calculate Metrics/1', 'autorouting', 'on');
    add_line(subsystemPath, 'Fuzzy Temperature/1', 'Calculate Metrics/2', 'autorouting', 'on');
    add_line(subsystemPath, 'ANN Temperature/1', 'Calculate Metrics/3', 'autorouting', 'on');
    add_line(subsystemPath, 'PID Power/1', 'Calculate Metrics/4', 'autorouting', 'on');
    add_line(subsystemPath, 'Fuzzy Power/1', 'Calculate Metrics/5', 'autorouting', 'on');
    add_line(subsystemPath, 'ANN Power/1', 'Calculate Metrics/6', 'autorouting', 'on');
    add_line(subsystemPath, 'Optimal Temperature/1', 'Calculate Metrics/7', 'autorouting', 'on');
    
    % Set up the MATLAB Function for metrics calculation
    metricsFcn = ['function fcn(pid_temp, fuzzy_temp, ann_temp, pid_power, fuzzy_power, ann_power, opt_temp)\n',...
        '    % Calculate performance metrics in real-time\n',...
        '    persistent pid_temp_error_sum fuzzy_temp_error_sum ann_temp_error_sum;\n',...
        '    persistent pid_power_sum fuzzy_power_sum ann_power_sum;\n',...
        '    persistent counter;\n',...
        '    \n',...
        '    % Initialize persistent variables\n',...
        '    if isempty(pid_temp_error_sum)\n',...
        '        pid_temp_error_sum = 0;\n',...
        '        fuzzy_temp_error_sum = 0;\n',...
        '        ann_temp_error_sum = 0;\n',...
        '        pid_power_sum = 0;\n',...
        '        fuzzy_power_sum = 0;\n',...
        '        ann_power_sum = 0;\n',...
        '        counter = 0;\n',...
        '    end\n',...
        '    \n',...
        '    % Accumulate error and power values\n',...
        '    pid_temp_error_sum = pid_temp_error_sum + abs(pid_temp - opt_temp);\n',...
        '    fuzzy_temp_error_sum = fuzzy_temp_error_sum + abs(fuzzy_temp - opt_temp);\n',...
        '    ann_temp_error_sum = ann_temp_error_sum + abs(ann_temp - opt_temp);\n',...
        '    \n',...
        '    pid_power_sum = pid_power_sum + pid_power;\n',...
        '    fuzzy_power_sum = fuzzy_power_sum + fuzzy_power;\n',...
        '    ann_power_sum = ann_power_sum + ann_power;\n',...
        '    \n',...
        '    counter = counter + 1;\n',...
        '    \n',...
        '    % At the end of simulation, calculate final metrics\n',...
        '    if counter == 6000 % 600 seconds / 0.1 time step = 6000 steps\n',...
        '        metrics.pid.avg_temp_error = pid_temp_error_sum / counter;\n',...
        '        metrics.fuzzy.avg_temp_error = fuzzy_temp_error_sum / counter;\n',...
        '        metrics.ann.avg_temp_error = ann_temp_error_sum / counter;\n',...
        '        \n',...
        '        metrics.pid.total_power = pid_power_sum;\n',...
        '        metrics.fuzzy.total_power = fuzzy_power_sum;\n',...
        '        metrics.ann.total_power = ann_power_sum;\n',...
        '        \n',...
        '        assignin(''base'', ''simulation_metrics'', metrics);\n',...
        '    end\n',...
        'end'];
    
    % Set the MATLAB Function content
    set_param([subsystemPath '/Calculate Metrics'], 'FunctionName', 'fcn');
    set_param([subsystemPath '/Calculate Metrics'], 'FunctionContents', metricsFcn);
end

function positionBlocks(modelName)
    % Position the blocks for better visual layout
    set_param([modelName '/Input Signals'], 'Position', [100, 100, 200, 150]);
    set_param([modelName '/System Parameters'], 'Position', [100, 200, 200, 250]);
    
    set_param([modelName '/PID Controller'], 'Position', [350, 100, 450, 150]);
    set_param([modelName '/Fuzzy Controller'], 'Position', [350, 200, 450, 250]);
    set_param([modelName '/ANN Controller'], 'Position', [350, 300, 450, 350]);
    
    set_param([modelName '/Engine & Cooling System (PID)'], 'Position', [550, 100, 650, 150]);
    set_param([modelName '/Engine & Cooling System (Fuzzy)'], 'Position', [550, 200, 650, 250]);
    set_param([modelName '/Engine & Cooling System (ANN)'], 'Position', [550, 300, 650, 350]);
    
    set_param([modelName '/Performance Metrics'], 'Position', [750, 200, 850, 250]);
    
    set_param([modelName '/Temperature Scope'], 'Position', [750, 100, 780, 130]);
    set_param([modelName '/Control Signal Scope'], 'Position', [750, 150, 780, 180]);
    set_param([modelName '/Power Consumption Scope'], 'Position', [750, 300, 780, 330]);
end

function fis = createFuzzySystem()
    % Create a Fuzzy Inference System for the cooling system controller
    fis = mamfis('CoolingSystem', 'mamdani');
    
    % Add input variables
    fis = addInput(fis, 'input', 'TemperatureError', [-50 50]);
    fis = addmf(fis, 'input', 1, 'NegLarge', 'trimf', [-50 -30 -10]);
    fis = addmf(fis, 'input', 1, 'NegSmall', 'trimf', [-20 -5 0]);
    fis = addmf(fis, 'input', 1, 'Zero', 'trimf', [-5 0 5]);
    fis = addmf(fis, 'input', 1, 'PosSmall', 'trimf', [0 5 20]);
    fis = addmf(fis, 'input', 1, 'PosLarge', 'trimf', [10 30 50]);
    
    fis = addinput(fis, 'input', 'ErrorChange', [-10 10]);
    fis = addmf(fis, 'input', 2, 'Decreasing', 'trimf', [-10 -5 0]);
    fis = addmf(fis, 'input', 2, 'Steady', 'trimf', [-2 0 2]);
    fis = addmf(fis, 'input', 2, 'Increasing', 'trimf', [0 5 10]);
    
    % Add output variable
    fis = addinput(fis, 'output', 'PumpSpeed', [0 1]);
    fis = addmf(fis, 'output', 1, 'VeryLow', 'trimf', [0 0.1 0.3]);
    fis = addmf(fis, 'output', 1, 'Low', 'trimf', [0.2 0.4 0.6]);
    fis = addmf(fis, 'output', 1, 'Medium', 'trimf', [0.4 0.6 0.8]);
    fis = addmf(fis, 'output', 1, 'High', 'trimf', [0.6 0.8 0.9]);
    fis = addmf(fis, 'output', 1, 'VeryHigh', 'trimf', [0.8 1 1]);
    
    % Add rules
    ruleList = [
        % If temperature is much higher than optimal (PosLarge)
        5 3 5 1 1  % PosLarge & Increasing -> VeryHigh
        5 2 5 1 1  % PosLarge & Steady -> VeryHigh
        5 1 4 1 1  % PosLarge & Decreasing -> High
        
        % If temperature is slightly higher than optimal (PosSmall)
        4 3 4 1 1  % PosSmall & Increasing -> High
        4 2 3 1 1  % PosSmall & Steady -> Medium
        4 1 2 1 1  % PosSmall & Decreasing -> Low
        
        % If temperature is at optimal level (Zero)
        3 3 3 1 1  % Zero & Increasing -> Medium
        3 2 2 1 1  % Zero & Steady -> Low
        3 1 1 1 1  % Zero & Decreasing -> VeryLow
        
        % If temperature is slightly lower than optimal (NegSmall)
        2 3 2 1 1  % NegSmall & Increasing -> Low
        2 2 1 1 1  % NegSmall & Steady -> VeryLow
        2 1 1 1 1  % NegSmall & Decreasing -> VeryLow
        
        % If temperature is much lower than optimal (NegLarge)
        1 3 1 1 1  % NegLarge & Increasing -> VeryLow
        1 2 1 1 1  % NegLarge & Steady -> VeryLow
        1 1 1 1 1  % NegLarge & Decreasing -> VeryLow
    ];
    
    fis = addrule(fis, ruleList);
end

function createANNControllerScript()
    % Creates a script to train the ANN controller
    
    scriptContent = [...
        'function net = trainCoolingSystemANN()\n',...
        '    % Train an ANN for the cooling system controller\n',...
        '    \n',...
        '    % Create training data\n',...
        '    % Input: [engine_temp, optimal_temp, load_profile, ambient_temp]\n',...
        '    % Output: pump_speed\n',...
        '    \n',...
        '    % Generate training data points\n',...
        '    num_samples = 5000;\n',...
        '    \n',...
        '    % Random input values in expected ranges\n',...
        '    engine_temps = 60 + 60*rand(num_samples, 1); % 60-120°C\n',...
        '    optimal_temps = 90*ones(num_samples, 1); % Fixed at 90°C\n',...
        '    load_profiles = 0.5 + 1.5*rand(num_samples, 1); % 0.5-2.0\n',...
        '    ambient_temps = 10 + 30*rand(num_samples, 1); % 10-40°C\n',...
        '    \n',...
        '    % Create input matrix\n',...
        '    inputs = [engine_temps, optimal_temps, load_profiles, ambient_temps]'';\n',...
        '    \n',...
        '    % Generate target outputs using a rule-based approach\n',...
        '    % This mimics what an expert or a well-tuned controller would do\n',...
        '    pump_speeds = zeros(num_samples, 1);\n',...
        '    \n',...
        '    for i = 1:num_samples\n',...
        '        temp_error = engine_temps(i) - optimal_temps(i);\n',...
        '        load_factor = load_profiles(i);\n',...
        '        ambient_factor = (ambient_temps(i) - 25) / 15; % Normalized around 25°C\n',...
        '        \n',...
        '        % Base pump speed on temperature error\n',...
        '        if temp_error < -20\n',...
        '            % Engine much colder than optimal\n',...
        '            base_speed = 0.1;\n',...
        '        elseif temp_error < -5\n',...
        '            % Engine slightly colder than optimal\n',...
        '            base_speed = 0.3;\n',...
        '        elseif temp_error < 5\n',...
        '            % Engine at optimal temperature\n',...
        '            base_speed = 0.5;\n',...
        '        elseif temp_error < 15\n',...
        '            % Engine slightly hotter than optimal\n',...
        '            base_speed = 0.7;\n',...
        '        else\n',...
        '            % Engine much hotter than optimal\n',...
        '            base_speed = 0.9;\n',...
        '        end\n',...
        '        \n',...
        '        % Adjust for load\n',...
        '        load_adjustment = 0.2 * (load_factor - 1);\n',...
        '        \n',...
        '        % Adjust for ambient temperature\n',...
        '        ambient_adjustment = 0.1 * ambient_factor;\n',...
        '        \n',...
        '        % Calculate final pump speed\n',...
        '        pump_speed = base_speed + load_adjustment + ambient_adjustment;\n',...
        '        \n',...
        '        % Ensure within bounds\n',...
        '        pump_speed = max(0, min(1, pump_speed));\n',...
        '        \n',...
        '        pump_speeds(i) = pump_speed;\n',...
        '    end\n',...
        '    \n',...
        '    targets = pump_speeds'';\n',...
        '    \n',...
        '    % Create and train the network\n',...
        '    net = feedforwardnet([10 5]); % Two hidden layers\n',...
        '    \n',...
        '    % Configure the network\n',...
        '    net.trainFcn = ''trainlm''; % Levenberg-Marquardt\n',...
        '    net.trainParam.epochs = 500;\n',...
        '    net.trainParam.goal = 1e-5;\n',...
        '    net.trainParam.min_grad = 1e-7;\n',...
        '    \n',...
        '    % Train the network\n',...
        '    [net, tr] = train(net, inputs, targets);\n',...
        '    \n',...
        '    % Save the trained network\n',...
        '    save(''cooling_system_ann.mat'', ''net'');\n',...
        '    \n',...
        '    % Generate Simulink compatible network\n',...
        '    gensim(net);\n',...
        '    \n',...
        '    fprintf(''ANN controller trained and saved successfully.\\n'');\n',...
        'end\n'...
    ];
    
    % Write the script to a file
    fid = fopen('trainCoolingSystemANN.m', 'w');
    fprintf(fid, '%s', scriptContent);
    fclose(fid);
    
    fprintf('ANN training script created: trainCoolingSystemANN.m\n');
end

function createSimulationReport()
    % Creates a comprehensive HTML report of simulation results
    
    if ~exist('simulation_metrics', 'var')
        fprintf('No simulation metrics available. Run the simulation first.\n');
        return;
    end
    
    % Create HTML report
    reportFilename = 'cooling_system_comparison_report.html';
    fid = fopen(reportFilename, 'w');
    
    % HTML header
    fprintf(fid, '<!DOCTYPE html>\n');
    fprintf(fid, '<html lang="en">\n');
    fprintf(fid, '<head>\n');
    fprintf(fid, '    <meta charset="UTF-8">\n');
    fprintf(fid, '    <meta name="viewport" content="width=device-width, initial-scale=1.0">\n');
    fprintf(fid, '    <title>Cooling System Controller Comparison</title>\n');
    fprintf(fid, '    <style>\n');
    fprintf(fid, '        body { font-family: Arial, sans-serif; margin: 40px; }\n');
    fprintf(fid, '        h1 { color: #2c3e50; }\n');
    fprintf(fid, '        h2 { color: #3498db; margin-top: 30px; }\n');
    fprintf(fid, '        table { border-collapse: collapse; width: 100%%; margin: 20px 0; }\n');
    fprintf(fid, '        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }\n');
    fprintf(fid, '        th { background-color: #f2f2f2; }\n');
    fprintf(fid, '        tr:nth-child(even) { background-color: #f9f9f9; }\n');
    fprintf(fid, '        .chart-container { margin: 30px 0; }\n');
    fprintf(fid, '        .chart-img { max-width: 100%%; height: auto; }\n');
    fprintf(fid, '        .conclusion { margin-top: 30px; padding: 15px; background-color: #edf7ff; border-radius: 5px; }\n');
    fprintf(fid, '    </style>\n');
    fprintf(fid, '</head>\n');
    fprintf(fid, '<body>\n');
    
    % Report header
    fprintf(fid, '    <h1>Engine Cooling System Controller Comparison Report</h1>\n');
    fprintf(fid, '    <p>This report compares the performance of PID, Fuzzy Logic, and ANN controllers for an engine cooling system.</p>\n');
    
    % Executive summary
    fprintf(fid, '    <h2>Executive Summary</h2>\n');
    fprintf(fid, '    <p>Three different control approaches were evaluated for managing an engine cooling system:</p>\n');
    fprintf(fid, '    <ul>\n');
    fprintf(fid, '        <li><strong>PID Controller:</strong> A conventional proportional-integral-derivative controller</li>\n');
    fprintf(fid, '        <li><strong>Fuzzy Logic Controller:</strong> A rule-based system using linguistic variables</li>\n');
    fprintf(fid, '        <li><strong>Artificial Neural Network (ANN):</strong> A machine learning approach trained on expert data</li>\n');
    fprintf(fid, '    </ul>\n');
    
    % Summary table
    fprintf(fid, '    <h2>Performance Summary</h2>\n');
    fprintf(fid, '    <table>\n');
    fprintf(fid, '        <tr>\n');
    fprintf(fid, '            <th>Metric</th>\n');
    fprintf(fid, '            <th>PID Controller</th>\n');
    fprintf(fid, '            <th>Fuzzy Controller</th>\n');
    fprintf(fid, '            <th>ANN Controller</th>\n');
    fprintf(fid, '            <th>Best Performer</th>\n');
    fprintf(fid, '        </tr>\n');
    
    % Temperature error
    fprintf(fid, '        <tr>\n');
    fprintf(fid, '            <td>Average Temperature Error</td>\n');
    fprintf(fid, '            <td>%.2f°C</td>\n', simulation_metrics.pid.avg_temp_error);
    fprintf(fid, '            <td>%.2f°C</td>\n', simulation_metrics.fuzzy.avg_temp_error);
    fprintf(fid, '            <td>%.2f°C</td>\n', simulation_metrics.ann.avg_temp_error);
    
    % Determine best performer for temperature control
    errors = [simulation_metrics.pid.avg_temp_error, simulation_metrics.fuzzy.avg_temp_error, simulation_metrics.ann.avg_temp_error];
    [~, best_idx] = min(errors);
    if best_idx == 1
        fprintf(fid, '            <td><strong>PID</strong></td>\n');
    elseif best_idx == 2
        fprintf(fid, '            <td><strong>Fuzzy</strong></td>\n');
    else
        fprintf(fid, '            <td><strong>ANN</strong></td>\n');
    end
    fprintf(fid, '        </tr>\n');
    
    % Power consumption
    fprintf(fid, '        <tr>\n');
    fprintf(fid, '            <td>Total Power Consumption</td>\n');
    pid_power_kwh = simulation_metrics.pid.total_power * 0.1 / 3600;
    fuzzy_power_kwh = simulation_metrics.fuzzy.total_power * 0.1 / 3600;
    ann_power_kwh = simulation_metrics.ann.total_power * 0.1 / 3600;
    
    fprintf(fid, '            <td>%.2f kWh</td>\n', pid_power_kwh);
    fprintf(fid, '            <td>%.2f kWh</td>\n', fuzzy_power_kwh);
    fprintf(fid, '            <td>%.2f kWh</td>\n', ann_power_kwh);
    
    % Determine best performer for power efficiency
    powers = [pid_power_kwh, fuzzy_power_kwh, ann_power_kwh];
    [~, best_idx] = min(powers);
    if best_idx == 1
        fprintf(fid, '            <td><strong>PID</strong></td>\n');
    elseif best_idx == 2
        fprintf(fid, '            <td><strong>Fuzzy</strong></td>\n');
    else
        fprintf(fid, '            <td><strong>ANN</strong></td>\n');
    end
    fprintf(fid, '        </tr>\n');
    
    % Add response time (calculated during plotting)
    fprintf(fid, '        <tr>\n');
    fprintf(fid, '            <td>Response Time</td>\n');
    fprintf(fid, '            <td>See detailed charts</td>\n');
    fprintf(fid, '            <td>See detailed charts</td>\n');
    fprintf(fid, '            <td>See detailed charts</td>\n');
    fprintf(fid, '            <td>See detailed analysis</td>\n');
    fprintf(fid, '        </tr>\n');
    
    fprintf(fid, '    </table>\n');
    
    % Charts section placeholder - in a real implementation, we would save the MATLAB figures
    % to image files and include them here
    fprintf(fid, '    <h2>Performance Charts</h2>\n');
    fprintf(fid, '    <p>Please refer to the MATLAB figures for detailed performance charts:</p>\n');
    fprintf(fid, '    <ul>\n');
    fprintf(fid, '        <li>Engine Temperature Comparison</li>\n');
    fprintf(fid, '        <li>Power Consumption Comparison</li>\n');
    fprintf(fid, '        <li>Temperature Error Comparison</li>\n');
    fprintf(fid, '        <li>Cumulative Energy Consumption</li>\n');
    fprintf(fid, '        <li>Controller Efficiency Comparison</li>\n');
    fprintf(fid, '    </ul>\n');
    
    % Add a conclusion section
    fprintf(fid, '    <div class="conclusion">\n');
    fprintf(fid, '        <h2>Conclusion and Recommendations</h2>\n');
    
    % Determine overall recommendation based on metrics
    % Simple scoring: lower error is better, lower power is better
    pid_score = simulation_metrics.pid.avg_temp_error + pid_power_kwh*0.5;
    fuzzy_score = simulation_metrics.fuzzy.avg_temp_error + fuzzy_power_kwh*0.5;
    ann_score = simulation_metrics.ann.avg_temp_error + ann_power_kwh*0.5;
    
    scores = [pid_score, fuzzy_score, ann_score];
    [~, best_overall] = min(scores);
    
    if best_overall == 1
        fprintf(fid, '        <p>Based on the simulation results, the <strong>PID controller</strong> offers the best overall performance considering both temperature control accuracy and power efficiency.</p>\n');
    elseif best_overall == 2
        fprintf(fid, '        <p>Based on the simulation results, the <strong>Fuzzy Logic controller</strong> offers the best overall performance considering both temperature control accuracy and power efficiency.</p>\n');
    else
        fprintf(fid, '        <p>Based on the simulation results, the <strong>ANN controller</strong> offers the best overall performance considering both temperature control accuracy and power efficiency.</p>\n');
    end
    
    fprintf(fid, '        <p>Key findings:</p>\n');
    fprintf(fid, '        <ul>\n');
    
    % Fixed: Corrected the syntax error in the cell indexing
    temp_controllers = {'PID', 'Fuzzy', 'ANN'};
    fprintf(fid, '            <li>Temperature control: The %s controller achieved the most precise temperature regulation.</li>\n', temp_controllers{best_idx});
    fprintf(fid, '            <li>Energy efficiency: The %s controller demonstrated the lowest energy consumption.</li>\n', temp_controllers{best_idx});
    fprintf(fid, '            <li>Overall performance: The %s controller offers the best balance of temperature control and energy efficiency.</li>\n', temp_controllers{best_overall});
    fprintf(fid, '        </ul>\n');
    fprintf(fid, '    </div>\n');
    
    % Close HTML tags
    fprintf(fid, '</body>\n');
    fprintf(fid, '</html>\n');
    
    fclose(fid);
    
    fprintf('Report generated: %s\n', reportFilename);
    if ispc
        system(['start ' reportFilename]);
    elseif ismac
        system(['open ' reportFilename]);
    elseif isunix
        system(['xdg-open ' reportFilename]);
    end
end
function createMainSimulationScript()
    % Creates a main script to run the simulation and analyze results
    
    scriptContent = [...
        'function runCoolingSystemSimulation()\n',...
        '    % Runs the cooling system simulation and analyzes results\n',...
        '    \n',...
        '    % Clear workspace and figures\n',...
        '    clear simulation_metrics;\n',...
        '    \n',...
        '    % Check if ANN model exists, otherwise train it\n',...
        '    if ~exist(''cooling_system_ann.mat'', ''file'')\n',...
        '        fprintf(''Training ANN controller...\\n'');\n',...
        '        trainCoolingSystemANN();\n',...
        '    end\n',...
        '    \n',...
        '    % Load the ANN model\n',...
        '    load(''cooling_system_ann.mat'');\n',...
        '    \n',...
        '    % Set up the ANN block in the Simulink model\n',...
        '    modelName = ''CoolingSystemComparison'';\n',...
        '    if ~bdIsLoaded(modelName)\n',...
        '        open_system(modelName);\n',...
        '    end\n',...
        '    \n',...
        '    % Set the trained network in the ANN block\n',...
        '    set_param([modelName ''/ANN Controller/ANN Model''], ''Network'', ''net'');\n',...
        '    \n',...
        '    % Run the simulation\n',...
        '    fprintf(''Running Simulink simulation...\\n'');\n',...
        '    sim(modelName);\n',...
        '    \n',...
        '    % Process and display results\n',...
        '    if exist(''simulation_metrics'', ''var'')\n',...
        '        fprintf(''\\nSimulation Results:\\n'');\n',...
        '        fprintf(''Average Temperature Error (PID): %.2f°C\\n'', simulation_metrics.pid.avg_temp_error);\n',...
        '        fprintf(''Average Temperature Error (Fuzzy): %.2f°C\\n'', simulation_metrics.fuzzy.avg_temp_error);\n',...
        '        fprintf(''Average Temperature Error (ANN): %.2f°C\\n'', simulation_metrics.ann.avg_temp_error);\n',...
        '        \n',...
        '        fprintf(''Total Power Consumption (PID): %.2f kWh\\n'', simulation_metrics.pid.total_power * 0.1 / 3600); % Convert to kWh\n',...
        '        fprintf(''Total Power Consumption (Fuzzy): %.2f kWh\\n'', simulation_metrics.fuzzy.total_power * 0.1 / 3600);\n',...
        '        fprintf(''Total Power Consumption (ANN): %.2f kWh\\n'', simulation_metrics.ann.total_power * 0.1 / 3600);\n',...
        '    else\n',...
        '        fprintf(''No simulation metrics available. Check if the simulation completed successfully.\\n'');\n',...
        '    end\n',...
        '    \n',...
        '    % Plot detailed results\n',...
        '    plotDetailedResults();\n',...
        'end\n',...
        '\n',...
        'function plotDetailedResults()\n',...
        '    % Create detailed plots of simulation results\n',...
        '    \n',...
        '    % Create figure for temperature comparison\n',...
        '    figure(''Name'', ''Engine Temperature Comparison'');\n',...
        '    plot(time, T_engine_pid, ''b-'', ''LineWidth'', 1.5);\n',...
        '    hold on;\n',...
        '    plot(time, T_engine_fuzzy, ''r-'', ''LineWidth'', 1.5);\n',...
        '    plot(time, T_engine_ann, ''g-'', ''LineWidth'', 1.5);\n',...
        '    plot(time, 90*ones(size(time)), ''k--'', ''LineWidth'', 1);\n',...
        '    hold off;\n',...
        '    xlabel(''Time (s)'');\n',...
        '    ylabel(''Temperature (°C)'');\n',...
        '    title(''Engine Temperature Comparison'');\n',...
        '    legend(''PID Controller'', ''Fuzzy Controller'', ''ANN Controller'', ''Optimal Temperature'');\n',...
        '    grid on;\n',...
        '    \n',...
        '    % Create figure for power consumption comparison\n',...
        '    figure(''Name'', ''Power Consumption Comparison'');\n',...
        '    plot(time, power_consumption_pid, ''b-'', ''LineWidth'', 1.5);\n',...
        '    hold on;\n',...
        '    plot(time, power_consumption_fuzzy, ''r-'', ''LineWidth'', 1.5);\n',...
        '    plot(time, power_consumption_ann, ''g-'', ''LineWidth'', 1.5);\n',...
        '    hold off;\n',...
        '    xlabel(''Time (s)'');\n',...
        '    ylabel(''Power (kW)'');\n',...
        '    title(''Power Consumption Comparison'');\n',...
        '    legend(''PID Controller'', ''Fuzzy Controller'', ''ANN Controller'');\n',...
        '    grid on;\n',...
        '    \n',...
        '    % Create figure for temperature error\n',...
        '    figure(''Name'', ''Temperature Error'');\n',...
        '    plot(time, abs(T_engine_pid - 90), ''b-'', ''LineWidth'', 1.5);\n',...
        '    hold on;\n',...
        '    plot(time, abs(T_engine_fuzzy - 90), ''r-'', ''LineWidth'', 1.5);\n',...
        '    plot(time, abs(T_engine_ann - 90), ''g-'', ''LineWidth'', 1.5);\n',...
        '    hold off;\n',...
        '    xlabel(''Time (s)'');\n',...
        '    ylabel(''Temperature Error (°C)'');\n',...
        '    title(''Absolute Temperature Error'');\n',...
        '    legend(''PID Controller'', ''Fuzzy Controller'', ''ANN Controller'');\n',...
        '    grid on;\n',...
        '    \n',...
        '    % Create figure for control output comparison\n',...
        '    figure(''Name'', ''Control Output Comparison'');\n',...
        '    plot(time, control_output_pid, ''b-'', ''LineWidth'', 1.5);\n',...
        '    hold on;\n',...
        '    plot(time, control_output_fuzzy, ''r-'', ''LineWidth'', 1.5);\n',...
        '    plot(time, control_output_ann, ''g-'', ''LineWidth'', 1.5);\n',...
        '    hold off;\n',...
        '    xlabel(''Time (s)'');\n',...
        '    ylabel(''Control Output (%)'');\n',...
        '    title(''Control Output Comparison'');\n',...
        '    legend(''PID Controller'', ''Fuzzy Controller'', ''ANN Controller'');\n',...
        '    grid on;\n',...
        '    \n',...
        '    % Create efficiency comparison figure\n',...
        '    figure(''Name'', ''Cooling System Efficiency'');\n',...
        '    efficiency_pid = simulation_metrics.pid.avg_temp_error ./ (simulation_metrics.pid.total_power * 0.1 / 3600);\n',...
        '    efficiency_fuzzy = simulation_metrics.fuzzy.avg_temp_error ./ (simulation_metrics.fuzzy.total_power * 0.1 / 3600);\n',...
        '    efficiency_ann = simulation_metrics.ann.avg_temp_error ./ (simulation_metrics.ann.total_power * 0.1 / 3600);\n',...
        '    \n',...
        '    bar([efficiency_pid, efficiency_fuzzy, efficiency_ann]);\n',...
        '    set(gca, ''xticklabel'', {''PID Controller'', ''Fuzzy Controller'', ''ANN Controller''});\n',...
        '    ylabel(''Efficiency (°C/kWh)'');\n',...
        '    title(''Controller Efficiency Comparison'');\n',...
        '    grid on;\n',...
        'end\n',...
    ];
    
    % Write the script to file
    fid = fopen('runCoolingSystemSimulation.m', 'w');
    fprintf(fid, '%s', scriptContent);
    fclose(fid);
    
    fprintf('Main simulation script created: runCoolingSystemSimulation.m\n');
end


function callUncalledFunctions()
    fprintf('simulink');
    buildCoolingSystemSimulinkModel();
    % Call createSimulationReport function
    fprintf('ann controller script');

    createANNControllerScript();

    fprintf('Calling createSimulationReport...\n');
    createSimulationReport();
    
    % Call createMainSimulationScript function
    fprintf('Calling createMainSimulationScript...\n');
    createMainSimulationScript();
    
    fprintf('All uncalled functions have been executed.\n');
end
buildCoolingSystemSimulinkModel();
% createANNControllerScript();
% createSimulationReport();
% createMainSimulationScript();

callUncalledFunctions();