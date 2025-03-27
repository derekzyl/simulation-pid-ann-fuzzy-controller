
%% Interactive Electric Vehicle Cooling System Simulation - simulink Implementation
% This script creates an interactive simulink model that implements the cooling system
% simulation with PID, Fuzzy Logic, and ANN controllers. Users can adjust parameters
% interactively through a dashboard interface.

% Clear workspace and close any open simulink models
clear all;
close all;
clc;
bdclose all;

%% Create a new simulink model
modelName = 'EVCoolingSystemSimulation';
if ~bdIsLoaded(modelName)
	new_system(modelName);
end
open_system(modelName);

% Set model parameters
set_param(modelName, 'Solver', 'ode45', 'StopTime', '600', 'StartTime', '0');

% Create User-Configurable Dashboard
% Create a dashboard using the Dashboard block from simulink
dashboardPath = [modelName '/System Parameters'];
add_block('simulink/Dashboard', dashboardPath);
set_param(dashboardPath, 'Position', [50, 50, 350, 350]);

% Add parameter controls to the dashboard
engineParams = [dashboardPath '/Engine Parameters'];
add_block('simulink/Dashboard/Group', engineParams); % Subgroup Block might be the issue
set_param(engineParams, 'Position', [20, 20, 300, 150]);

% Engine mass control
add_block('simulink/Dashboard/Knob', [engineParams '/Engine Mass']);
set_param([engineParams '/Engine Mass'], 'Position', [20, 30, 60, 70]);
set_param([engineParams '/Engine Mass'], 'Min', '50', 'Max', '250', 'Value', '150');
set_param([engineParams '/Engine Mass'], 'Label', 'Mass (kg)');

% Engine specific heat control
add_block('simulink/Dashboard/Slider', [engineParams '/Engine Specific Heat']);
set_param([engineParams '/Engine Specific Heat'], 'Position', [90, 30, 180, 50]);
set_param([engineParams '/Engine Specific Heat'], 'Min', '200', 'Max', '700', 'Value', '450');
set_param([engineParams '/Engine Specific Heat'], 'Label', 'Specific Heat (J/kg·K)');

% Engine heat generation control
add_block('simulink/Dashboard/Knob', [engineParams '/Heat Generation']);
set_param([engineParams '/Heat Generation'], 'Position', [200, 30, 240, 70]);
set_param([engineParams '/Heat Generation'], 'Min', '10000', 'Max', '50000', 'Value', '30000');
set_param([engineParams '/Heat Generation'], 'Label', 'Heat Gen. (W)');

% Engine optimal temperature control
add_block('simulink/Dashboard/Slider', [engineParams '/Optimal Temperature']);
set_param([engineParams '/Optimal Temperature'], 'Position', [20, 90, 140, 110]);
set_param([engineParams '/Optimal Temperature'], 'Min', '70', 'Max', '110', 'Value', '90');
set_param([engineParams '/Optimal Temperature'], 'Label', 'Optimal Temp (°C)');

% Engine ambient temperature control
add_block('simulink/Dashboard/Slider', [engineParams '/Ambient Temperature']);
set_param([engineParams '/Ambient Temperature'], 'Position', [170, 90, 290, 110]);
set_param([engineParams '/Ambient Temperature'], 'Min', '0', 'Max', '40', 'Value', '25');
set_param([engineParams '/Ambient Temperature'], 'Label', 'Ambient Temp (°C)');

% Add parameters for water pump
pumpParams = [dashboardPath '/Pump Parameters'];
add_block('simulink/Dashboard/Group', pumpParams); % Subgroup Block might be the issue
set_param(pumpParams, 'Position', [20, 170, 300, 260]);

% Pump max flow rate control
add_block('simulink/Dashboard/Slider', [pumpParams '/Max Flow Rate']);
set_param([pumpParams '/Max Flow Rate'], 'Position', [20, 20, 140, 40]);
set_param([pumpParams '/Max Flow Rate'], 'Min', '1', 'Max', '5', 'Value', '2.5');
set_param([pumpParams '/Max Flow Rate'], 'Label', 'Max Flow (kg/s)');

% Pump min flow rate control
add_block('simulink/Dashboard/Slider', [pumpParams '/Min Flow Rate']);
set_param([pumpParams '/Min Flow Rate'], 'Position', [160, 20, 280, 40]);
set_param([pumpParams '/Min Flow Rate'], 'Min', '0.1', 'Max', '1', 'Value', '0.2');
set_param([pumpParams '/Min Flow Rate'], 'Label', 'Min Flow (kg/s)');

