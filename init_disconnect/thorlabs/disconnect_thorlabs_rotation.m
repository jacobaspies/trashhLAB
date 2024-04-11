%% Disconnect Thorlabs Rotation Stage (K10CR1)
% Jacob A. Spies
% UC Berkeley
% 20 Nov 2023
%
% Disconnect Thorlabs K10CR1 rotation stage.
%
% Input:
%   * device - Object of Thorlabs K10CR1 rotation stage to be disconnected.

function [] = disconnect_thorlabs_rotation(device)

    %Stop connection to device
    device.StopPolling()
    device.Disconnect()

end