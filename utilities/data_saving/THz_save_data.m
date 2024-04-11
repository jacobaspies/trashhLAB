%% Data Saving Function
% Jacob A. Spies
% 13 Nov 2023
%
% Function for saving data with a automatically generated filenames based
% on the date. Also creates a directory with the date if it does not
% already exist.
%
% Inputs:
%   * data - Array of data to be saved.
%   * extension - Desired file extension for data including the "dot" 
%       (e.g., .txt or .pmp)

function [] = THz_save_data(data,extension)
    
    % Define file saving directory based on the current date
    subdir = datestr(now,'yyyy_mm_dd');
    dir = strcat('C:\Data\',subdir,'\');
    
    % Check if directory exists. If not, make the directory
    if not(isfolder(dir))
        mkdir(dir)
    end
    
    % Check if filename exists, if it does increment number.
    for i = 1:9999
        % Maximum of 9999 data saves per day, could expand this.
        filename = sprintf('%s_%04d',datestr(now,'yyyy_mm_dd'),i);
        if not(isfile(strcat(dir,filename,extension)))
            % The file does not exist, so break the loop
            break
        end
    end
    
    % Write the data
    dlmwrite(strcat(dir,filename,extension),data);

end