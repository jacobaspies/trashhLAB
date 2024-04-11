%% Initialize K10CR1 Rotation Stage
% Jacob A. Spies
% UC Berkeley
% 20 Nov 2023
%
% Script to initialize K10CR1 rotation stage based on code from Truman Metz
% at Thorlabs.
%
% Inputs:
%   * serial_num - Device serial number
%   * home_bool - Boolean to indicate whether stage should be homed
%   * timeout - Timeout for rotation stage movements. Needs to be long
%       enough to home or move the stage.
% Outputs:
%   * device - Object for device

function [device] = init_thorlabs_rotation(serial_num, home_bool, timeout)

    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll');
    
    import Thorlabs.MotionControl.DeviceManagerCLI.*
    import Thorlabs.MotionControl.GenericMotorCLI.*
    import Thorlabs.MotionControl.IntegratedStepperMotorsCLI.*
    
    %Initialize Device List
    DeviceManagerCLI.BuildDeviceList();
    DeviceManagerCLI.GetDeviceListSize();
    
    %Set up device and configuration
    device = CageRotator.CreateCageRotator(serial_num);
    device.Connect(serial_num);
    device.WaitForSettingsInitialized(5000);

    motorSettings = device.LoadMotorConfiguration(serial_num);
    currentDeviceSettings = device.MotorDeviceSettings;

    motorSettings.UpdateCurrentConfiguration();
    deviceUnitConverter = device.UnitConverter();

    device.StartPolling(250);
    device.EnableDevice();
    pause(1); %wait to make sure device is enabled

    %Home device
    if home_bool
        device.Home(timeout);
        fprintf('Motor homed.\n');
    else
        fprintf('Motor not homed.\n');
    end

end