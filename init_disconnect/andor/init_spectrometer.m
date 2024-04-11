%% Initialize Andor Kymera Spectrometer
% Jacob A. Spies
% UC Berkeley
% 05 Dec 2023
%
% Initializes the Andor Kymera spectrometer connected via USB.
%
% Inputs:
%   * set_temperature - Target temperature to cool the detector. Function
%   checks to see if set_temperature is within the applicable range.
% Outputs:
%   * device - Identifier for device (int, usually 0).
%   * wavelength - Array of wavelengths from calibration at current grating
%   settings.
%   * grating - Current grating
%   * center_wl - Center center wavelength of grating
%   * temperature - Current detector temperature
%   * ret - Return message from spectrometer.

function [device, wavelength, grating, center_wl, numberPixels, temperature, ret] = init_spectrometer(set_temperature)
    
    % Initialize Andor iDus Camera
    disp('Initializing Andor iDus Camera...')
    ret = AndorInitialize('');
    CheckError(ret);

    % Get number of pixels and pixel width
    [ret, xSize, ~] = GetPixelSize();
    CheckError(ret);
    width = xSize;

    [ret,XPixels, ~] = GetDetector(); % Get the CCD size
    CheckWarning(ret);
    numberPixels = XPixels;

    % Initialize Andor Kymera Spectrograph
    disp('Initializing Andor Kymera Spectrograph...');
    [ret] = ATSpectrographInitialize('');
    ATSpectrographCheckError(ret);
    
    [ret, deviceCount] = ATSpectrographGetNumberDevices();
    ATSpectrographCheckWarning(ret);

    disp(['Found ', num2str(deviceCount), ' Andor Spectrographs']);
    
    for device=0:(deviceCount-1)
        [ret, serial] = ATSpectrographGetSerialNumber(device, 256);
        ATSpectrographCheckWarning(ret);
        disp(['  Spectrograph ', num2str(device), ': Serial Number: ', serial]);
    end
    
    % Get grating and center wavelength settings
    [ret, grating] = ATSpectrographGetGrating(device);
    ATSpectrographCheckWarning(ret);
    
    [ret, center_wl] = ATSpectrographGetWavelength(device);
    ATSpectrographCheckWarning(ret);
    
    % Set size and number of pixel
    [ret] = ATSpectrographSetPixelWidth(device, width);
    ATSpectrographCheckWarning(ret);

    [ret] = ATSpectrographSetNumberPixels(device, numberPixels);
    ATSpectrographCheckWarning(ret);

    % Get spectrograph calibration
    [ret, wavelength] = ATSpectrographGetCalibration(device, numberPixels);
    ATSpectrographCheckWarning(ret);

    % Camera Cooling Routine
    disp('Spectrometer Initialized...');
    disp('Cooling iDus Camera...');
    
    [ret, min_temp, max_temp] = GetTemperatureRange();
    CheckWarning(ret);

    if (set_temperature > min_temp) && (set_temperature < max_temp)
        % Set temperature
        [ret] = SetTemperature(set_temperature);
        CheckWarning(ret);
        disp("Temperature set to " + num2str(set_temperature) + " C")
    else
        disp('Temperature requested out of range. Closing spectrometer...');
        [ret]=AndorShutDown;
        CheckWarning(ret);

        [ret] = ATSpectrographClose();
        ATSpectrographCheckWarning(ret);
    end
    
    [ret] = CoolerON();
    CheckWarning(ret);
    
    cooling = 1; % Boolean to monitor temperature stabilization

    disp('Cooling...')
    while cooling
        [ret, temperature] = GetTemperature();
        % CheckWarning(ret);
        disp("Current Temperature: " + num2str(temperature) + " C");
        pause(5);

        if ret == 20036 % Temperature stabilized.
            cooling = 0;
        end
    end
    
    disp('Temperature Stabilized...');
    [ret, temperature] = GetTemperature();
    disp('Spectrometer Initialization Complete...');

end