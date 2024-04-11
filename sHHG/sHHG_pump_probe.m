%% sHHG Pump Probe
% Zuerch Group
% UC Berkeley
% 14 Dec 2023
%
% Measurement script for performing a pump-probe sHHG measurement using a
% Thorlabs DDS delay stage, shutters controller by Thorlabs SC10 shutter
% controller, and an Andor spectrometer. The script also currently
% interfaces with a Lakeshore Model 335 temperature controller to log the
% temperature during the experiment. Note that shutters must be closed
% before starting measurement and will automatically close when the
% experiment is complete.

tic;
clearvars -except andor wavelength grating center_wl N_wl temperature ... % spectrometer variables
    driver analyzer zaber_controller connection delay bbd timeout pump probe lakeshore ... % device variables
    background % data variables
close all;
parameters.start_time = datestr(now); % Save start time in parameter structure

%% Measurement Parameters
% Measurement parameters
N_avg = 10; % Number of averages requested

% Time Delays
t_start = 180; % Start time delay in ps (absolute)
t_stop = 189; % Stop time delay in ps (absolute)
t_step = 0.2; % Time step in ps

% Memo line for parameter file
memo = 'Pump Probe';

% Temporal trace monitoring wavelength
td_monitor = 450; % nm

scatter = 0; % Boolean to collect scatter spectrum and do correction

%% Initialization
% Initialization Variables
serial = '103265994'; % BBD302 controller serial
timeout = 200000; % BBD302 timeout
set_temperature = -70; % iDus camera temperature (-70 C usually)
integration_time = 0.5; % Spectrometer integration time (sec)
grating = 2; % Spectrometer grating number
center_wl = 450; % Spectrometer center wavelength
shutter_wait = 0.5; % Shutter wait time after actuation
wl_index = 773; % Find index for td_monitor ((NEED TO WRITE A FUNCTION!!!))

if ~exist('andor','var') % Fix this statment, I think it has to do with an Andor folder (so specify var)
    % Init spectrometer
    disp('Spectrometer...')
    [andor, wavelength, grating, center_wl, N_wl, temperature, ret] ...
        = init_spectrometer(set_temperature);
    % Set spectrometer integration time
    set_acquisition(integration_time);
    % Set grating
    [wavelength, grating, center_wl] = set_spectrometer(andor, grating, center_wl, N_wl);
else
    disp('Spectrometer already initialized...')
end
%%
if ~exist('delay','var')
    % Init delay stage
    disp('Delay stage...')
    [delay, bbd] = init_BBD30X(serial,timeout);
else
    disp('Delay stage already initialized...')
end

if ~exist('pump','var')
    % Init pump shutter
    disp('Initializing pump shutter...')
    pump = init_shutter("COM7");
end

if ~exist('probe','var')
    % Init probe shutter
    disp('Initializing probe shutter...')
    probe = init_shutter("COM5");
end

if ~exist('lakeshore','var')
    % Init Lakeshore temperature controller
    disp('Initializing Lakeshore Model 335 temperature controller')
    lakeshore = init_lakeshore(0,12);
end

%% Declare arrays, collect background, and create figure
tpump = t_start:t_step:t_stop;
N_delay = length(tpump);

% Initialize data arrays
data.diff = zeros(N_wl,N_delay,N_avg);
data.off = zeros(N_wl,N_delay,N_avg);
data.scatter = zeros(N_wl,N_delay,N_avg);
data.temp = zeros(2,N_delay,N_avg);

data_avg.diff = zeros(N_wl,N_delay);
data_avg.off = zeros(N_wl,N_delay);
data_avg.scatter = zeros(N_wl,N_delay);
data_avg.temp = zeros(2,N_delay);

% Define structure for parameter file
parameters.spec.grating = grating;
parameters.spec.center_wl = center_wl;
parameters.spec.integration_time = integration_time;
parameters.spec.temp = set_temperature;
parameters.iterations_requested = N_avg;

if ~exist("background")
    % Collect new background with both shutters closed
    background = get_spectrum(N_wl);
end

fig = figure(1); % Important to not place in the loop for "quit" functionality
ax_diff = subplot(3,2,1);
ax_current = subplot(3,2,2);
ax_td = subplot(3,2,3);
ax_td_avg = subplot(3,2,4);
ax_contour = subplot(3,2,5);
ax_contour_avg = subplot(3,2,6);

stop_measurement = 0; % Boolean to quit measurement

