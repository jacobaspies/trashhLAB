%% Save Static sHHG Data
% Jacob A. Spies
% 14 Dec 2023
%
% Function that saves data from sHHG measurements to file. The function is
% generalized such that it can save static anisotropy, regular pump-probe,
% and time-resolved anisotropic sHHG (TRASHH) measurements. The type of
% measurement is determined from the contents of the data structures 
% imported (see documentation for details).
%
% Inputs:
%   * index - 
%   * wavelength - array of wavelengths
%   * axes - structure containing other axes for the measurement
%       * axes.angles - array of angles for anisotropy measurement
%       * axes.tpump - array of time delays for pump-probe measurement
%       * Note that one or both may be included as the script checks if the
%           variable exists.
%   * data_raw - structure containing raw data array
%       * (wavelength, (angles)/time, iteration, (time))
%   * data_avg - structure containing averaged data array 
%       * (wavelength, (angles)/time, (time))
%
% Notes:
%   * For time-resolved measurements, the tpump array is saving. The index
%       of each entry in tpump corresponds to the number in the filename
%       "tXXXX" so the time array needs to be reconstructed.

function [] = sHHG_save_data(index, wavelength, axes, data_raw, data_avg)

    % Define file saving directory based on the current date
    subdir = datestr(now,'yyyy_mm_dd');
    dir = strcat('C:\Data\sHHG\',subdir,'\');
    
    % Check if directory exists. If not, make the directory
    if not(isfolder(dir))
        mkdir(dir)
    end
    
    % Define filename based on previously determined index
    filename = sprintf('%s_%03d',datestr(now,'yyyy_mm_dd'),index);

    % Write wavelength and angles if files do no already exist
    if not(isfile(strcat(dir,filename,'.wl')))
        % The file does not exist, so write the file
        dlmwrite(strcat(dir,filename,'.wl'),wavelength);
    end
    
    % Check if angles exists in the axes structure and then save file if it
    % has not already been saved.
    if isfield(axes,'angles')
        if not(isfile(strcat(dir,filename,'.angle')))
            % The file does not exist, so write the file
            dlmwrite(strcat(dir,filename,'.angle'),axes.angles);
        end
    end

    % Check if t_pump exists in the axes structure and then save file if ot
    % has not already been saved
    if isfield(axes,'tpump')
        N_tpump = length(axes.tpump);
        if not(isfile(strcat(dir,filename,'.tpump')))
            % The file does not exist, so write the file
            dlmwrite(strcat(dir,filename,'.tpump'),axes.tpump);
        end
    end
    
    %% Parallel Static Anisotropy Data
    if isfield(data_avg,'par')    
        % Write the average data to file
        dlmwrite(strcat(dir,filename,'_avg.par'),data_avg.par);
        
        % Write raw data to file
        N = length(data_raw.par(1,1,:));
        
        for j = 1:N
            filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
            dlmwrite(strcat(dir,filename_raw,'.par'),data_raw.par(:,:,j));
        end
    else
        disp('Static parallel data does not exist.');
    end

    %% Perpendicular Static Anisotropy Data
    if isfield(data_avg,'perp')
        % Write the average data to file
        dlmwrite(strcat(dir,filename,'_avg.perp'),data_avg.perp);
        
        % Write raw data to file
        N = length(data_raw.perp(1,1,:));
        
        for j = 1:N
            filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
            dlmwrite(strcat(dir,filename_raw,'.perp'),data_raw.perp(:,:,j));
        end
    else
        disp('Static perpendicular data does not exist.');
    end

    %% Time-Resolved sHHG Data
    % Check if data is a pump-probe dataset
    if isfield(data_avg,'diff')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Check if data is a TRASHH dataset %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isfield(data_avg.diff,'par') % Parallel TRASHH
            %%% Write parallel differential data to file
            for k = 1:N_tpump % Loop over all collected time delays
                % Define new filename for averaged parallel TRASHH dataset
                filename_avg = sprintf('%s_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,k);
                dlmwrite(strcat(dir,filename_avg,'_avg_trashh.par'),data_avg.diff.par(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.diff.par(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_trashh.par'),data_raw.diff.par(:,:,k,j));
                end
                
                %%% Write parallel dark data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_dark.par'),data_avg.off.par(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.off.par(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_dark.par'),data_raw.off.par(:,:,k,j));
                end
                
                %%% Write parallel scatter data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_scatter.par'),data_avg.scatter.par(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.scatter.par(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_scatter.par'),data_raw.scatter.par(:,:,k,j));
                end

                %%% Write parallel temperature data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_temp.par'),data_avg.temp.par(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.temp.par(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_temp.par'),data_raw.temp.par(:,:,k,j));
                end

            end
        end

        if isfield(data_avg.diff,'perp') % Perpendicular TRASHH
            %%% Write parallel differential data to file
            for k = 1:N_tpump % Loop over all collected time delays
                % Define new filename for averaged parallel TRASHH dataset
                filename_avg = sprintf('%s_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,k);
                dlmwrite(strcat(dir,filename_avg,'_avg_trashh.perp'),data_avg.diff.perp(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.diff.perp(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_trashh.perp'),data_raw.diff.perp(:,:,k,j));
                end
                
                %%% Write parallel dark data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_dark.perp'),data_avg.off.perp(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.off.perp(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_dark.perp'),data_raw.off.perp(:,:,k,j));
                end
                
                %%% Write perpendicular scatter data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_scatter.perp'),data_avg.scatter.perp(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.scatter.perp(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_scatter.perp'),data_raw.scatter.perp(:,:,k,j));
                end
                
                %%% Write perpendicular temperature data to file
                dlmwrite(strcat(dir,filename_avg,'_avg_temp.perp'),data_avg.temp.perp(:,:,k));
                
                % Write raw data to file
                N = length(data_raw.temp.perp(1,1,k,:));
                
                for j = 1:N
                    filename_raw = sprintf('%s_%03d_%03d_t%03d',datestr(now,'yyyy_mm_dd'),index,j,k);
                    dlmwrite(strcat(dir,filename_raw,'_temp.perp'),data_raw.temp.perp(:,:,k,j));
                end

            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% If not a TRASHH measurement, export non-isotropic pump-probe %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isfield(data_avg,'diff') && ~isfield(data_avg.diff,'par') && ~isfield(data_avg.diff,'perp') % Non-anistropic pump-probe measurement
            %%% Write pump-probe data to file
            dlmwrite(strcat(dir,filename,'_avg.pmp'),data_avg.diff);
            
            % Write raw data to file
            N = length(data_raw.diff(1,1,:));
            
            for j = 1:N
                filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
                dlmwrite(strcat(dir,filename_raw,'.pmps'),data_raw.diff(:,:,j));
            end

            %%% Write dark data to file
            dlmwrite(strcat(dir,filename,'_avg.off'),data_avg.off);
            
            % Write raw data to file
            N = length(data_raw.off(1,1,:));
            
            for j = 1:N
                filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
                dlmwrite(strcat(dir,filename_raw,'.off'),data_raw.off(:,:,j));
            end
            
            %%% Write pump-probe scatter data to file
            dlmwrite(strcat(dir,filename,'_avg.scatter'),data_avg.scatter);
            
            % Write raw data to file
            N = length(data_raw.scatter(1,1,:));
            
            for j = 1:N
                filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
                dlmwrite(strcat(dir,filename_raw,'.scatter'),data_raw.scatter(:,:,j));
            end

            %%% Write pump-probe temperature data to file
            dlmwrite(strcat(dir,filename,'_avg.temp'),data_avg.temp);
            
            % Write raw data to file
            N = length(data_raw.temp(1,1,:));
            
            for j = 1:N
                filename_raw = sprintf('%s_%03d_%03d',datestr(now,'yyyy_mm_dd'),index,j);
                dlmwrite(strcat(dir,filename_raw,'.temp'),data_raw.temp(:,:,j));
            end
        end
    end

end