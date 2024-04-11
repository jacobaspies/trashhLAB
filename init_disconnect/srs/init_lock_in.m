%% Initialize Lock-in Amplifier
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Initialize Stanford Research Systems lock-in amplifier connected via a
% GPIB-USB adapter (currently supporting adapters from National Instruments
% and Agilent). This function is compatible with both the SR810 and SR830.
%
% For Agilent, board index = 7
% For National Instruments, board index = 0
% Primary address is usually 8, but can be changed on lock-in (e.g., for
% connecting multiple lock-in amplifiers).
%
% Inputs:
%   * board_index - Board index for GPIB-USB adapter.
%   * primary_address - Primary address of the peripheral to be connected.
% Output:
%   * lock_in - GPIB object for lock-in amplifier.

function [lock_in] = init_lock_in(board_index, primary_address)
    % Create GPIB Object
    lock_in = instrfind('Type', 'gpib', 'BoardIndex', board_index, 'PrimaryAddress', primary_address, 'Tag', '');
    
    % Connect to SR810/SR830 Lock-in Amplifier
    if board_index == 7
        vendor = 'AGILENT';
    else
        vendor = 'NI';
    end
    
    if isempty(lock_in)
        lock_in = gpib(vendor, board_index, primary_address);
    else
        fclose(lock_in);
        lock_in = lock_in(1)
    end
    
    % Connect to instrument object, lock_in.
    fopen(lock_in);
    
    % Test communication
    try
        idn = query(lock_in, '*IDN?')
    catch
        warning('Lock-in not working correctly... =(');
    end
end