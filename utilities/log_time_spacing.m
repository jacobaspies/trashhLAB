%% Define logarithmic time spacing for an arbitrary time-zero
% Jacob A. Spies
% UC Berkeley
% 14 Mar 2024
%
% Function that returns an array of logarithmically spaced time delays for
% an arbitrary time-zero using a fixed initial spacing. Units are in
% picoseconds (ps).
%
% Inputs:
%   t_0 - Time zero on absolute delay stage scale (ps)
%   init_spacing - Initial spacing (ps)
%   num_init - Number of points with initial spacing before and after time zero
%   num_baseline - Number of additional baseline points (pre-time zero)
%   t_stop - Delay time to stop (ps)
% Outputs:
%   delays - Array of delays adjusted to the determine time zero
%   t_pump - Array of delays not adjusted to time zero (for plotting)
%   N_pts - Number of points in the array of delays

function [delays, t_pump, N_pts] = log_time_spacing(t_0, init_spacing, num_init, num_baseline, pre_baseline, t_stop, N_log)

    % Define initial points (baseline and earlier time delays)
    t = -init_spacing*num_baseline:init_spacing:init_spacing*num_init;

    % Define post time-zero points
    start = log10(t(end)); 
    stop = log10(t_stop);
    
    % logspace(a,b,n) generates n points between decades 10^a and 10^b
    temp = logspace(start,stop,N_log);

    % Find first index where logarithmic difference is greater than the
    % defined spacing
    for i = 1:length(temp)
        if (temp(i+1) - temp(i)) > init_spacing
            break;
        end
    end
    
    t_baseline = t(1)-(pre_baseline*init_spacing*10):init_spacing*10:t(1)-(init_spacing*10);

    % Calculate array of delays and adjust for determined time zero
    t_pump = [t_baseline t temp(i+1:end)];
    delays = t_pump + t_0;

    N_pts = length(t_pump);

end