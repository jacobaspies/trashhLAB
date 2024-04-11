%% Initialize Lakeshore Temperature Controller
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Initialize Lakeshore Model 335 temperature controller connected via a
% GPIB-USB adapter (currently supporting adapters from National Instruments
% and Agilent).
%
% For Agilent, board index = 7
% For National Instruments, board index = 0
% Primary address is usually 8, but can be changed on device (e.g., for
% connecting multiple GPIB devices in tandem).
%
% Inputs:
%   * board_index - Board index for GPIB-USB adapter.
%   * primary_address - Primary address of the peripheral to be connected.
% Output:
%   * lakeshore - GPIB object for Lakeshore temperature controller.

function [lakeshore] = init_lakeshore(board_index, primary_address)
    % Create GPIB Object
    lakeshore = instrfind('Type', 'gpib', 'BoardIndex', board_index, 'PrimaryAddress', primary_address, 'Tag', '');
    
    % Connect to Lakeshore Model 335 Temperature Controller
    if board_index == 7
        vendor = 'AGILENT';
    else
        vendor = 'NI';
    end
    
    if isempty(lakeshore)
        lakeshore = gpib(vendor, board_index, primary_address);
    else
        fclose(lakeshore);
        lakeshore = lakeshore(1)
    end
    
    % Connect to instrument object, lock_in.
    fopen(lakeshore);
    
    % Test communication
    try
        idn = query(lakeshore, '*IDN?')
    catch
        warning('Temperature controller not working correctly... =(');
    end
end