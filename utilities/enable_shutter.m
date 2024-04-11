%% Enable/Disable Shutter
% Jacob A. Spies
% 23 Jan 2024
%
% Function to enable or disable a shutter connected to a Thorlabs SC10
% shutter controller.
%
% Inputs:
%   * shutter - Shutter object
%   * wait - Wait time after shutter actuation in seconds.

function [] = enable_shutter(shutter,wait)

    writeline(shutter,'ens');
    pause(wait);

end