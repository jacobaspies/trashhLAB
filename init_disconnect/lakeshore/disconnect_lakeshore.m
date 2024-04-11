%% Disconnect Lakeshore Model 335 Temperature Controller
% Jacob A. Spies
% UC Berkeley
% 06 Apr 2024
%
% Disconnect from Lakeshore Model 335 temperature controller.
%
% Input:
%   * lakeshore - Object for GPIB device associated with temperature
%       controller.

function [] = disconnect_lakeshore(lakeshore)
    % Close lock-in object
    fclose(lakeshore);
    % Clean up lock-in object
    delete(lakeshore);
end