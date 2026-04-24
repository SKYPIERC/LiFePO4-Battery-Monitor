%% Simulation vs Real Measurement Comparison Plot
% NOTE: Run Simulink simulation first to populate 'out' variable
close all
clc

%% Load real measured data from CSV
realData    = readtable('battery_full_log.csv');
realTime    = realData.Time_s;
realVoltage = realData.Voltage_V;
realCurrent = realData.Current_A;
realPower   = realData.Power_W;

%% Extract Simscape simulation data
simTime       = out.simVoltage.time;
simVoltage    = out.simVoltage.signals.values;
simCurrentRaw = out.simCurrent.signals.values;
simCurrent    = abs(simCurrentRaw);
simPower      = simVoltage .* simCurrent;

%% Voltage comparison plot
figure(1);
clf;

subplot(3,1,1);
plot(realTime, realVoltage, 'b-', 'LineWidth', 2, 'DisplayName', 'Real Measurement');
hold on;
plot(simTime, simVoltage, 'r--', 'LineWidth', 2, 'DisplayName', 'Simscape Model');
ylabel('Voltage (V)');
title('LiFePO4 Cell — Simscape Model vs Real Measurement');
legend('Location', 'best');
grid on;
ylim([2.5 3.5]);

subplot(3,1,2);
plot(realTime, realCurrent, 'b-', 'LineWidth', 2, 'DisplayName', 'Real Measurement');
hold on;
plot(simTime, simCurrent, 'r--', 'LineWidth', 2, 'DisplayName', 'Simscape Model');
ylabel('Current (A)');
legend('Location', 'best');
grid on;
ylim([0 1]);

subplot(3,1,3);
plot(realTime, realPower, 'b-', 'LineWidth', 2, 'DisplayName', 'Real Measurement');
hold on;
plot(simTime, simPower, 'r--', 'LineWidth', 2, 'DisplayName', 'Simscape Model');
xlabel('Time (s)');
ylabel('Power (W)');
legend('Location', 'best');
grid on;
ylim([0 3]);

%% Error metrics
simV_interp = interp1(simTime, simVoltage, realTime, 'linear', 'extrap');
simI_interp = interp1(simTime, simCurrent, realTime, 'linear', 'extrap');

voltageError = realVoltage - simV_interp;
currentError = realCurrent - simI_interp;

fprintf('\n=== Model Validation Results ===\n');
fprintf('Voltage — Mean Error: %.4fV | RMSE: %.4fV\n', ...
    mean(voltageError), sqrt(mean(voltageError.^2)));
fprintf('Current — Mean Error: %.4fA | RMSE: %.4fA\n', ...
    mean(currentError), sqrt(mean(currentError.^2)));
fprintf('================================\n');

%% Save figure
saveas(figure(1), 'simulation_vs_real_comparison.png');
disp('Plot saved as simulation_vs_real_comparison.png');