% Pump max speed control
add_block('simulink/Dashboard/Knob', [pumpParams '/Max Speed']);
set_param([pumpParams '/Max Speed'], 'Position', [50, 50, 90, 90]);
set_param([pumpParams '/Max Speed'], 'Min', '1000', 'Max', '5000', 'Value', '3000');
set_param([pumpParams '/Max Speed'], 'Label', 'Max Speed (RPM)');

% Pump time constant control
add_block('simulink/Dashboard/Slider', [pumpParams '/Time Constant']);
set_param([pumpParams '/Time Constant'], 'Position', [160, 60, 280, 80]);
set_param([pumpParams '/Time Constant'], 'Min', '0.1', 'Max', '2', 'Value', '0.5');
set_param([pumpParams '/Time Constant'], 'Label', 'Time Constant (s)');

%% Create Controller Selection Dashboard
controllerParams = [dashboardPath '/Controller Parameters'];
add_block('simulink/Dashboard/Group', controllerParams); % Subgroup Block might be the issue
set_param(controllerParams, 'Position', [20, 280, 300, 350]);

% Controller selection
add_block('simulink/Dashboard/Radio Button', [controllerParams '/Controller Selection']);
set_param([controllerParams '/Controller Selection'], 'Position', [20, 20, 150, 60]);
set_param([controllerParams '/Controller Selection'], 'Items', 'PID|Fuzzy Logic|ANN');
set_param([controllerParams '/Controller Selection'], 'Label', 'Controller Type');

% PID controller parameters
pidParams = [controllerParams '/PID Parameters'];
add_block('simulink/Dashboard/Group', pidParams); % Subgroup Block might be the issue
set_param(pidParams, 'Position', [170, 20, 280, 130]);

% PID Kp control
add_block('simulink/Dashboard/Knob', [pidParams '/Kp']);
set_param([pidParams '/Kp'], 'Position', [10, 20, 40, 50]);
set_param([pidParams '/Kp'], 'Min', '0', 'Max', '300', 'Value', '150');
set_param([pidParams '/Kp'], 'Label', 'Kp');

% PID Ki control
add_block('simulink/Dashboard/Knob', [pidParams '/Ki']);
set_param([pidParams '/Ki'], 'Position', [50, 20, 80, 50]);
set_param([pidParams '/Ki'], 'Min', '0', 'Max', '50', 'Value', '15');
set_param([pidParams '/Ki'], 'Label', 'Ki');

% PID Kd control
add_block('simulink/Dashboard/Knob', [pidParams '/Kd']);
set_param([pidParams '/Kd'], 'Position', [90, 20, 120, 50]);
set_param([pidParams '/Kd'], 'Min', '0', 'Max', '50', 'Value', '10');
set_param([pidParams '/Kd'], 'Label', 'Kd');

%% Create Disturbance Profiles Dashboard
disturbanceParams = [modelName '/Disturbance Profiles'];
add_block('simulink/Dashboard', disturbanceParams);
set_param(disturbanceParams, 'Position', [400, 50, 600, 250]);

% Engine load profile controls
loadParams = [disturbanceParams '/Load Profile'];
add_block('simulink/Dashboard/Group', loadParams); % Subgroup Block might be the issue
set_param(loadParams, 'Position', [20, 20, 180, 180]);

% Load profile type
add_block('simulink/Dashboard/Radio Button', [loadParams '/Load Type']);
set_param([loadParams '/Load Type'], 'Position', [20, 20, 150, 60]);
set_param([loadParams '/Load Type'], 'Items', 'Constant|Step|Variable|Custom');
set_param([loadParams '/Load Type'], 'Label', 'Load Profile Type');

% Load magnitude control
add_block('simulink/Dashboard/Slider', [loadParams '/Load Magnitude']);
set_param([loadParams '/Load Magnitude'], 'Position', [20, 70, 150, 90]);
set_param([loadParams '/Load Magnitude'], 'Min', '0.5', 'Max', '2', 'Value', '1.5');
set_param([loadParams '/Load Magnitude'], 'Label', 'Load Magnitude');

% Ambient temperature profile controls
ambientParams = [disturbanceParams '/Ambient Temperature Profile'];
add_block('simulink/Dashboard/Group', ambientParams); % Subgroup Block might be the issue
set_param(ambientParams, 'Position', [20, 210, 180, 350]);

