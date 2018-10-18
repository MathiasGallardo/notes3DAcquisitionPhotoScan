function  ptsPix = orthographicProject(ptsxyz,camera,options)
%performs orthograph camera projection.
%see cameraDef.m for how to specify an orthographic camera
% Inputs:
%    ptsxyz - matrix of size n*3 holding the xyz coordinates of n points in
%    camera - an orthographic camera. See cameraDef.m for how to specify one
%    of these.
%    options - options structure. This holds one field which must be set:
%    options.src_coordSystem specifies the coordinate frame of the points
%    ptsxyz. This can either be 'world' or 'camera'.
%
% Outputs: ptsPix -  matrix of size n*2 holding projected positions in pixels of the
% 3D points.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

switch options.src_coordSystem
    case {'world','scene'}
        %first transform points into camera space:
        if isfield(camera.params,'M_cam2World_inv')
            ptsCam = homoMult(camera.params.M_cam2World_inv,ptsxyz);
        else
            if isfield(camera.params,'M_world2Cam')
            ptsCam = homoMult(camera.params.M_world2Cam,ptsxyz);
            
            else
                M = [camera.params.R,camera.params.T];
                M(4,4) = 1;
                ptsCam = homoMult(M,ptsxyz);
                
            end
        end
    case 'camera'
        ptsCam=ptsxyz;
end
ptsCam_ = ptsCam;
ptsCam_=[ptsCam_,ones(size(ptsCam_,1),1)];
ptsPix=(camera.params.Prj*ptsCam_')';
ptsPix = ptsPix(:,1:2);