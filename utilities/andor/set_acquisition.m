%% Set Andor Acquisition Parameters
% Jacob A. Spies
% UC Berkeley
% 05 Dec 2023
%
% Function to set the acquisition time in seconds for a single scan 
% captured using full vertical binning (FVB).
%
% Input:
%   * integration_time - Requested integration (i.e., acquisition) time in
%       seconds.

function [] = set_acquisition(integration_time)

    disp('Configuring Acquisition...');
    [ret]=SetAcquisitionMode(1);  %   Set acquisition mode; 1 for Single Scan
    CheckWarning(ret);
    [ret]=SetReadMode(0);         % Set read mode; 0 for FVB
    CheckWarning(ret);
    [ret]=SetAcquisitionMode(1);  % Set acquisition mode; 1 for Single Scan
    CheckWarning(ret);
    [ret]=SetExposureTime(integration_time);  % Set exposure time in second
    CheckWarning(ret);
    
end