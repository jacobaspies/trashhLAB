%% Disconnect spectrometer
% Jacob A. Spies
% UC Berkeley
% 05 Dec 2023
%
% Disconnects the connected Andor spectrometer and camera using the proper
% warming protocol for cooled detectors (Classic and iCCD systems).

function [] = disconnect_spectrometer()

    [ret] = CoolerOFF();
    CheckError(ret);

    cooling = 1;
    while cooling
        [ret, temperature] = GetTemperature();
        % CheckWarning(ret);
        disp("Current Temperature: " + num2str(temperature) + " C");
        pause(5);

        if temperature > -20
            cooling = 0;
        end
    end

    [ret]=AndorShutDown;
    CheckWarning(ret);

    [ret] = ATSpectrographClose();
    ATSpectrographCheckWarning(ret);

    disp('Spectrometer Successfully Disconnected...')
end