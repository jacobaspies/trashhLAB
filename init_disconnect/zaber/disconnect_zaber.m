%% Disconnect Zaber controller
% Jacob A. Spies
% UC Berkeley
% 20 Nov 2023
%
% Disconnects a connected Zaber controller
%
% Inputs:
%   * connection - Object referring to connected controller

function [] = disconnect_zaber(controller)
    controller.close();
end