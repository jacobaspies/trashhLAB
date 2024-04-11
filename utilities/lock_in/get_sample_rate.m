%% Get sample rate from SR810/830 lock-in amplifier
% Jacob A. Spies
% UC Berkeley
% 22 Nov 2023
%
% Get sample rate from Stanford Research Systems SR810/830 lock-in 
% amplifier. For simplicity, the sample rate corresponding to 'trigger' 
% simply outputs zero.
%
% Input:
%   * lock_in - GPIB object for connected lock-in amplifier
% Output:
%   * srat - Queried sample rate in Hz

function srat = get_sample_rate(lock_in)
    
    sr_list = [ 62.5e-3; 125e-3; 250e-3; 500e-3; 1; 2; 4; 8; 16; 32; ...
        64; 128; 256; 512; 0];

    sr_index = int32(str2double(query(lock_in, 'SRAT?')));
    
    srat = sr_list(sr_index+1);
    
end