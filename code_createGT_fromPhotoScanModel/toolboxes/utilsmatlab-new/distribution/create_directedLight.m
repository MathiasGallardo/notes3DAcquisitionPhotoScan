function light = create_directedLight(viewDir,intens)
%create_directedLight - function to create a directional light structure
% Syntax: light = create_directedLight(viewDir,intens)
%
% Inputs:
%    viewDir - viewing direction of the light (normalised to unit length)
%    intens - RBB intensity of the light source (of size 1x3)
% Outputs:
% light - light structure. See lightDef.m for details on light structures.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

light = struct;
light.type = 'directedLight';
light.viewDir = viewDir./norm(viewDir);
light.intens = intens;