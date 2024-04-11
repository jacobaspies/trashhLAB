%% THz-TDS Script
% Jacob A. Spies
% 03 Nov 2023
%
% Measurement script for performing THz-TDS (or TRTS) using a step
% acquisition scheme using a SR810/830 lock-in amplifier and Thorlabs DDS
% delay stage.

tic
clearvars -except probe device sr830 stage zaber_controller connection % Clear all variables except hardware objects
close all
start_time = datestr(now); % Measurement start time

%% Experiment Parameters
N_avg = 1; % Number of iterations requested
t_probe = 748:0.05:778; % Array of absolute time delays in ps
tc_to_wait = 3; % Number of time constants to wait
N_samples = 3; % Number of samples (i.e., averages) per point
channels = 2; % Number of channels to utilize on lock-in (X or X&Y)
save = 0; % Boolean to save data
memo = "THz-TDS Step Acquisition";

%% Initialization
% Initialize BBD303 and stage connected to Channel 1
serial_BBD303 = '103374264'; % THz spectrometer delay stage connected via USB
timeout = 60000;
if ~exist('probe')
    [probe, device] = init_BBD30X(serial_BBD303);
end

% Initialize lock-in
if ~exist('sr830')
    sr830 = init_lock_in(7,8); % Initialize SR830 w/ NI GPIB interface
end

% Disconnect lines for reference
%disconnect_BBD30X(probe, device);
%disconnect_lock_in(sr830);

% Initialize arrays and constants
t_probe = transpose(t_probe);
N_delay = length(t_probe);
tc = get_time_constant(sr830); % Query time constant from lock-in

lock_in_param = [tc; tc_to_wait; N_samples; 2];

data_X = zeros(N_delay,N_avg);
data_Y = zeros(N_delay,N_avg);

data_X_avg = zeros(N_delay,1);
data_Y_avg = zeros(N_delay,1);

% Initialize figure and axes
fig1 = figure(1);

%% Run Probe Step
for i = 1:N_avg
    i % Outputs loop number to keep track of current iteration

    [data, complete] = ...
        step_acquisition_lock_in(fig1, probe, sr830, t_probe, lock_in_param, timeout);
    
    data_X(:,i) = data(:,1);
    data_Y(:,i) = data(:,2);
    
    % Break loop if step acquisition is aborted.
    if complete < N_delay
        iterations_completed = i-1;
        break;
    end
    
    % Calculate running average
    for j = 1:N_delay
        data_X_avg(j,1) = mean(data_X(j,1:i));
        data_Y_avg(j,1) = mean(data_Y(j,1:i));
    end 

    % Plot running average
    subplot(2,2,3,'Parent',fig1)
    plot(t_probe,data_X(:,i));
    subplot(2,2,4,'Parent',fig1)
    plot(t_probe,data_Y(:,i));
end

if ~exist("iterations_completed")
    iterations_completed = i;
end

%% Clean up average
for i = 1:N_delay
    data_X_avg(i,1) = mean(data_X(i,1:iterations_completed));
    data_Y_avg(i,1) = mean(data_Y(i,1:iterations_completed));
end

figure(2);
subplot(2,1,1)
plot(t_probe,data_X_avg);
subplot(2,1,2)
plot(t_probe,data_Y_avg);

%% Save data to file
if save
    THz_save_data([t_probe data_X_avg],'.timx')
    THz_save_data([t_probe data_Y_avg],'.timy')
    THz_save_data([t_probe data_X],'.timsx')
    THz_save_data([t_probe data_Y],'.timsy')
    THz_write_metadata(sr830,memo,N_avg,tc_to_wait,N_samples,iterations_completed,start_time);
end

%% End timer
toc