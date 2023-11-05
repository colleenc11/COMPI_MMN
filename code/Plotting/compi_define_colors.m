function [ clrs ] = compi_define_colors( )
% -------------------------------------------------------------------------
% COMPI_DEFINE_COLORS Defines all colors used for paper figures in the 
% COMPI study.
% -------------------------------------------------------------------------
clrs.darkred    = [0.804 0 0];  % mu3, epsi3 (#CD0000)
clrs.darkgreen  = [0 0.502 0];  % mu2, epsi2 (#008000)
clrs.lightgreen = [0 0.702 0];  % mu1 (#00B300)

clrs.darkgray   = [58 60 61]/255;       % tone ERP (#3A3C3D)
clrs.medgray    = [135 137 138]/255;    % standards (#87898A)
clrs.lightred   = [255 0 0]/255;        % deviants (#FF0000)

clrs.yellow    = [1 1 0];  
clrs.magenta    = [1 0 1];  
clrs.cyan    = [0 1 1]; 
clrs.blue = [0, 0.4470, 0.7410];
end