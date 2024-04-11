%% Initialize BBD30X Controller and Stage
% Jacob A. Spies
% UC Berkeley
% 03 Nov 2023
%
% Function to initialize Thorlabs BBD30X direct-drive translation stage
% controller connected via USB. Currently only initializes and homes one channel, so
% modification of the code is required to initialize multiple delay stages
% connected to a BBD302 or BB303 controller. Future iterations will have
% this generalized. Example code to initialize two stages is included, but
% commented out because it has not been tested.
%
% Inputs:
%   * serial - Serial number of the Thorlabs BBD30X controller.
%   * timeout - Timeout for translation stage, needs to be long enough for
%       delay stage to home.
%   * channel - Channel to initialize.
% Outputs:
%   * Ch - Object corresponding to connected linear translation stage.
%   * device - Object corresponding to the connected BBD30X controller.

function [Ch, device] = init_BBD30X(serial,timeout,channel)
    
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.dll');
    
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.Benchtop.BrushlessMotorCLI.*
    
    DeviceManagerCLI.BuildDeviceList();
    DeviceManagerCLI.GetDeviceListSize();
    DeviceManagerCLI.GetDeviceList();

    % serial = '103374264';
    
    device = BenchtopBrushlessMotor.CreateBenchtopBrushlessMotor(serial); %;The output of this line must be suppressed
    device.Connect(serial) 

    % add an try catch that if device not connected execute device.ResetConnection(serial)
    Ch = device.GetChannel(channel);
    Ch.WaitForSettingsInitialized(10000);
    Ch.StartPolling(250);
    
    %Ch2 = device.GetChannel(2);
    %Ch2.WaitForSettingsInitialized(10000);
    %Ch2.StartPolling(250);
    
    deviceInfo = Ch.GetDeviceInfo;
    
    C = {'Connected device is', int2str(deviceInfo.SerialNumber), char(deviceInfo.Name),'\n'};
    fprintf(strjoin(C));

    % motorSettings.UpdateCurrentConfiguration();
    % Ch1.UpdateCurrentConfiguration();
    % deviceUnitConverter = Ch1.UnitConverter();
    
    Ch.EnableDevice();
    pause(1);
    %Ch2.EnableDevice();
    %pause(1); %wait to make sure Ch1 is enabled
    fprintf('Device enabled at channel 1.\n');

    % motorSettings = Ch1.LoadMotorConfiguration(serial);
    motorSettings = Ch.LoadMotorConfiguration(Ch.DeviceID);
    fprintf('Motor configuration loaded at channel 1.\n'); % Comment
    % Ch2.LoadMotorConfiguration(serial);

    if ~Ch.Status.IsHomed
        Ch.Home(timeout);
    end
    % Home_Method1(Ch1);
    %Ch2.Home();
    Ch1_homed = Ch.Status.IsHomed;
    pause(1);
end

