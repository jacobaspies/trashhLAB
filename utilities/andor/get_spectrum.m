%% Get background
% Jacob A. Spies
% UC Berkeley
% 05 Dec 2023
%
% Function to collect spectrum using an Andor spectrometer.
%
% Input:
%   * numberPixels - Number of pixels on the camera in use.
% Output:
%   * spec - Array of intensity values

function [spec] = get_spectrum(numberPixels)

    [ret] = StartAcquisition();                   
    CheckWarning(ret);
    
    [ret,gstatus]=AndorGetStatus;
    CheckWarning(ret);

    while(gstatus ~= atmcd.DRV_IDLE)
        [ret,gstatus]=AndorGetStatus;
        CheckWarning(ret);
    end
    
    [ret, spec] = GetMostRecentImage(numberPixels);
    CheckWarning(ret);
    
    [ret]=AbortAcquisition;

end