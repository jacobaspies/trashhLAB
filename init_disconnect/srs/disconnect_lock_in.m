%% Disconnect Lock-in amplifier
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Disconnect from lock-in amplifier
%
% Input:
%   * lock_in - Object for GPIB device associated with lock-in amplifier.

function [] = disconnect_lock_in(lock_in)
    % Close lock-in object
    fclose(lock_in);
    % Clean up lock-in object
    delete(lock_in);
end