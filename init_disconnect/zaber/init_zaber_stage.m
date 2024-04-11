%% Initialize Zaber stage
% Jacob A. Spies
% UC Berkeley
% 21 Nov 2023
%
% Initializes a Zaber stage connected to an active controller. Can be used
% for both linear translation and rotation stages.
%
% Inputs:
%   * device - Object for connected X-MCC controller.
%   * index - Channel on X-MCC controller that stage is connected to.
% Output:
%   * axis - Object for connected stage.

function [axis] = init_zaber_stage(device,index)

    axis = device.getAxis(index);
    
    if ~axis.isHomed()
        axis.home();
    end

end