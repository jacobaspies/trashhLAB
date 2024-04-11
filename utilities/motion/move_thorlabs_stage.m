%% Move Thorlabs DDS delay stage
% Jacob A. Spies
% UC Berkeley
% 06 Nov 2023
%
% Function to move Thorlabs DDS linear translation stage connected to a
% BBD30X controller connected via USB to a desired absolute time delay.
%
% Inputs:
%   * time - Absolute target delay time delay in ps
%   * stage - Object from connected Thorlabs DDS stage
%   * timeout - Timeout required for Thorlabs DDS stage

function [] = move_thorlabs_stage(time,stage,timeout)

    position = ps_to_mm(time);
    stage.MoveTo(position, timeout);
    
end