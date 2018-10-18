function camera = initPerspectiveCam(meshIn,op)
%INITPERSPECTIVECAM - function which constructs a perspective camera that centres
%its gaze on an input mesh
%
% Syntax:  camera = initCamera(meshIn,op)
%
% Inputs:
%    meshIn - an input mesh
%    op - options structure
%    this has the following fields:
%
%    op.res: [1x2] vector specifying the camera's resolution (pixels).
%    Default is op.res = [500,500]
%
% Outputs:
%    camera - A perspective camera centred on the input mesh
%
% Other m-files required:   homoMult
%                           z_buffer2
% Subfunctions: none
% MAT-files required: none
%
% See also:  cameradef.m for how to specify a perspective camera.
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008; Last revision: 20-Jan-2011

%------------- BEGIN CODE --------------


if isfield(op,'res')
    
else
    op.res = [500,500]; %X Y
end
if isfield(op,'K')
    camera.params.K  = op.K;
    fx = op.K(1,1);
    fy = op.K(2,2);
    
    
else
    fx = op.res(1)*3;
    fy = op.res(1)*3;
    ox = op.res(1)/2;
    oy = op.res(2)/2;
    %fill camera structure:
    camera.params.K = eye(3);
    camera.params.K(1,1) = fx;
    camera.params.K(2,2) = -fy;
    camera.params.K(1,3) = ox;
    camera.params.K(2,3) = oy;
    
    
end

pts_bar = mean(meshIn.vertexPos,1);

M_world2Cam = eye(4);
M_world2Cam(1:3,end) = -pts_bar;

pts_cam = homoMult(M_world2Cam,meshIn.vertexPos);




%position the camera's depth such that the mesh fills most of the image:
[xmin,xminInd] = min(pts_cam(:,1));
[ymax,ymaxInd] = max(pts_cam(:,2));
if abs(xmin)<ymax
    ind =  xminInd;
    x = pts_cam(ind,1);
    x_ = op.res(1)/5;
    z =  pts_cam(ind,3);
    delz = - z - (fx*x)/(camera.params.K(1,3) - x_);
else
    ind =  ymaxInd;
    y = pts_cam(ind,2);
    y_ = op.res(2)/5;
    z =  pts_cam(ind,3);
    delz = (fy*y)/(camera.params.K(2,3) - y_) - z;
end

M_world2Cam(3,end) = M_world2Cam(3,end)+delz;

camera.params.R = eye(3);
camera.params.T = M_world2Cam(1:3,end);
camera.type = 'perspective';

camera.pixelResH = op.res(2);
camera.pixelResW = op.res(1);
