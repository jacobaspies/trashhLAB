%% Move Zaber linear translation stage
% Jacob A. Spies
% UC Berkeley
% 06 Nov 2023
%
% Function to move Zaber linear translation stage connected to an X-MCC
% controller to a desired position in mm.
%
% Inputs:
%   * stage - Object for connected Zaber linear translation stage
%   * position - Target position in mm

function [] = move_zaber_stage(stage,position)

    import zaber.motion.Units;
    stage.moveAbsolute(position, Units.LENGTH_MILLIMETRES);

end