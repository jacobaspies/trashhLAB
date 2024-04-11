%% Lakeshore query temperature setpoint
% Jacob A. Spies
% UC Berkeley
% 30 Mar 2024
%
% Function to query the temperature setpoint from a LakeShore Model 335 
% temperature controller.
%
% Inputs:
%   * lakeshore - GPIB object for LakeShore controller.
% Outputs:
%   * setpoint - Temperature setpoint in K

function [setpoint] = get_set_point(lakeshore)
    
    setpoint = str2double(query(lakeshore, 'SETP? 1'));

end