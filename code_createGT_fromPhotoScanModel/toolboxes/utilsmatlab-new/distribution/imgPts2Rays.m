function rs = imgPts2Rays(cam,ptsImg)
%imgPts2Rays - function to transform a list of pixels to their
%corresponding rays projecting from the COP  (in the camera's coordinate frame.) 
% Syntax: rs = imgPts2Rays(cam,ptsImg,z)
%
% Inputs:
%    cam - Camera struct. See cameraDef.m for more details on this.
%    ptsImg - list of n*2 pixel points (first column denotes rows, second
%    column denotes columns.
%    
% Outputs:
% rs- ray vectors passing from the camera's COP thruogh the pixel centres
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

switch cam.type
    case {'linear_perspective','perspective'}
        ptsCam = homoMult(inv(cam.params.K),ptsImg);
        ptsCam = [ptsCam,ones(size(ptsCam,1),1)];
        pos = zeros(size(ptsImg,1),3);
        rs=[pos,ptsCam];
end