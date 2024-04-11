%% Rotate Zaber Stage
% Jacob A. Spies
% 25 Mar 2024
%
% Function to rotate Zaber rotation stage connected to an X-MCC
% controller to a desired angle in degrees.
%
% Inputs:
%   * stage - Object for connected Zaber rotation stage
%   * position - Target angle in degrees

function [] = rotate_zaber_stage(stage,angle)

    import zaber.motion.Units;
    stage.moveAbsolute(angle, Units.ANGLE_DEGREES);
    
end