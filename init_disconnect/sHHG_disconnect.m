%% sHHG Disconnect
% Jacob A. Spies
% UC Berkeley
% 13 Dec 2023
%
% A collection of function to disconnect peripherals for sHHG measurements.
% Need to comment/uncomment based on what devices are used in the
% particular instrument.

%disconnect_thorlabs_rotation(driver); clear driver;
%disconnect_thorlabs_rotation(analyzer); clear analyzer;
disconnect_zaber(connection); clear zaber_controller connection driver analyzer;
disconnect_BBD30X(delay, bbd); clear delay bbd;

disconnect_spectrometer; clear andor; % Disconnects the spectrometer.

clear;  
close all;