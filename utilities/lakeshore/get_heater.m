%% Lakeshore query heaters
% Jacob A. Spies
% UC Berkeley
% 30 Mar 2024
%
% Function to query heater readings from a LakeShore Model 335 temperature
% controller.
%
% Inputs:
%   * lakeshore - GPIB object for Lakeshore controller.
% Outputs:
%   * temp - Array of heater outputs.

function [heater] = get_heater(lakeshore)
    
    heater = zeros(2,1);
    heater(1,1) = str2double(query(lakeshore, 'HTR? 1'));
    heater(2,1) = str2double(query(lakeshore, 'HTR? 2'));

end