%% Write metadata file for THz measurements
% Jacob A. Spies
% UC Berkeley
% 13 Nov 2023
%
% Writes a simple metadata file for THz-TDS and OPTP measurements
% Requires the following imports
%   * Lock-in object (lock_in)
%   * Memo string (memo)
%   * A variety of scan parameters. One could be clever about making these
%       global variables or wrap them into a structure, but that has not 
%       been done in this implementation.

function THz_write_metadata(lock_in,memo,N_avg,tc_to_wait,N_samples,iterations,start_time,zaber_position)

    subdir = datestr(now,'yyyy_mm_dd');
    dir = "C:\Data\" + subdir + "\";
    
    for i = 1:9999
        % Maximum of 9999 data saves per day, could expand this if needed.
        filename = sprintf('%s_%04d',datestr(now,'yyyy_mm_dd'),i);
        if not(isfile(strcat(dir,filename,'.par')))
            % The file does not exist, so break the loop
            break
        end
    end

    metadata = fopen(dir + filename + ".par",'w');
    fprintf(metadata,'TeraMATLAB Data Acquisition Package v0.0\r\n\r\n');
    fprintf(metadata,memo + "\r\n\r\n");
    %% Scan Parameters
    % Iterations completed
    fprintf(metadata, 'Zaber Position: %6.2f mm\r\n\r\n',zaber_position);
    fprintf(metadata,'Iterations Completed: %d\r\n',iterations);
    % Iterations requested
    fprintf(metadata,'Iterations Requested: %d\r\n',N_avg);
    % Time started
    fprintf(metadata,"Time Started: " + start_time + "\r\n");
    % Time completed
    fprintf(metadata,"Time Completed: " + datestr(now) + "\r\n\r\n");
    
    %% Lock-In Parameters
    % Time Constant
    fprintf(metadata,'Time Constant: %6.2f sec\r\n',get_time_constant(lock_in));
    % Sample Rate
    fprintf(metadata,'Sample Rate: %6.2f Hz\r\n',get_sample_rate(lock_in));
    % Sensitivity
    fprintf(metadata,"Sensitivity: " + get_sensitivity(lock_in) + "\r\n");
    % Phase
    fprintf(metadata,'Phase: %6.2f deg.\r\n\r\n',get_phase(lock_in));
    
    %% Acquisition Parameters
    % Number of time constants to wait
    fprintf(metadata,'Num. Time Constants to Wait: %d\r\n',tc_to_wait);
    % Samples per point
    fprintf(metadata,'Num. Samples per Point: %d',N_samples);
    
    fclose(metadata);

end