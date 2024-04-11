%% sHHG TRASHH Measurements Script
% Zuerch Group
% UC Berkeley
% 25 Jan 2024
%
% Measurement script for performing time-resolved anisotropic solid-state
% high harmonic generation (TRASHH) spectroscopy using Zaber rotation
% stages, a Thorlabs DDS delay stage, shutter controlled using Thorlabs
% SC10 controllers, and an Andor spectrometer. The script also currently
% interfaces with a Lakeshore Model 335 temperature controller to log the
% temperature during the experiment.
%
% Quit functionality is still being debugged.

tic;
clearvars -except andor wavelength grating center_wl N_wl temperature ... % spectrometer variables
    driver analyzer zaber_controller connection delay bbd timeout pump probe lakeshore ... % device variables
    background % data variables
close all;
import zaber.motion.Units;
import zaber.motion.Measurement;
parameters.start_time = datestr(now); % Save start time in parameter structure

%% Measurement Parameters
% Measurement parameters
N_avg = 10; % Number of averages

% Time Delays
t0 = 183.5; % Time zero in ps on delay stage
t_pump = [1]; % Array of time delays in ps for TRASHH measurement

% Angles
angles = 156:4:396; % Array of polarization angles for anisotropy scan
parallel = 1; % Boolean to run parallel anisotropy scan
perpendicular = 1; % Boolean to run perpendicular anisotropy scan

memo = 'TRASHH'; % Memo for data saving

%% Initialization
% Initialization Variables
serial = '103265994'; % BBD302 controller serial
timeout = 600000; % BBD302 timeout
set_temperature = -70; % iDus camera temperature (-70 C usually)
integration_time = 10; % Spectrometer integration time (sec)
grating = 2; % Spectrometer grating number
center_wl = 450; % Spectrometer center wavelength
shutter_wait = 0.5; % Shutter wait time after actuation
delay_wait = 0.5; % Delay stage wait time after moving

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

if ~exist('delay','var')
    % Init delay stage
    disp('Delay stage...')
    [delay, bbd] = init_BBD30X(serial,timeout);
else
    disp('Delay stage already initialized...')
end

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
tpump = t_pump + t0;
N_delay = length(tpump);
N_angles = length(angles);

% Initialize data arrays for parallel and perpendicular TRASHH
if parallel
    data.diff.par = zeros(N_wl,N_angles,N_delay,N_avg);
    data.off.par = zeros(N_wl,N_angles,N_delay,N_avg);
    data.scatter.par = zeros(N_wl,N_angles,N_delay,N_avg);
    data.temp.par = zeros(2,N_angles,N_delay,N_avg);
    data_avg.diff.par = zeros(N_wl,N_angles,N_delay);
    data_avg.off.par = zeros(N_wl,N_angles,N_delay);
    data_avg.scatter.par = zeros(N_wl,N_angles,N_delay);
    data_avg.temp.par = zeros(2,N_angles,N_delay);
end

if perpendicular
    data.diff.perp = zeros(N_wl,N_angles,N_delay,N_avg);
    data.off.perp = zeros(N_wl,N_angles,N_delay,N_avg);
    data.scatter.perp = zeros(N_wl,N_angles,N_delay,N_avg);
    data.temp.perp = zeros(2,N_angles,N_delay,N_avg);
    data_avg.diff.perp = zeros(N_wl,N_angles,N_delay);
    data_avg.off.perp = zeros(N_wl,N_angles,N_delay);
    data_avg.scatter.perp = zeros(N_wl,N_angles,N_delay);
    data_avg.temp.perp = zeros(2,N_angles,N_delay);
end

% Define structure for parameter file
parameters.spec.grating = grating;
parameters.spec.center_wl = center_wl;
parameters.spec.integration_time = integration_time;
parameters.spec.temp = set_temperature;
parameters.iterations_requested = N_avg;

if ~exist('background','var')
    % Collect new background with both shutters closed if it does not exist
    background = get_spectrum(N_wl);
end

fig = figure(1); % Important to not place in the loop for "quit" functionality
ax_diff = subplot(3,4,[1,2]);
ax_off = subplot(3,4,[3,4]);
ax_par_diff = subplot(3,4,5);
ax_par_diff_avg = subplot(3,4,6);
ax_par_off = subplot(3,4,9);
ax_par_off_avg = subplot(3,4,10);
ax_perp_diff = subplot(3,4,7);
ax_perp_diff_avg = subplot(3,4,8);
ax_perp_off = subplot(3,4,11);
ax_perp_off_avg = subplot(3,4,12);

