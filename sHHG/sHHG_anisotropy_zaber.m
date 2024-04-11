%% sHHG Anisotropy Zaber Rotation Stages
% Zuerch Group
% UC Berkeley
% 13 Dec 2023
%
% Measurement script for performing a sHHG anisotropy measurment using
% Zaber rotation stages, a probe shutter controlled by a Thorlabs SC10
% controller, an Andor spectrometer. Note that shutters must be closed when
% the experiment is started and will automatically close upon completion.
%
% Quit functionality is not yet implemented in this script.

tic;
clearvars -except andor wavelength grating center_wl N_wl temperature ... % spectrometer variables
    driver analyzer zaber_controller connection delay bbd timeout pump probe lakeshore ... % device variables
    background % data variables
close all;
import zaber.motion.Units;
import zaber.motion.Measurement;
parameters.start_time = datestr(now); % Save start time in parameter structure

%% Measurement Parameters
parallel = 1; % Boolean for parallel scan
perpendicular = 1; % Boolean for perpendicular scan
N_avg = 1; % Number of averages requested

% Measurement angles
angle_start = 156;
angle_stop  = 396;
angle_step  = 4;

% Memo for parameter/metadata file
memo = 'Dark Anisotropy';

%% Initialization
set_temperature = -70; % iDus camera temperature (-70 C usually)
integration_time = 5; % Spectrometer integration time (sec)
grating = 2; % Spectrometer grating number
center_wl = 450; % Spectrometer center wavelength
shutter_wait = 0.5;

if ~exist('andor','var')
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
if ~exist('zaber_controller','var')
    % Initialize Zaber controller
    disp('Initializing Zaber rotation stages...')
    [zaber_controller, connection] = init_zaber_controller('192.168.1.211',55551);
    % Initialize stages
    [driver] = init_zaber_stage(zaber_controller,1);
    [analyzer] = init_zaber_stage(zaber_controller,2);
else
    disp('Zaber rotation stages already initialized...')
end

if ~exist('background','var')
    % Collect new background with both shutters closed if it does not exist
    background = get_spectrum(N_wl);
end

%% Define and initialize arrays
angles = angle_start:angle_step:angle_stop; % Angle range;
N_angles = length(angles);
if parallel
    data.par = zeros(N_wl,N_angles,N_avg);
    data_avg.par = zeros(N_wl,N_angles);
end
if perpendicular
    data.perp = zeros(N_wl,N_angles,N_avg);
    data_avg.perp = zeros(N_wl,N_angles);
end

% Define structure for parameter file
parameters.spec.grating = grating;
parameters.spec.center_wl = center_wl;
parameters.spec.integration_time = integration_time;
parameters.spec.temp = set_temperature;
parameters.iterations_requested = N_avg;

% Open figure for plotting individual scans.
fig = figure(1); % Important to not place in the loop for "quit" functionality
ax_current = subplot(3,2,[1,2]);
title('Current Spectrum')
ax_par_raw = subplot(3,2,3);
title('Current Parallel');
ax_par_avg = subplot(3,2,4);
title('Average Parallel');
ax_perp_raw = subplot(3,2,5);
title('Current Perpendicular');
ax_perp_avg = subplot(3,2,6);
title('Average Perpendicular');

stop_measurement = 0;

enable_shutter(probe,shutter_wait); % Open probe shutter

for avg = 1:N_avg
    % Start averaging
    avg
    if parallel
        % Run parallel anisotropy
        for i = 1:N_angles
            % Check if measurement should be stopped
            if stop_measurement == 1
                break;
            end
            % Move polarizers and collect spectra
            driver.moveAbsolute(angles(i)/2, Units.ANGLE_DEGREES, false);
            analyzer.moveAbsolute(angles(i), Units.ANGLE_DEGREES, false);

            driver.waitUntilIdle();
            analyzer.waitUntilIdle();
            
            spec = get_spectrum(N_wl);
            data.par(:,i,avg) = spec - background;
            
            % Plot data
            plot(ax_current,wavelength,data.par(:,i,avg));
            contourf(ax_par_raw,angles,wavelength,data.par(:,:,avg),'LineColor','none');
            drawnow;

            % Stop measurement if 'q' is pressed in the figure window
            if fig.CurrentCharacter == 'q'
                stop_measurement = 1;
                break;
            end
        end % End parallel anisotropy loop

        % Calculate running average
        for i = 1:N_wl
            for j = 1:N_angles
                data_avg.par(i,j) = sum(data.par(i,j,:))/avg;
            end
        end
        % Plot running average
        contourf(ax_par_avg,angles,wavelength,data_avg.par(:,:),'LineColor','none');
        drawnow;
    end % End parallel if statement
    
    if perpendicular
        % Do perpendicular scan
        for i = 1:N_angles
            % Check if measurement should be stopped
            if stop_measurement == 1
                break;
            end
            % Move polarizers and collect spectra
            driver.moveAbsolute(angles(i)/2, Units.ANGLE_DEGREES, false);
            analyzer.moveAbsolute(angles(i)+90, Units.ANGLE_DEGREES, false);

            driver.waitUntilIdle();
            analyzer.waitUntilIdle();

            spec = get_spectrum(N_wl);
            data.perp(:,i,avg) = spec - background;
            
            % Plot data
            plot(ax_current,wavelength,data.perp(:,i,avg));
            contourf(ax_perp_raw,angles,wavelength,data.perp(:,:,avg),'LineColor','none');
            drawnow;

            % Check if measurement should be stopped
            if stop_measurement == 1
                break;
            end
        end % End perpendicular anistropy loop

        % Calculate running average
        for i = 1:N_wl
            for j = 1:N_angles
                data_avg.perp(i,j) = sum(data.perp(i,j,:))/avg;
            end
        end
        % Plot running average
        contourf(ax_perp_avg,angles,wavelength,data_avg.perp(:,:),'LineColor','none');
        drawnow;
    end % End perpendicular if statement

    if stop_measurement == 1
        break;
    end

end % End average loop

enable_shutter(probe,shutter_wait); % Close probe shutter
%% Save data and cleanup
if stop_measurement == 1
    parameters.iterations_completed = avg - 1;
    % Calculate average for completed scans
    for i = 1:N_wl
        for j = 1:N_angles
            if parallel
                data_avg.par(i,j) = mean(data.par(i,j,1:(avg-1)));
            end
            if perpendicular
                data_avg.perp(i,j) = mean(data.perp(i,j,1:(avg-1)));
            end
        end
    end
    if parallel
        data.par = data.par(:,:,1:(avg-1));
    end
    if perpendicular
        data.perp = data.perp(:,:,1:(avg-1));
    end
else
    % Scan was fully completed
    parameters.iterations_completed = avg;
end

% Save anisotropy data (Note that you must write the metadata file first
% to determine the next available index.)
index = sHHG_write_metadata(memo,parameters)
axes.angles = angles;
sHHG_save_data(index, wavelength, axes, data, data_avg);

% Reset Polarizer
driver.moveAbsolute(0, Units.ANGLE_DEGREES, false);
analyzer.moveAbsolute(0, Units.ANGLE_DEGREES, false);

driver.waitUntilIdle();
analyzer.waitUntilIdle();

toc