% Ambient profile type
add_block('simulink/Dashboard/Radio Button', [ambientParams '/Ambient Type']);
set_param([ambientParams '/Ambient Type'], 'Position', [20, 20, 150, 60]);
set_param([ambientParams '/Ambient Type'], 'Items', 'Constant|Step|Variable|Custom');
set_param([ambientParams '/Ambient Type'], 'Label', 'Ambient Profile Type');

% Ambient variation control
add_block('simulink/Dashboard/Slider', [ambientParams '/Ambient Variation']);
set_param([ambientParams '/Ambient Variation'], 'Position', [20, 70, 150, 90]);
set_param([ambientParams '/Ambient Variation'], 'Min', '-20', 'Max', '20', 'Value', '15');
set_param([ambientParams '/Ambient Variation'], 'Label', 'Temperature Variation (°C)');





%% Create Main System Model
% Create the main system subsystem
systemModel = [modelName '/Cooling System Model'];
add_block('simulink/Ports & Subsystems/Subsystem', systemModel);
set_param(systemModel, 'Position', [400, 300, 600, 400]);

% Create input and output ports for the subsystem
delete_line(systemModel, 'In1/1', 'Out1/1');
delete_block([systemModel '/In1']);
delete_block([systemModel '/Out1']);

% Create new input ports
add_block('simulink/Sources/In1', [systemModel '/Controller Type']);
set_param([systemModel '/Controller Type'], 'Position', [50, 50, 70, 70]);

add_block('simulink/Sources/In1', [systemModel '/Engine Parameters']);
set_param([systemModel '/Engine Parameters'], 'Position', [50, 100, 70, 120]);

add_block('simulink/Sources/In1', [systemModel '/Pump Parameters']);
set_param([systemModel '/Pump Parameters'], 'Position', [50, 150, 70, 170]);

add_block('simulink/Sources/In1', [systemModel '/Controller Parameters']);
set_param([systemModel '/Controller Parameters'], 'Position', [50, 200, 70, 220]);

add_block('simulink/Sources/In1', [systemModel '/Load Profile']);
set_param([systemModel '/Load Profile'], 'Position', [50, 250, 70, 270]);

add_block('simulink/Sources/In1', [systemModel '/Ambient Profile']);
set_param([systemModel '/Ambient Profile'], 'Position', [50, 300, 70, 320]);

% Create output ports for temperature, control signals, and power
add_block('simulink/Sinks/Out1', [systemModel '/Engine Temperature']);
set_param([systemModel '/Engine Temperature'], 'Position', [550, 100, 570, 120]);

add_block('simulink/Sinks/Out1', [systemModel '/Coolant Temperature']);
set_param([systemModel '/Coolant Temperature'], 'Position', [550, 150, 570, 170]);

add_block('simulink/Sinks/Out1', [systemModel '/Pump Speed']);
set_param([systemModel '/Pump Speed'], 'Position', [550, 200, 570, 220]);

add_block('simulink/Sinks/Out1', [systemModel '/Power Consumption']);
set_param([systemModel '/Power Consumption'], 'Position', [550, 250, 570, 270]);

%% Create Controller Subsystems

% Create the PID Controller Subsystem
pidController = [systemModel '/PID Controller'];
add_block('simulink/Ports & Subsystems/Subsystem', pidController);
set_param(pidController, 'Position', [200, 100, 300, 150]);

% Delete default connections
delete_line(pidController, 'In1/1', 'Out1/1');
delete_block([pidController '/In1']);
delete_block([pidController '/Out1']);

