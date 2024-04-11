%% Line Scan Measurement with Lock-In Amplifier
% Zuerch Group
% UC Berkeley
% 22 Nov 2023
%
% Function to perform line scan with Zaber translation stage and SR810/830 
% lock-in amplifier at a fixed time delay.
%
% Inputs:
%   * fig - Figure object for real time plotting
%   * stage - Object for Zaber linear translation stage
%   * lock_in - Object for SR810/830 lock-in amplifier
%   * positions - Array of positions in mm for line scan
%   * lock_in_param - Array containing lock-in parameters
% Outputs:
%   * data - Array of data collected
%   * complete - Number of iterations completed

function [data, complete] = line_scan_lock_in(fig, stage, lock_in, positions, lock_in_param)

    import zaber.motion.Units;
    
    N_pos = length(positions);

    tc = lock_in_param(1);
    tc_to_wait = lock_in_param(2);
    N_samples = lock_in_param(3);
    channels = lock_in_param(4);
    
    data = zeros(N_pos, channels);
    
    for i = 1:N_pos
        % Move to position
        stage.moveAbsolute(positions(i), Units.LENGTH_MILLIMETRES);
        
        % Wait specified number of time constants
        pause(tc*tc_to_wait);
        % Collect data from lock-in
        for k = 1:N_samples
            data(i,1) = data(i,1) + str2double(query(lock_in, 'OUTP? 1'));
            if channels == 2
                data(i,2) = data(i,2) + str2double(query(lock_in, 'OUTP? 2'));
            end
        end
        
        % Average data point for number of samples collected
        data(i,1) = data(i,1)/N_samples;
        if channels == 2
            data(i,2) = data(i,2)/N_samples;
        end

        % Add plotting command and update for each data point collected
        subplot(2,2,1,'Parent',fig)
        scatter(positions,data(:,1));
        subplot(2,2,2,'Parent',fig)
        scatter(positions,data(:,2));
        
        % Break data acquisition
        if fig.CurrentCharacter == 'q'
            break;
        end
    end
    
    complete = i; % Boolean used to mark if an iteration is complete
    
    % Reset stage position
    stage.moveAbsolute(positions(1), Units.LENGTH_MILLIMETRES);

end