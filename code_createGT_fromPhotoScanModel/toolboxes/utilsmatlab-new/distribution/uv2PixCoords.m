function pixCoords = uv2PixCoords(uv,imW,imH)
%uv2PixCoords - function to transform uv coordinates to pixels. uv
%coordinates are defined in the range 0<=u,v<=1. This function transforms
%them to pixel coordinates.
% Inputs:
%    uv -  uv coordinates. This is size n*2 where n is the number of points
%    imW - image width
%    imH - image height
%    
% Outputs:
% pixCoords- pixel coordinates. This is of size n*2.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
u=uv(:,1);
v=uv(:,2);

pixCoords(:,1) = u.*imW;
pixCoords(:,2) = imH-v.*imH;


