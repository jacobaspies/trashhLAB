%% Connect shutter
% Jacob A. Spies
% 23 Jan 2024
%
% Function to connect to shutter over virtual serial port
% As of 23 Jan 2024, the available COM ports are as follows:
%   COM5 - Probe Shutter
%   COM7 - Pump Shutter
% These will be different and need to be found before using this function.
%
% Input:
%   * com_port - COM port for Thorlabs SC10 shutter controller.
% Output:
%   * shutter - Object for shutter controller.

function shutter = init_shutter(com_port)

    shutter = serialport(com_port,9600);
    configureTerminator(shutter,'CR','CR');

end