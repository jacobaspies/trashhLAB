%% Disconnect BBD30X Controller and Stages
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Disconnect BBD30X controller and and clean up. Currently only implemented
% for a single channel.
%
% Inputs:
%   * Ch1 - Object of linear translation stage to be disconnected.
%   * device - Object of BBD30X controller to be disconnected. 

function [] = disconnect_BBD30X(Ch1, device)
    Ch1.StopPolling();
    Ch1.DisableDevice();
    device.Disconnect();
end