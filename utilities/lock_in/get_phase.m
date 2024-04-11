%% Get phase from SR810/830 lock-in amplifier
% Jacob A. Spies
% UC Berkeley
% 22 Nov 2023
%
% Function that queries the phase from a Stanford Research System
% SR810/SR830 lock-in amplifier connected via GPIB-USB.
%
% Input:
%   * lock_in - GPIB object for connected lock-in amplifier
% Output:
%   * phase - Queried phase from lock-in amplifier

function phase = get_phase(lock_in)
    
    phase = str2double(query(lock_in, 'PHAS?'));
    
end