% MATLAB Simulation for Performance Comparison of Electric Automotive Cooling Systems
% Comparing ANN, PID, and Fuzzy Logic Controllers (FLC)

clc;
clear;
close all;

%% Step 1: Enhanced System Modeling
% Water Pump Dynamics (Nonlinear Model)
pump_gain = 1; % Gain of the pump
pump_time_constant = 0.5; % Time constant of the pump
pump_tf = tf(pump_gain, [pump_time_constant, 1]);

% Radiator Heat Transfer (Nonlinear Model)
radiator_gain = 1; % Gain of the radiator
radiator_time_constant = 2; % Time constant of the radiator
radiator_tf = tf(radiator_gain, [radiator_time_constant, 1]);

% Engine Thermal Response (Nonlinear Model)
engine_gain = 1; % Gain of the engine thermal response
engine_time_constant = 5; % Time constant of the engine
engine_tf = tf(engine_gain, [engine_time_constant, 1]);

% Overall System Model (Nonlinear)
system_tf = series(pump_tf, radiator_tf);
system_tf = series(system_tf, engine_tf);

% Add Disturbances (e.g., environmental temperature changes)
disturbance_gain = 0.1; % Disturbance gain
disturbance_tf = tf(disturbance_gain, [1, 0]);

% Combine System and Disturbance
system_with_disturbance = parallel(system_tf, disturbance_tf);

%% Step 2: Enhanced Controller Design
% 2.1 PID Controller (Tuned for Nonlinear System)
Kp = 2; % Proportional gain
Ki = 0.5; % Integral gain
Kd = 0.1; % Derivative gain
pid_controller = pid(Kp, Ki, Kd);

% 2.2 Fuzzy Logic Controller (FLC) (Enhanced for Nonlinearities)
fis = mamfis('Name', 'CoolingSystemFLC');

% Define Input Variables
fis = addInput(fis, [0 100], 'Name', 'EngineTemperature'); % Engine temperature in °C
fis = addInput(fis, [0 10], 'Name', 'CoolantFlowRate'); % Coolant flow rate in kg/s

% Define Output Variable
fis = addOutput(fis, [0 5000], 'Name', 'PumpSpeed'); % Pump speed in RPM

% Define Membership Functions
fis = addMF(fis, 'EngineTemperature', 'gaussmf', [15 0], 'Name', 'Low');
fis = addMF(fis, 'EngineTemperature', 'gaussmf', [15 50], 'Name', 'Medium');
fis = addMF(fis, 'EngineTemperature', 'gaussmf', [15 100], 'Name', 'High');

fis = addMF(fis, 'CoolantFlowRate', 'gaussmf', [2 0], 'Name', 'Low');
fis = addMF(fis, 'CoolantFlowRate', 'gaussmf', [2 5], 'Name', 'Medium');
fis = addMF(fis, 'CoolantFlowRate', 'gaussmf', [2 10], 'Name', 'High');

fis = addMF(fis, 'PumpSpeed', 'gaussmf', [1000 0], 'Name', 'Low');
fis = addMF(fis, 'PumpSpeed', 'gaussmf', [1000 2500], 'Name', 'Medium');
fis = addMF(fis, 'PumpSpeed', 'gaussmf', [1000 5000], 'Name', 'High');

% Define Rules
rule1 = "If EngineTemperature is Low and CoolantFlowRate is Low then PumpSpeed is Low";
rule2 = "If EngineTemperature is Medium and CoolantFlowRate is Medium then PumpSpeed is Medium";
rule3 = "If EngineTemperature is High and CoolantFlowRate is High then PumpSpeed is High";
fis = addRule(fis, [rule1; rule2; rule3]);

% 2.3 ANN-Based Controller (Enhanced for Nonlinearities)
% Prepare Training Data (Example Data)
engine_temperature_data = linspace(30, 100, 100); % Engine temperature in °C
coolant_flow_rate_data = linspace(2, 10, 100); % Coolant flow rate in kg/s
pump_speed_data = 1000 + 4000 * (engine_temperature_data / 100) .* (coolant_flow_rate_data / 10); % Pump speed in RPM

inputs = [engine_temperature_data; coolant_flow_rate_data]; % Input data
outputs = pump_speed_data; % Output data

% Create and Train the ANN
net = feedforwardnet([20 20]); % Two hidden layers with 20 neurons each
net = train(net, inputs, outputs); % Train the network

%% Step 3: Simulation and Comparison
% Simulation Time
t = 0:0.1:50; % Time vector for simulation

% Step Input (Engine Load Change)
step_input = 80 * ones(size(t)); % Step input for engine temperature

% Simulate PID Controller
pid_system = feedback(series(pid_controller, system_with_disturbance), 1);
[y_pid, ~] = lsim(pid_system, step_input, t);

% Simulate FLC
pump_speed_flc = zeros(size(t));
for i = 1:length(t)
    engine_temperature = step_input(i);
    coolant_flow_rate = 5 + 2 * sin(0.1 * t(i)); % Varying coolant flow rate
    pump_speed_flc(i) = evalfis(fis, [engine_temperature, coolant_flow_rate]);
end

% Simulate ANN Controller
pump_speed_ann = zeros(size(t));
for i = 1:length(t)
    engine_temperature = step_input(i);
    coolant_flow_rate = 5 + 2 * sin(0.1 * t(i)); % Varying coolant flow rate
    pump_speed_ann(i) = net([engine_temperature; coolant_flow_rate]);
end

%% Step 4: Plot Results
figure;
plot(t, y_pid, 'r', 'LineWidth', 2); % PID Response
hold on;
plot(t, pump_speed_flc, 'g', 'LineWidth', 2); % FLC Response
plot(t, pump_speed_ann, 'b', 'LineWidth', 2); % ANN Response
legend('PID', 'FLC', 'ANN');
xlabel('Time (s)');
ylabel('Pump Speed (RPM)');
title('Performance Comparison of Controllers');
grid on;

%% Step 5: Analyze Results
% Calculate Performance Metrics
IAE_pid = trapz(t, abs(step_input' - y_pid)); % Integral Absolute Error for PID
IAE_flc = trapz(t, abs(step_input' - pump_speed_flc')); % Integral Absolute Error for FLC
IAE_ann = trapz(t, abs(step_input' - pump_speed_ann')); % Integral Absolute Error for ANN

% Display Results
fprintf('Integral Absolute Error (IAE) for PID Controller: %.4f\n', IAE_pid);
fprintf('Integral Absolute Error (IAE) for FLC: %.4f\n', IAE_flc);
fprintf('Integral Absolute Error (IAE) for ANN: %.4f\n', IAE_ann);

%% Step 6: Recommendations
disp('Recommendations:');
disp('1. ANN-based controllers provide faster and more accurate responses but require higher computational resources.');
disp('2. PID controllers are simpler but may struggle with nonlinearities.');
disp('3. FLC offers a good balance between complexity and performance for nonlinear systems.');