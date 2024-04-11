%% Lakeshore query temperatures
% Jacob A. Spies
% UC Berkeley
% 30 Mar 2024
%
% Function to query temperature readings for both A (sample) and B (cold
% head) from LakeShore Model 335 temperature controller.
%
% Inputs:
%   * lakeshore - GPIB object for LakeShore controller.
% Outputs:
%   * temp - Arrays of temperatures for the A and B sensors.

function [temp] = get_temperature(lakeshore)
    
    temp = zeros(2,1);
    temp(1,1) = str2double(query(lakeshore, 'KRDG? A'));
    temp(2,1) = str2double(query(lakeshore, 'KRDG? B'));

end