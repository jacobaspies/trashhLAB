%% sHHG Align
% Zuerch Group
% UC Berkeley
% 21 Nov 2023
%
% Simple script for performing sHHG alignment. Continuously collected
% spectra until 'q' is pressed in the Figure window.

close all;

run = 1e6; % Maximum number of iterations
y_min = -20; % Minimum intensity limit for plotting
y_max = 150; % Maximum intensity limit for plotting

f = figure(1);
h = axes;
xlabel('Wavelength (nm)');
ylabel('Intensity (cps)');

for i = 1:run
    % Collect spectrum with andor spectrometer
    spectrum = get_spectrum(N_wl);

    spectrum = spectrum - background;

    avg = mean(spectrum);
    
    plot(wavelength,spectrum-avg);
    ylim([y_min y_max]);
    drawnow;
    
    % Stop acquisition when 'q' is pressed
    if f.CurrentCharacter == 'q'
        break;
    end
end