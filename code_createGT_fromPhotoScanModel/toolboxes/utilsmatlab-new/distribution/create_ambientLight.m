function light = create_ambientLight(intens)
%create_ambientLight - function to create an ambient light structure
% Syntax: light = create_ambientLight(intens)
%
% Inputs:
%    intens - RBB intensity of the light (of size 1x3)
% Outputs:
% light - light structure. See lightDef.m for details on light structures.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
light = struct;
light.type = 'ambientLight';
light.intens = intens;