% Add PID controller inputs and outputs
add_block('simulink/Sources/In1', [pidController '/Error Input']);
set_param([pidController '/Error Input'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [pidController '/Parameters']);
set_param([pidController '/Parameters'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sinks/Out1', [pidController '/Control Output']);
set_param([pidController '/Control Output'], 'Position', [350, 45, 370, 65]);

% Add PID controller blocks
add_block('simulink/Continuous/PID Controller', [pidController '/PID']);
set_param([pidController '/PID'], 'Position', [150, 40, 250, 70]);

% Add Demux for parameters
add_block('simulink/Signal Routing/Demux', [pidController '/Parameter Demux']);
set_param([pidController '/Parameter Demux'], 'Position', [80, 65, 85, 95]);
set_param([pidController '/Parameter Demux'], 'Outputs', '3');

% Connect PID controller blocks
add_line(pidController, 'Error Input/1', 'PID/1', 'autorouting', 'on');
add_line(pidController, 'PID/1', 'Control Output/1', 'autorouting', 'on');
add_line(pidController, 'Parameters/1', 'Parameter Demux/1', 'autorouting', 'on');
add_line(pidController, 'Parameter Demux/1', 'PID/1', 'autorouting', 'on');
add_line(pidController, 'Parameter Demux/2', 'PID/2', 'autorouting', 'on');
add_line(pidController, 'Parameter Demux/3', 'PID/3', 'autorouting', 'on');

% Create the Fuzzy Logic Controller Subsystem
fuzzyController = [systemModel '/Fuzzy Logic Controller'];
add_block('simulink/Ports & Subsystems/Subsystem', fuzzyController);
set_param(fuzzyController, 'Position', [200, 180, 300, 230]);

% Delete default connections
delete_line(fuzzyController, 'In1/1', 'Out1/1');
delete_block([fuzzyController '/In1']);
delete_block([fuzzyController '/Out1']);

% Add Fuzzy controller inputs and outputs
add_block('simulink/Sources/In1', [fuzzyController '/Error Input']);
set_param([fuzzyController '/Error Input'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [fuzzyController '/Error Rate']);
set_param([fuzzyController '/Error Rate'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sinks/Out1', [fuzzyController '/Control Output']);
set_param([fuzzyController '/Control Output'], 'Position', [350, 45, 370, 65]);

% Add Fuzzy Logic Controller block
add_block('fuzzy/Fuzzy Logic Controller', [fuzzyController '/FLC']);
set_param([fuzzyController '/FLC'], 'Position', [150, 40, 250, 70]);
set_param([fuzzyController '/FLC'], 'FIS', 'cooling_system_fis');

% Connect Fuzzy Logic Controller blocks
add_line(fuzzyController, 'Error Input/1', 'FLC/1', 'autorouting', 'on');
add_line(fuzzyController, 'Error Rate/1', 'FLC/2', 'autorouting', 'on');
add_line(fuzzyController, 'FLC/1', 'Control Output/1', 'autorouting', 'on');

% Create the ANN Controller Subsystem
annController = [systemModel '/ANN Controller'];
add_block('simulink/Ports & Subsystems/Subsystem', annController);
set_param(annController, 'Position', [200, 260, 300, 310]);

% Delete default connections
delete_line(annController, 'In1/1', 'Out1/1');
delete_block([annController '/In1']);
delete_block([annController '/Out1']);

% Add ANN controller inputs and outputs
add_block('simulink/Sources/In1', [annController '/Temperature']);
set_param([annController '/Temperature'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [annController '/Load']);
set_param([annController '/Load'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sources/In1', [annController '/Ambient Temp']);
set_param([annController '/Ambient Temp'], 'Position', [20, 120, 40, 140]);

add_block('simulink/Sinks/Out1', [annController '/Control Output']);
set_param([annController '/Control Output'], 'Position', [350, 70, 370, 90]);

% Add Neural Network block
add_block('simulink/Deep Learning/Neural Network', [annController '/NN']);
set_param([annController '/NN'], 'Position', [200, 65, 300, 95]);

% Add Mux for inputs
add_block('simulink/Signal Routing/Mux', [annController '/Input Mux']);
set_param([annController '/Input Mux'], 'Position', [100, 65, 105, 95]);
set_param([annController '/Input Mux'], 'Inputs', '3');

% Connect ANN controller blocks
add_line(annController, 'Temperature/1', 'Input Mux/1', 'autorouting', 'on');
add_line(annController, 'Load/1', 'Input Mux/2', 'autorouting', 'on');
add_line(annController, 'Ambient Temp/1', 'Input Mux/3', 'autorouting', 'on');
add_line(annController, 'Input Mux/1', 'NN/1', 'autorouting', 'on');
add_line(annController, 'NN/1', 'Control Output/1', 'autorouting', 'on');

%% Create Engine and Cooling System Dynamics
engineSystem = [systemModel '/Engine & Cooling System'];
add_block('simulink/Ports & Subsystems/Subsystem', engineSystem);
set_param(engineSystem, 'Position', [350, 150, 450, 250]);

% Delete default connections
delete_line(engineSystem, 'In1/1', 'Out1/1');
delete_block([engineSystem '/In1']);
delete_block([engineSystem '/Out1']);

% Add Engine system inputs and outputs
add_block('simulink/Sources/In1', [engineSystem '/Heat Input']);
set_param([engineSystem '/Heat Input'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [engineSystem '/Flow Rate']);
set_param([engineSystem '/Flow Rate'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sources/In1', [engineSystem '/Ambient Temp']);
set_param([engineSystem '/Ambient Temp'], 'Position', [20, 120, 40, 140]);

add_block('simulink/Sources/In1', [engineSystem '/Engine Parameters']);
set_param([engineSystem '/Engine Parameters'], 'Position', [20, 170, 40, 190]);

add_block('simulink/Sinks/Out1', [engineSystem '/Engine Temperature']);
set_param([engineSystem '/Engine Temperature'], 'Position', [450, 40, 470, 60]);

add_block('simulink/Sinks/Out1', [engineSystem '/Coolant Temperature']);
set_param([engineSystem '/Coolant Temperature'], 'Position', [450, 90, 470, 110]);

% Add blocks for engine thermal dynamics
% Heat generation
add_block('simulink/Math Operations/Product', [engineSystem '/Heat Generation']);
set_param([engineSystem '/Heat Generation'], 'Position', [100, 40, 130, 70]);

% Heat dissipation
add_block('simulink/Math Operations/Product', [engineSystem '/Heat Dissipation']);
set_param([engineSystem '/Heat Dissipation'], 'Position', [200, 90, 230, 120]);

% Engine temperature integrator
add_block('simulink/Continuous/Integrator', [engineSystem '/Engine Temp Integrator']);
set_param([engineSystem '/Engine Temp Integrator'], 'Position', [350, 40, 380, 70]);
set_param([engineSystem '/Engine Temp Integrator'], 'InitialCondition', '25');

% Coolant temperature integrator
add_block('simulink/Continuous/Integrator', [engineSystem '/Coolant Temp Integrator']);
set_param([engineSystem '/Coolant Temp Integrator'], 'Position', [350, 90, 380, 120]);
set_param([engineSystem '/Coolant Temp Integrator'], 'InitialCondition', '25');

% Engine temperature gain
add_block('simulink/Math Operations/Gain', [engineSystem '/Engine Temp Gain']);
set_param([engineSystem '/Engine Temp Gain'], 'Position', [280, 40, 310, 70]);

% Coolant temperature gain
add_block('simulink/Math Operations/Gain', [engineSystem '/Coolant Temp Gain']);
set_param([engineSystem '/Coolant Temp Gain'], 'Position', [280, 90, 310, 120]);

% Connect engine dynamics blocks
add_line(engineSystem, 'Heat Input/1', 'Heat Generation/1', 'autorouting', 'on');
add_line(engineSystem, 'Flow Rate/1', 'Heat Dissipation/1', 'autorouting', 'on');
add_line(engineSystem, 'Engine Temp Integrator/1', 'Engine Temperature/1', 'autorouting', 'on');
add_line(engineSystem, 'Coolant Temp Integrator/1', 'Coolant Temperature/1', 'autorouting', 'on');
add_line(engineSystem, 'Engine Temp Gain/1', 'Engine Temp Integrator/1', 'autorouting', 'on');
add_line(engineSystem, 'Coolant Temp Gain/1', 'Coolant Temp Integrator/1', 'autorouting', 'on');

%% Create Pump Dynamics Subsystem
pumpSystem = [systemModel '/Pump Dynamics'];
add_block('simulink/Ports & Subsystems/Subsystem', pumpSystem);
set_param(pumpSystem, 'Position', [350, 280, 450, 330]);

% Delete default connections
delete_line(pumpSystem, 'In1/1', 'Out1/1');
delete_block([pumpSystem '/In1']);
delete_block([pumpSystem '/Out1']);

% Add Pump system inputs and outputs
add_block('simulink/Sources/In1', [pumpSystem '/Pump Speed']);
set_param([pumpSystem '/Pump Speed'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [pumpSystem '/Pump Parameters']);
set_param([pumpSystem '/Pump Parameters'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sinks/Out1', [pumpSystem '/Flow Rate']);
set_param([pumpSystem '/Flow Rate'], 'Position', [350, 40, 370, 60]);

add_block('simulink/Sinks/Out1', [pumpSystem '/Power Consumption']);
set_param([pumpSystem '/Power Consumption'], 'Position', [350, 90, 370, 110]);

% Add Transfer function for pump dynamics
add_block('simulink/Continuous/Transfer Fcn', [pumpSystem '/Pump Transfer Function']);
set_param([pumpSystem '/Pump Transfer Function'], 'Position', [150, 40, 250, 70]);
set_param([pumpSystem '/Pump Transfer Function'], 'Numerator', '[1]');
set_param([pumpSystem '/Pump Transfer Function'], 'Denominator', '[0.5 1]');

% Add Power calculation block
add_block('simulink/Math Operations/Math Function', [pumpSystem '/Power Calculation']);
set_param([pumpSystem '/Power Calculation'], 'Position', [150, 90, 250, 120]);
set_param([pumpSystem '/Power Calculation'], 'Operator', 'pow');

% Connect pump dynamics blocks
add_line(pumpSystem, 'Pump Speed/1', 'Pump Transfer Function/1', 'autorouting', 'on');
add_line(pumpSystem, 'Pump Speed/1', 'Power Calculation/1', 'autorouting', 'on');
add_line(pumpSystem, 'Pump Transfer Function/1', 'Flow Rate/1', 'autorouting', 'on');
add_line(pumpSystem, 'Power Calculation/1', 'Power Consumption/1', 'autorouting', 'on');

%% Create Visualization and Results Subsystem
resultsDisplay = [modelName '/Visualization & Results'];
add_block('simulink/Ports & Subsystems/Subsystem', resultsDisplay);
set_param(resultsDisplay, 'Position', [650, 300, 850, 400]);

% Delete default connections
delete_line(resultsDisplay, 'In1/1', 'Out1/1');
delete_block([resultsDisplay '/In1']);
delete_block([resultsDisplay '/Out1']);

% Add results display inputs
add_block('simulink/Sources/In1', [resultsDisplay '/Engine Temperature']);
set_param([resultsDisplay '/Engine Temperature'], 'Position', [20, 20, 40, 40]);

add_block('simulink/Sources/In1', [resultsDisplay '/Coolant Temperature']);
set_param([resultsDisplay '/Coolant Temperature'], 'Position', [20, 70, 40, 90]);

add_block('simulink/Sources/In1', [resultsDisplay '/Pump Speed']);
set_param([resultsDisplay '/Pump Speed'], 'Position', [20, 120, 40, 140]);

add_block('simulink/Sources/In1', [resultsDisplay '/Power Consumption']);
set_param([resultsDisplay '/Power Consumption'], 'Position', [20, 170, 40, 190]);

add_block('simulink/Sources/In1', [resultsDisplay '/Load Profile']);
set_param([resultsDisplay '/Load Profile'], 'Position', [20, 220, 40, 240]);

add_block('simulink/Sources/In1', [resultsDisplay '/Ambient Profile']);
set_param([resultsDisplay '/Ambient Profile'], 'Position', [20, 270, 40, 290]);

% Add Scope for engine temperature
add_block('simulink/Sinks/Scope', [resultsDisplay '/Engine Temp Scope']);
set_param([resultsDisplay '/Engine Temp Scope'], 'Position', [100, 20, 130, 50]);

% Add Scope for coolant temperature
add_block('simulink/Sinks/Scope', [resultsDisplay '/Coolant Temp Scope']);
set_param([resultsDisplay '/Coolant Temp Scope'], 'Position', [100, 70, 130, 100]);

% Add Scope for pump speed
add_block('simulink/Sinks/Scope', [resultsDisplay '/Pump Speed Scope']);
set_param([resultsDisplay '/Pump Speed Scope'], 'Position', [100, 120, 130, 150]);

% Add Scope for power consumption
add_block('simulink/Sinks/Scope', [resultsDisplay '/Power Scope']);
set_param([resultsDisplay '/Power Scope'], 'Position', [100, 170, 130, 200]);

% Add Scope for load and ambient profiles
add_block('simulink/Sinks/Scope', [resultsDisplay '/Profiles Scope']);
set_param([resultsDisplay '/Profiles Scope'], 'Position', [100, 220, 130, 250]);

% Add Display for performance metrics
add_block('simulink/Sinks/Display', [resultsDisplay '/Performance Metrics']);
set_param([resultsDisplay '/Performance Metrics'], 'Position', [200, 100, 280, 170]);

% Connect visualization blocks
add_line(resultsDisplay, 'Engine Temperature/1', 'Engine Temp Scope/1', 'autorouting', 'on');
add_line(resultsDisplay, 'Coolant Temperature/1', 'Coolant Temp Scope/1', 'autorouting', 'on');
add_line(resultsDisplay, 'Pump Speed/1', 'Pump Speed Scope/1', 'autorouting', 'on');
add_line(resultsDisplay, 'Power Consumption/1', 'Power Scope/1', 'autorouting', 'on');
add_line(resultsDisplay, 'Load Profile/1', 'Profiles Scope/1', 'autorouting', 'on');
add_line(resultsDisplay, 'Ambient Profile/1', 'Profiles Scope/2', 'autorouting', 'on');

%% Create necessary functions to support the model

% Create Fuzzy Logic Controller file
fis = setupFuzzyController();
writeFIS(fis, 'cooling_system_fis');

% Create function to train the ANN
annNet = trainANNController();
save('cooling_system_ann.mat', 'annNet');

% Connect top level model
% Add lines from dashboard to system model
add_line(modelName, [controllerParams '/Controller Selection/1'], [systemModel '/1'], 'autorouting', 'on');
add_line(modelName, [engineParams '/1'], [systemModel '/2'], 'autorouting', 'on');
add_line(modelName, [pumpParams '/1'], [systemModel '/3'], 'autorouting', 'on');
add_line(modelName, [pidParams '/1'], [systemModel '/4'], 'autorouting', 'on');
add_line(modelName, [loadParams '/Load Type/1'], [systemModel '/5'], 'autorouting', 'on');
add_line(modelName, [ambientParams '/Ambient Type/1'], [systemModel '/6'], 'autorouting', 'on');

% Connect system model to visualization
add_line(modelName, [systemModel '/1'], [resultsDisplay '/1'], 'autorouting', 'on');
add_line(modelName, [systemModel '/2'], [resultsDisplay '/2'], 'autorouting', 'on');
add_line(modelName, [systemModel '/3'], [resultsDisplay '/3'], 'autorouting', 'on');
add_line(modelName, [systemModel '/4'], [resultsDisplay '/4'], 'autorouting', 'on');
add_line(modelName, [loadParams '/Load Type/1'], [resultsDisplay '/5'], 'autorouting', 'on');
add_line(modelName, [ambientParams '/Ambient Type/1'], [resultsDisplay '/6'], 'autorouting', 'on');

%% Save the model
save_system(modelName);
fprintf('Model created successfully: %s\n', modelName);

%% Define helper functions

function fis = setupFuzzyController()
	% Create a new Fuzzy Inference System (FIS)
	fis = mamfis('Name', 'CoolingSystem');
    
	% Add input variable 'temperature_error'
	fis = addInput(fis, [-30 30], 'Name', 'temperature_error');
	fis = addMF(fis, 'temperature_error', 'trimf', [-30 -20 -10], 'Name', 'negative_large');
	fis = addMF(fis, 'temperature_error', 'trimf', [-15 -5 0], 'Name', 'negative_small');
	fis = addMF(fis, 'temperature_error', 'trimf', [-5 0 5], 'Name', 'zero');
	fis = addMF(fis, 'temperature_error', 'trimf', [0 5 15], 'Name', 'positive_small');
	fis = addMF(fis, 'temperature_error', 'trimf', [10 20 30], 'Name', 'positive_large');
    
	% Add input variable 'error_rate'
	fis = addInput(fis, [-10 10], 'Name', 'error_rate');
	fis = addMF(fis, 'error_rate', 'trimf', [-10 -5 0], 'Name', 'negative');
	fis = addMF(fis, 'error_rate', 'trimf', [-3 0 3], 'Name', 'zero');
	fis = addMF(fis, 'error_rate', 'trimf', [0 5 10], 'Name', 'positive');
    
	% Add output variable 'pump_speed_percentage'
	fis = addOutput(fis, [0 1], 'Name', 'pump_speed_percentage');
	fis = addMF(fis, 'pump_speed_percentage', 'trimf', [0 0.1 0.3], 'Name', 'very_low');
	fis = addMF(fis, 'pump_speed_percentage', 'trimf', [0.2 0.4 0.6], 'Name', 'low');
	fis = addMF(fis, 'pump_speed_percentage', 'trimf', [0.4 0.6 0.8], 'Name', 'medium');
	fis = addMF(fis, 'pump_speed_percentage', 'trimf', [0.6 0.8 0.9], 'Name', 'high');
	fis = addMF(fis, 'pump_speed_percentage', 'trimf', [0.8 1 1], 'Name', 'very_high');
    
	% Add fuzzy rules
	rule1 = "If temperature_error is positive_large OR error_rate is positive then pump_speed_percentage is very_high";
	rule2 = "If temperature_error is positive_small AND error_rate is zero then pump_speed_percentage is high";
	rule3 = "If temperature_error is zero AND error_rate is zero then pump_speed_percentage is medium";
	rule4 = "If temperature_error is negative_small AND error_rate is not positive then pump_speed_percentage is low";
	rule5 = "If temperature_error is negative_large then pump_speed_percentage is very_low";
	rule6 = "If error_rate is negative AND temperature_error is not negative_large then pump_speed_percentage is high";
    
	% Add rules to FIS
	fis = addRule(fis, [rule1; rule2; rule3; rule4; rule5; rule6]);
end

function net = trainANNController()
	% Define the parameter ranges
	temp_range = [25, 110]; 	% Engine temperature range (°C)
	load_range = [0.5, 2.0];	% Engine load range
	ambient_range = [15, 45];   % Ambient temperature range (°C)
    
	% Generate training data
	n_samples = 1000;
    
	% Generate random inputs within ranges
	engine_temps = temp_range(1) + (temp_range(2) - temp_range(1)) * rand(n_samples, 1);
	engine_loads = load_range(1) + (load_range(2) - load_range(1)) * rand(n_samples, 1);
	ambient_temps = ambient_range(1) + (ambient_range(2) - ambient_range(1)) * rand(n_samples, 1);
    
	% Create input matrix
	inputs = [engine_temps, engine_loads, ambient_temps]';
    
	% Calculate ideal pump speeds for each input combination (simplified model)
	outputs = zeros(1, n_samples);
	for i = 1:n_samples
    	% Higher engine temperature -> higher pump speed
    	temp_factor = (engine_temps(i) - 90) / 20;  % 90°C is optimal temperature
   	 
    	% Higher load -> higher pump speed
    	load_factor = engine_loads(i) - 1;
   	 
    	% Higher ambient temperature -> higher pump speed
    	ambient_factor = (ambient_temps(i) - 25) / 30;  % 25°C is base ambient temp
   	 
    	% Combined factors with some nonlinearity (simplified model)
    	ideal_speed = 0.5 + 0.5 * (temp_factor + load_factor + ambient_factor);
   	 
    	% Constrain to [0, 1] range
    	outputs(i) = min(max(ideal_speed, 0), 1);
	end
    
	% Create and configure neural network
	net = feedforwardnet([10 5]);  % 10 neurons in first hidden layer, 5 in second
	net.trainFcn = 'trainlm';  	% Levenberg-Marquardt backpropagation
	net.trainParam.epochs = 1000;
	net.trainParam.goal = 1e-5;
	net.trainParam.min_grad = 1e-7;
    
	% Train the neural network
	[net, ~] = train(net, inputs, outputs);
end

% Initialize all scopes
function initializeScopes(modelName)
	scopeBlocks = find_system(modelName, 'BlockType', 'Scope');
	for i = 1:length(scopeBlocks)
    	open_system(scopeBlocks{i}, 'force');
	end
end

% Set up the Scope configuration
function configureScopesAndDisplays(modelName)
	% Configure scopes
	engineTempScope = [modelName '/Visualization & Results/Engine Temp Scope'];
	set_param(engineTempScope, 'NumInputPorts', '1');
	set_param(engineTempScope, 'YMin', '20', 'YMax', '110');
	set_param(engineTempScope, 'YLabel', 'Temperature (°C)');
	set_param(engineTempScope, 'XLabel', 'Time (s)');
    
	coolantTempScope = [modelName '/Visualization & Results/Coolant Temp Scope'];
	set_param(coolantTempScope, 'NumInputPorts', '1');
	set_param(coolantTempScope, 'YMin', '20', 'YMax', '110');
	set_param(coolantTempScope, 'YLabel', 'Temperature (°C)');
	set_param(coolantTempScope, 'XLabel', 'Time (s)');
    
	pumpSpeedScope = [modelName '/Visualization & Results/Pump Speed Scope'];
	set_param(pumpSpeedScope, 'NumInputPorts', '1');
	set_param(pumpSpeedScope, 'YMin', '0', 'YMax', '3000');
	set_param(pumpSpeedScope, 'YLabel', 'Speed (RPM)');
	set_param(pumpSpeedScope, 'XLabel', 'Time (s)');
    
	powerScope = [modelName '/Visualization & Results/Power Scope'];
	set_param(powerScope, 'NumInputPorts', '1');
	set_param(powerScope, 'YMin', '0', 'YMax', '1');
	set_param(powerScope, 'YLabel', 'Power (kW)');
	set_param(powerScope, 'XLabel', 'Time (s)');
    
	profilesScope = [modelName '/Visualization & Results/Profiles Scope'];
	set_param(profilesScope, 'NumInputPorts', '2');
	set_param(profilesScope, 'YMin', '0', 'YMax', '50');
	set_param(profilesScope, 'YLabel', 'Load / Temperature');
	set_param(profilesScope, 'XLabel', 'Time (s)');
end

%% Configure and initialize the model
initializeScopes(modelName);
configureScopesAndDisplays(modelName);

fprintf('Simulation model setup complete. Run the model to start the simulation.\n');
fprintf('You can adjust parameters through the dashboard during simulation.\n');
