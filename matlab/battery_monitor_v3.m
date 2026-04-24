%% LiFePO4 Battery Monitor V3 — V + I + T via Serial
clear all
close all
clc

%% Open serial connection to Arduino
s = serialport('COM3', 9600);
configureTerminator(s, 'LF');
flush(s);

%% Settings
sampleTime = 1;
duration   = 120;
samples    = duration / sampleTime;

%% Initialize arrays
timeData    = zeros(1, samples);
voltageData = zeros(1, samples);
currentData = zeros(1, samples);
tempData    = zeros(1, samples);
powerData   = zeros(1, samples);

%% Setup figure
figure(1);
clf;

subplot(4,1,1);
ylabel('Voltage (V)');
title('LiFePO4 Cell — Real-Time Monitor');
grid on; hold on;
yline(3.65, 'g--', 'Full',    'LineWidth', 1.5);
yline(3.20, 'b--', 'Nominal', 'LineWidth', 1.5);
yline(3.00, 'r--', 'Low',     'LineWidth', 1.5);
ylim([2.5 3.8]);

subplot(4,1,2);
ylabel('Current (A)');
grid on; hold on;
ylim([0 1]);

subplot(4,1,3);
ylabel('Power (W)');
grid on; hold on;
ylim([0 3]);

subplot(4,1,4);
xlabel('Time (s)');
ylabel('Temp (°C)');
grid on; hold on;
ylim([20 40]);

%% Wait for Arduino ready signal
disp('Waiting for Arduino...');
while true
    line = readline(s);
    if contains(line, 'READY')
        disp('Arduino ready — starting monitor');
        break;
    end
end

%% Monitoring loop
for i = 1:samples
    % Read line from Arduino
    line = readline(s);
    
    % Parse comma separated values
    values = str2double(split(line, ','));
    
    if numel(values) == 3
        cellVoltage  = values(1);
        cellCurrent  = abs(values(2));  % abs fixes negative sign issue
        cellTemp     = values(3);
        cellPower    = cellVoltage * cellCurrent;
        
        % Store data
        timeData(i)    = (i-1) * sampleTime;
        voltageData(i) = cellVoltage;
        currentData(i) = cellCurrent;
        tempData(i)    = cellTemp;
        powerData(i)   = cellPower;
        
        % Update voltage plot
        subplot(4,1,1);
        plot(timeData(1:i), voltageData(1:i), 'b-', 'LineWidth', 2);
        drawnow;
        
        % Update current plot
        subplot(4,1,2);
        plot(timeData(1:i), currentData(1:i), 'r-', 'LineWidth', 2);
        drawnow;
        
        % Update power plot
        subplot(4,1,3);
        plot(timeData(1:i), powerData(1:i), 'm-', 'LineWidth', 2);
        drawnow;
        
        % Update temperature plot
        subplot(4,1,4);
        plot(timeData(1:i), tempData(1:i), 'g-', 'LineWidth', 2);
        drawnow;
        
        % Print to command window
        fprintf('t=%3ds | V=%6.4fV | I=%6.4fA | P=%6.4fW | T=%5.2fC\n', ...
            (i-1)*sampleTime, cellVoltage, cellCurrent, cellPower, cellTemp);
        
        % Safety warnings
        if cellVoltage < 3.0
            disp('WARNING: Cell voltage low!');
        end
        if cellTemp > 35
            disp('WARNING: Cell temperature high!');
        end
    end
end

%% Save data
results = table(timeData', voltageData', currentData', tempData', powerData', ...
    'VariableNames', {'Time_s','Voltage_V','Current_A','Temp_C','Power_W'});
writetable(results, 'battery_full_log.csv');
disp('Data saved to battery_full_log.csv');

%% Close serial port
clear s