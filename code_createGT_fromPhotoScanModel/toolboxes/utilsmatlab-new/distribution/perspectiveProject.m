function ptsPix = perspectiveProject(pts,camera,options)
%performs perspective camera projection.
%see cameraDef.m for how to specify an perspective camera
% Inputs:
%    ptsxyz - matrix of size n*3 holding the xyz coordinates of n points in
%    camera - an perspective camera. See cameraDef.m for how to specify one
%    of these.
%    options - options structure. This holds one field which must be set:
%    options.src_coordSystem specifies the coordinate frame of the points
%    ptsxyz. This can either be 'world' or 'camera'.
%
% Outputs: ptsPix -  matrix of size n*2 holding projected positions of the
% 3D points.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

if isempty(pts)
    ptsPix=[];
    return;
end

switch options.src_coordSystem
    case {'world','scene'}
        %first transform points into camera space:
        if isfield(camera.params,'M_cam2World_inv')
            ptsCam = homoMult(camera.params.M_cam2World_inv,pts);
        else
            if ~isfield(camera.params,'M_world2Cam')
                M = [[camera.params.R,camera.params.T];[0,0,0,1]];
                ptsCam = homoMult(M,pts);
            else
            ptsCam = homoMult(camera.params.M_world2Cam,pts);
            end
        end
        
    case 'camera'
        ptsCam=pts;
        
end
switch camera.type
    case {'linear_perspective','perspective'};
        P = [camera.params.K,[0;0;0]]; %3x4 projection matrix      
        ptsCamH = [ptsCam,ones(size(ptsCam,1),1)];
        ptsPix = P*[ptsCamH'];
        ptsPix=ptsPix';
        ptsPix=[ptsPix(:,1)./ptsPix(:,3),ptsPix(:,2)./ptsPix(:,3)];
    case 'di3d'
        coords = project3DFast(ptsCam,camera,2,0);
        ptsPix=[coords(:,2),coords(:,1)];       
end