enable_shutter(probe,shutter_wait); % Open probe shutter (Pump off/Probe on)

%% Run measurement
for avg = 1:N_avg
    avg
    for i = 1:N_delay
        delay.MoveTo(ps_to_mm(tpump(i)),timeout);
        pause(shutter_wait); % Wait 0.5 seconds after move.
        
        spec_off = get_spectrum(N_wl);
        
        enable_shutter(pump,shutter_wait); % Open pump shutter (Pump on/Probe on)
        spec_on = get_spectrum(N_wl);
        
        if scatter
            enable_shutter(probe,shutter_wait) % Close probe shutter (Pump on/Probe off)
            spec_scatter = get_spectrum(N_wl);
        end

        enable_shutter(pump,shutter_wait); % Close pump shutter (Pump off/Probe off)

        data.diff(:,i,avg) = spec_on - spec_off;
        data.off(:,i,avg) = spec_off - background;
        
        if scatter
            data.scatter(:,i,avg) = spec_scatter - background;
            data.diff(:,i,avg) = data.diff(:,i,avg) - spec_scatter + background;
            enable_shutter(probe,shutter_wait) % Open probe shutter (Pump on/Probe off)
        end

        data.temp(:,i,avg) = get_temperature(lakeshore);
            
        % Plot data
        plot(ax_diff,wavelength,data.diff(:,i,avg));
        plot(ax_current,wavelength,data.off(:,i,avg));
        plot(ax_td,tpump,data.diff(wl_index,:,avg));
        contourf(ax_contour,tpump,wavelength,data.diff(:,:,avg),'LineColor','none');
        drawnow;
        
        % Stop measurement if 'q' is pressed in the figure window
        if fig.CurrentCharacter == 'q'
            stop_measurement = 1;
            break;
        end

    end

    % Calculate running average or break if measurement stopped
    if stop_measurement == 0
        for i = 1:N_wl
            for j = 1:N_delay
                data_avg.diff(i,j) = sum(data.diff(i,j,:))/avg;
                data_avg.off(i,j) = sum(data.off(i,j,:))/avg;
                if scatter
                    data_avg.scatter(i,j) = sum(data.scatter(i,j,:))/avg;
                end
                if i < 3
                    data_avg.temp(i,j) = sum(data.temp(i,j,:))/avg;
                end
            end
        end
    else
        break;
    end

    % Plot running average
    plot(ax_td_avg,tpump,data_avg.diff(wl_index,:));
    contourf(ax_contour_avg,tpump,wavelength,data_avg.diff(:,:),'LineColor','none');
    drawnow;

end

enable_shutter(probe,shutter_wait) % Close probe shutter (Pump on/Probe off)

%% Clean-up and export data
% Number of iterations completed and average calculations
if stop_measurement == 1
    parameters.iterations_completed = avg - 1;
    % Calculate average for completed scans
    for i = 1:N_wl
        for j = 1:N_delay
            data_avg.diff(i,j) = sum(data.diff(i,j,1:(avg-1)))/(avg-1);
            data_avg.off(i,j) = sum(data.off(i,j,1:(avg-1)))/(avg-1);
            if scatter
                data_avg.scatter(i,j) = sum(data.scatter(i,j,1:(avg-1)))/(avg-1);
            end
            if i < 3
                data_avg.temp(i,j) = sum(data.temp(i,j,1:(avg-1)))/(avg-1);
            end
        end
    end
    % Redefine data arrays to only include completed iterations
    data.diff = data.diff(:,:,1:(avg-1));
    data.off = data.off(i,j,1:(avg-1));
    data.scatter = data.scatter(:,:,1:(avg-1));
    data.temp = data.temp(:,:,1:(avg-1));
else
    % Scan was fully completed
    parameters.iterations_completed = avg;
end

% Save anisotropy data (Note that you must write the metadata file first
% to determine the next available index.)
index = sHHG_write_metadata(memo,parameters);
axes.tpump = tpump;
filename = sprintf('%s_%03d',datestr(now,'yyyy_mm_dd'),index);
subdir = datestr(now,'yyyy_mm_dd');
dir = strcat('C:\Data\sHHG\',subdir,'\');
save(strcat(dir,filename,'.mat'));
sHHG_save_data(index, wavelength, axes, data, data_avg);

% Reset delay stage to starting position
delay.MoveTo(ps_to_mm(tpump(1)),timeout);

toc


