%% Get sensitivity from SR810/830 lock-in amplifier
% Jacob A. Spies
% UC Berkeley
% 22 Nov 2023
%
% Get sensitivity from Stanford Research Systems SR810/830 lock-in 
% amplifier.
%
% Input:
%   * lock_in - GPIB object for connected lock-in amplifier
% Output:
%   * sense - String containing the sensitivity

function sens = get_sensitivity(lock_in)

    sens_list = [2; 5; 10; 20; 50; 100; 200; 500; 1; 2; 5; 10; 20; 50; ...
        100; 200; 500; 1; 2; 5; 10; 20; 50; 100; 200; 500; 1];

    sens_index = int32(str2double(query(lock_in, 'SENS?')));
    
    if sens_index < 8
        unit = " nV/fA";
    elseif sens_index < 17
        unit = " uV/pA";
    elseif sens_index < 26
        unit = " mV/nA";
    else
        unit = " V/uA";
    end
    
    sens = sens_list(sens_index+1) + unit;
    
end