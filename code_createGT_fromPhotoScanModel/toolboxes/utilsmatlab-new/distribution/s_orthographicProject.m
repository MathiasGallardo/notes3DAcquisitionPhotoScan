function ptsPix = s_orthographicProject(ptsxyz,camera,options)
%performs scaled orthograph camera projection.
%ptsPix: first column = across, second = down

switch options.src_coordSystem
    case {'world','scene'}
        %first transform points into camera space:
        if isfield(camera.params,'M_cam2World_inv')
            ptsCam = homoMult(camera.params.M_cam2World_inv,ptsxyz);
        else
            ptsCam = homoMult(camera.params.M_world2Cam,ptsxyz);
        end
    case 'camera'
        ptsCam=ptsxyz;
end
alpha = camera.params.f./ptsCam(:,3);
ptsPix(:,1)=alpha.*ptsCam(:,1)+camera.params.offset(1);
ptsPix(:,2)=alpha.*ptsCam(:,2)+camera.params.offset(2);




