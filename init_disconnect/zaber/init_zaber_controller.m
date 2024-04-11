%% Initialize Zaber rotation stage
% Jacob A. Spies
% UC Berkeley
% 20 Nov 2023
%
% Initializes a Zaber X-MCC controller connected via ethernet with a static
% IP address (needs to be set in the Zaber Launcher).
%
% Inputs:
%   * ip - IP address of controller as a string
%   * port - port as an integer, either 55550 for controller only or 55551
%       for all devices in chain.
% Outputs:
%   * device - Object for the controller
%   * connection - Object for connection to controller, used in disconnect
%

function [device, connection] = init_zaber_controller(ip,port)

    import zaber.motion.ascii.Connection;

    connection = Connection.openTcp(ip,port);
    try
        deviceList = connection.detectDevices();
        fprintf('Found %d devices.\n', deviceList.length);
        device = deviceList(1);
    catch exception
        disp(getReport(exception));
    end
    
end