function light = create_brdfLight(viewDir,intens,m)
%create_bdrfLight - function to create a specular light structure 
% Syntax: light = create_ambientLight(viewDir,intens,m)
%
% Inputs:
%    viewDir - Direction of the light (of size 1x3)
%    intens - RGB intensity of the light (of size 1x3)
%    m - roughness parameter
% Outputs:
% light - light structure.
% 
% Author: Raquel Jalvo
% email: raquel.jalvo@gmail.com
% Feb 2011

light = struct;
light.type = 'brdfLight';
light.viewDir = viewDir./norm(viewDir);
light.intens = intens;
light.m=m;