stop_measurement = 0; % Boolean to quit measurement


%% Run measurement
for avg = 1:N_avg
    avg
    for i = 1:N_delay
        i
        delay.MoveTo(ps_to_mm(tpump(i)),timeout); % Move delay stage
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% PARALLEL ANISOTROPY %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if parallel
            % Run parallel anisotropy
            for j = 1:N_angles
                % Check if measurement should be stopped
                if stop_measurement == 1
                    break;
                end
                % Move rotation stages
                driver.moveAbsolute(angles(j)/2, Units.ANGLE_DEGREES, false);
                analyzer.moveAbsolute(angles(j), Units.ANGLE_DEGREES, false);
                
                driver.waitUntilIdle();
                analyzer.waitUntilIdle();

                enable_shutter(probe,shutter_wait); % Open probe shutter (Pump off/Probe on)
                spec_off = get_spectrum(N_wl);
                
                enable_shutter(pump,shutter_wait); % Open pump shutter (Pump on/Probe on)
                spec_on = get_spectrum(N_wl);
                
                enable_shutter(probe,shutter_wait) % Close probe shutter (Pump on/Probe off)
                spec_scatter = get_spectrum(N_wl);
                
                enable_shutter(pump,shutter_wait); % Close pump shutter (Pump off/Probe off)

                data.temp.par(:,j,i,avg) = get_temperature(lakeshore);

                data.diff.par(:,j,i,avg) = spec_on - spec_off - spec_scatter + background;
                data.off.par(:,j,i,avg) = spec_off - background;
                data.scatter.par(:,j,i,avg) = spec_scatter - background;

                % Plot current parallel data
                plot(ax_diff,wavelength,data.diff.par(:,j,i,avg));
                plot(ax_off,wavelength,data.off.par(:,j,i,avg));
                contourf(ax_par_diff,angles,wavelength,data.diff.par(:,:,i,avg),'LineColor','none');
                contourf(ax_par_off,angles,wavelength,data.off.par(:,:,i,avg),'LineColor','none');
                drawnow;
                
                % Stop measurement if 'q' is pressed in the figure window
                if fig.CurrentCharacter == 'q'
                    stop_measurement = 1;
                    break;
                end

            end % End parallel anisotropy loop
            
            % Calculate running average for parallel anistropy
            for wl = 1:N_wl
                for j = 1:N_angles
                    data_avg.diff.par(wl,j,i) = sum(data.diff.par(wl,j,i,:))/avg;
                    data_avg.off.par(wl,j,i) = sum(data.off.par(wl,j,i,:))/avg;
                    data_avg.scatter.par(wl,j,i) = sum(data.scatter.par(wl,j,i,:))/avg;
                    if wl < 3
                        data_avg.temp.par(wl,j,i) = sum(data.temp.par(wl,j,i,:))/avg;
                    end
                end
            end
            
            % Plot running average
            contourf(ax_par_diff_avg,angles,wavelength,data_avg.diff.par(:,:,i),'LineColor','none');
            contourf(ax_par_off_avg,angles,wavelength,data_avg.off.par(:,:,i),'LineColor','none');
            drawnow;
        
        end % End parallel if statement

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%% PERPENDICULAR ANISOTROPY %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if perpendicular
            % Run perpendicular anisotropy
            for j = 1:N_angles
                % Check if measurement should be stopped
                if stop_measurement == 1
                    break;
                end
                % Move rotation stages
                driver.moveAbsolute(angles(j)/2, Units.ANGLE_DEGREES, false);
                analyzer.moveAbsolute(angles(j)+90, Units.ANGLE_DEGREES, false);
                
                driver.waitUntilIdle();
                analyzer.waitUntilIdle();

                enable_shutter(probe,shutter_wait); % Open probe shutter (Pump off/Probe on)
                spec_off = get_spectrum(N_wl);
                
                enable_shutter(pump,shutter_wait); % Open pump shutter (Pump on/Probe on)
                spec_on = get_spectrum(N_wl);
                
                enable_shutter(probe,shutter_wait) % Close probe shutter (Pump on/Probe off)
                spec_scatter = get_spectrum(N_wl);
                
                enable_shutter(pump,shutter_wait); % Close pump shutter (Pump off/Probe off)

                data.temp.perp(:,j,i,avg) = get_temperature(lakeshore);

                data.diff.perp(:,j,i,avg) = spec_on - spec_off - spec_scatter + background;
                data.off.perp(:,j,i,avg) = spec_off - background;
                data.scatter.perp(:,j,i,avg) = spec_scatter - background;
                
                % Plot current perpendicular data
                plot(ax_diff,wavelength,data.diff.perp(:,j,i,avg));
                plot(ax_off,wavelength,data.off.perp(:,j,i,avg));
                contourf(ax_perp_diff,angles,wavelength,data.diff.perp(:,:,i,avg),'LineColor','none');
                contourf(ax_perp_off,angles,wavelength,data.off.perp(:,:,i,avg),'LineColor','none');
                drawnow;

                % Stop measurement if 'q' is pressed in the figure window
                if fig.CurrentCharacter == 'q'
                    stop_measurement = 1;
                    break;
                end
            end % End perpendicular anistropy loop

            % Calculate running average for perpendicular anistropy
            for wl = 1:N_wl
                for j = 1:N_angles
                    data_avg.diff.perp(wl,j,i) = sum(data.diff.perp(wl,j,i,:))/avg;
                    data_avg.off.perp(wl,j,i) = sum(data.off.perp(wl,j,i,:))/avg;
                    data_avg.scatter.perp(wl,j,i) = sum(data.scatter.perp(wl,j,i,:))/avg;
                    if wl < 3
                        data_avg.temp.perp(wl,j,i) = sum(data.temp.perp(wl,j,i,:))/avg;
                    end
                end
            end
            
            % Plot running average
            contourf(ax_perp_diff_avg,angles,wavelength,data_avg.diff.perp(:,:,i),'LineColor','none');
            contourf(ax_perp_off_avg,angles,wavelength,data_avg.off.perp(:,:,i),'LineColor','none');
            drawnow;

        end % End perpendicular if statement
        
        % Stop measurement if 'q' is pressed in the figure window
        if fig.CurrentCharacter == 'q'
            stop_measurement = 1;
            break;
        end
    end % End of time delay loop
