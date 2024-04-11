%% Line Scan Measurement
% Jacob A. Spies
% 03 Nov 2023
%
% Measurement script for running a line scan using a Zaber linear
% translation stage and SR810/830 lock-in ampifier.

tic
clearvars -except probe device sr830 stage zaber_controller connection % Clear all variables except hardware objects
close all
start_time = datestr(now); % Measurement start time

%% Experiment Parameters
N_avg = 3; % Number of iterations requested
positions = 0:1:50; % Array of positions for line scan
tc_to_wait = 3; % Number of time constants to wait
N_samples = 3; % Number of samples (i.e., averages) per point
channels = 2; % Number of channels to utilize on lock-in (X or X&Y)
save = 0; % Boolean to determine whether data is saved (to be changed to a text query later)
memo = "Line scan";

%% Initialization
% Initialize BBD303 and stage connected to Channel 1
serial_BBD303 = '103374264'; % THz spectrometer delay stage connected via USB
timeout = 60000;
if ~exist('probe','var')
    [probe, device] = init_BBD30X(serial_BBD303);
end

% Initialize lock-in
if ~exist('sr830','var')
    sr830 = init_lock_in(7,8); % Initialize SR830 w/ Agilent GPIB interface
end

% Initialize Zaber sample stage
import zaber.motion.Units;
import zaber.motion.Measurement;
if ~exist('stage','var')
    [zaber_controller, connection] = init_zaber_controller('192.168.1.211',55551);
    [stage] = init_zaber_stage(zaber_controller,4);
end

%% Disconnect lines for reference
%disconnect_BBD30X(probe, device);
%disconnect_lock_in(sr830);

%% Initialize arrays and constants
positions = transpose(positions);
%pos = ps_to_mm(t_probe); % Convert time delays to positions
N_pos = length(positions);
tc = get_time_constant(sr830); % Query time constant from lock-in

lock_in_param = [tc; tc_to_wait; N_samples; 2];

data_X = zeros(N_pos,N_avg);
data_Y = zeros(N_pos,N_avg);

data_X_avg = zeros(N_pos,1);
data_Y_avg = zeros(N_pos,1);

% Initialize figure and axes
fig1 = figure(1);


%% Run Probe Step
for i = 1:N_avg
    i % Outputs loop number to keep track of current iteration
    
    [data, complete] = line_scan_lock_in(fig1,stage,sr830,positions,lock_in_param);

    data_X(:,i) = data(:,1);
    data_Y(:,i) = data(:,2);
    
    % Break loop if step acquisition is aborted.
    if complete < N_pos
        iterations_completed = i-1;
        break;
    end
    
    % Calculate running average
    for j = 1:N_pos
        data_X_avg(j,1) = mean(data_X(j,1:i));
        data_Y_avg(j,1) = mean(data_Y(j,1:i));
    end 

    % Plot running average
    subplot(2,2,3,'Parent',fig1)
    plot(positions,data_X(:,i));
    subplot(2,2,4,'Parent',fig1)
    plot(positions,data_Y(:,i));
end

if ~exist('iterations_completed','var')
    iterations_completed = i;
end

%% Clean up average
for i = 1:N_pos
    data_X_avg(i,1) = mean(data_X(i,1:iterations_completed));
    data_Y_avg(i,1) = mean(data_Y(i,1:iterations_completed));
end

figure(2);
subplot(2,1,1)
plot(positions,data_X_avg);
subplot(2,1,2)
plot(positions,data_Y_avg);

zaber_position = stage.getPosition(Units.LENGTH_MILLIMETRES);

%% Save data to file
if save
    THz_write_metadata(sr830,memo,N_avg,tc_to_wait,N_samples,iterations_completed,start_time,zaber_position);
    THz_save_data([positions data_X_avg],'.timx');
    THz_save_data([positions data_Y_avg],'.timy');
    THz_save_data([positions data_X],'.timsx');
    THz_save_data([positions data_Y],'.timsy');
end

toc