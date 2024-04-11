%% Get time constant from SR810/830 lock-in amplifier
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Get time constant from Stanford Research Systems SR810/830 lock-in 
% amplifier.
%
% Input:
%   * lock_in - GPIB object for connected lock-in amplifier
% Output:
%   * sense - Queried time constant in seconds

function tc = get_time_constant(lock_in)
    
    tc_list = [10e-6; 30e-6; 100e-6; 300e-6; 1e-3; 3e-3; 10e-3; 30e-3; ...
        100e-3; 300e-3; 1; 3; 10; 30; 100; 300; 1e3; 3e3; 10e3; 30e3];

    tc_index = int32(str2double(query(lock_in, 'OFLT?')));
    
    tc = tc_list(tc_index+1);
    
end