end % End of average loop

if stop_measurement == 1
    % Clean up averaged data
    new_avg = avg - 1;
    if parallel
        % Clean up parallel data
        data_avg.diff.par(:,:,:)
        data_avg.off.par(:,:,:)
        data_avg.scatter.par(:,:,:)
        data.diff.par(:,:,:,:)
        data.off.par(:,:,:,:)
        data.scatter.par(:,:,:,:)
    end
    if perpendicular
        % Clean up perpendicular data
        data_avg.diff.perp(:,:,:)
        data_avg.off.perp(:,:,:)
        data_avg.scatter.perp(:,:,:)
        data.diff.perp(:,:,:)
        data.off.perp(:,:,:)
        data.scatter.perp(:,:,:)
    end
end

%% Clean-up and export data
if stop_measurement == 1
    parameters.iterations_completed = avg - 1;
    % Calculate average for completed scans
    for i = 1:N_wl
        for j = 1:N_delay
            data_avg.diff(i,j) = sum(data.diff(i,j,1:(avg-1)))/(avg-1);
            data_avg.off(i,j) = sum(data.off(i,j,1:(avg-1)))/(avg-1);
            data_avg.scatter(i,j) = sum(data.scatter(i,j,1:(avg-1)))/(avg-1);
        end
    end
else
    % Scan was fully completed
    parameters.iterations_completed = avg;
end

% Save anisotropy data (Note that you must write the metadata file first
% to determine the next available index.)
index = sHHG_write_metadata(memo,parameters) % Save metadata file, set file index
% Save whole workspace as a .mat file
filename = sprintf('%s_%03d',datestr(now,'yyyy_mm_dd'),index);
subdir = datestr(now,'yyyy_mm_dd');
dir = strcat('C:\Data\sHHG\',subdir,'\');
save(strcat(dir,filename,'.mat'));
% Save data in a series of text files
axes.tpump = tpump;
axes.angles = angles;
sHHG_save_data(index, wavelength, axes, data, data_avg); % Save data to text files

% Reset delay stage to starting position
delay.MoveTo(ps_to_mm(tpump(1)),timeout);
driver.moveAbsolute(angles(1)/2, Units.ANGLE_DEGREES, false);
analyzer.moveAbsolute(angles(1), Units.ANGLE_DEGREES, false);
driver.waitUntilIdle();
analyzer.waitUntilIdle();

toc % Output total script runtime


