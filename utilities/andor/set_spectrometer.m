%% Set grating and wavelength
% Jacob A. Spies
% UC Berkeley
% 05 Dec 2023
%
% Function to set the grating and center wavelength on an Andor
% spectrograph and output updated array of wavelengths.
%
% Inputs:
%   * device - Object for the connected Andor spectrograph
%   * grating - Target grating number to change to
%   * center_wl - Center wavelength in nm of spectral range to use
%   * numberPixels - Number of pixels on the Andor camera
% Outputs:
%   * wavelength - Updated array of wavelengths based on the spectrograph
%       calibration
%   * grating - Updated grating number
%   * center_wl - Updated center wavelength

function [wavelength, grating, center_wl] = set_spectrometer(device, grating, center_wl, numberPixels)

    % Set and assign grating
    disp("Setting to Grating: " + num2str(grating));
    [ret] = ATSpectrographSetGrating(device,grating);
    ATSpectrographCheckWarning(ret);
    [ret, grating] = ATSpectrographGetGrating(device);
    ATSpectrographCheckWarning(ret);

    % Set and reassign center wavelength
    disp("Setting to Center Wavelength: " + num2str(center_wl))
    [ret] = ATSpectrographSetWavelength(device,center_wl);
    ATSpectrographCheckWarning(ret);
    [ret, center_wl] = ATSpectrographGetWavelength(device);
    ATSpectrographCheckWarning(ret);

    % Get new array of wavelengths
    [ret, wavelength] = ATSpectrographGetCalibration(device, numberPixels);
    ATSpectrographCheckWarning(ret);

end