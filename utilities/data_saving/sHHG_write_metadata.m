%% sHHG Write metadata file
% Jacob A. Spies
% 14 Dec 2023
%
% Function to write metadata file for given sHHG experiment
%
% Inputs:
%   * memo - String containing a memo to write in the parameter file
%   * parameters - Various experimental parameters
%       * parameters.spec.grating
%       * parameters.spec.center_wl
%       * parameters.spec.integration_time
%       * parameters.spec.temp
%       * parameters.iterations_requested
%       * parameters.iterations_completed
%       * parameters.start_time
% Output:
%   * index - Index of first unused filenumber, used in data saving
%       functions

function [index] = sHHG_write_metadata(memo,parameters)

    % Define file saving directory based on the current date
    subdir = datestr(now,'yyyy_mm_dd');
    dir = "C:\Data\sHHG\" + subdir + "\";
    
    % Check if directory exists. If not, make the directory
    if not(isfolder(dir))
        mkdir(dir)
    end
    
    % Check if filename exists, if it does increment number.
    for index = 1:999
        % Maximum of 999 data saves per day, could expand this.
        filename = sprintf('%s_%03d',datestr(now,'yyyy_mm_dd'),index);
        if not(isfile(strcat(dir,filename,'.param')))
            % The file does not exist, so break the loop
            break
        end
    end

    metadata = fopen(dir + filename + ".param",'w');
    fprintf(metadata,'trashhLAB Data Acquisition Package v0.0\r\n\r\n');
    fprintf(metadata,memo + "\r\n\r\n");

    %% Scan Parameters
    % Iterations completed
    fprintf(metadata,'Iterations Completed: %d\r\n',parameters.iterations_completed);
    % Iterations requested
    fprintf(metadata,'Iterations Requested: %d\r\n',parameters.iterations_requested);
    % Time started
    fprintf(metadata,"Time Started: " + parameters.start_time + "\r\n");
    % Time completed
    fprintf(metadata,"Time Completed: " + datestr(now) + "\r\n\r\n");

    %% Spectrometer Parameters
    fprintf(metadata,"Grating: " + parameters.spec.grating + "\r\n");
    fprintf(metadata,"Center Wavelength: " + parameters.spec.center_wl + " nm\r\n");
    fprintf(metadata,"Integration Time: " + parameters.spec.integration_time + " sec\r\n");
    fprintf(metadata,"Camera Temp: " + parameters.spec.temp + " C");

    fclose(metadata); % Close metadata file

end