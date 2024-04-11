%% Rotate Zaber rotation stages to new symmetry plane
% Jacob A. Spies
% UC Berkeley
% 31 Mar 2024
%
% Function that moves both polarizers to a new symmetry plane for
% measurements at a specific set of rotation stage angles. Currently this
% function works for Zaber stages.
%
% Can move to probe signal both parallel ('par') or perpendicular ('perp')
% to the driving field polarization.
%
% Inputs:
%   * angle - Angle of symmetry plane
%   * orientation - Specify 'par' for parallel or 'perp' for perpendicular
%       Defaults to 'par' for all strings other than 'perp'
%   * driver - Object for MIR waveplate rotation stage
%   * analyzer - Object for UV-Vis polarizer rotation stage

function [] = rotate_symmetry(angle,orientation,driver,analyzer)

    import zaber.motion.Units;

    % Rotate driver to correct orientation
    driver.moveAbsolute(angle/2, Units.ANGLE_DEGREES, false);

    if strcmp(orientation,'perp')
        % Rotate analyzer to perpendicular orientation
        analyzer.moveAbsolute(angle+90, Units.ANGLE_DEGREES, false);
    else
        % Rotate analyzer to parallel orientation
        analyzer.moveAbsolute(angle, Units.ANGLE_DEGREES, false);
    end
    
    % Wait until both moves are completed
    driver.waitUntilIdle();
    analyzer.waitUntilIdle();

end