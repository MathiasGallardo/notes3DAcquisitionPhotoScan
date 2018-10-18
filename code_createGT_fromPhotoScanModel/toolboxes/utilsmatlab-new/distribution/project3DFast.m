function [coords,X_camspace] = project3DFast(points,cam,flg,flg2)
%old code for projecting with DI3D cameras.

pm_proj = cam.mat3;
pv_lens = cam.pProjR2T2;
pv_rot = cam.rotation;
pv_trans = cam.translation;
if flg2 ==1
    buildScaleFactor = 1/cam.scale;
    disp('depricated');
else
    buildScaleFactor = 1;
end

%function which projects coordinates from the world frame to image
%coordinates.
%flg==1 means that we should do full projection: world->camcoords->image.
%coords are [row,column] pairs
%flg==0 means we should do world->camframe
%flg==2 means we should do camframe->image
%(c) Toby Collins 2006
%lm_P is the coordinate system transformation

%flg2: if the points are from the depth map, they need to be scaled if the
%3d build was at a reduced size (flg2=1)
%this should always be 1.
if flg==2
    localCoords=points;
else
    lm_P = zeros(4);
    lm_P(1:3,1:3) = rotconv(pv_rot);
    lm_P(1,4) = pv_trans(1);
    lm_P(2,4) = pv_trans(2);
    lm_P(3,4) = pv_trans(3);
    lm_P(4,4) = 1.0;
    lm_P=inv(lm_P);
    %qa=[pv_rot(1:3)*sin(pv_rot(4)/2);cos(pv_rot(4)/2)];
    %lm_P(1:3,1:3)=q2dcm(qa);

    if flg ==0
        coords =[points,ones(size(points,1),1)]*lm_P';
        return
    else
        localCoords=[points,ones(size(points,1),1)]*lm_P';
    end
end


X_camspace = localCoords;
localCoords(:,1:3)=localCoords(:,1:3)./(repmat(sqrt(localCoords(:,1).^2+localCoords(:,2).^2+localCoords(:,3).^2),1,3));
zs=repmat(localCoords(:,3),1,3);
localCoords(:,1:3)=localCoords(:,1:3)./zs;


ls_len2 = localCoords(:,1).*localCoords(:,1) + localCoords(:,2).*localCoords(:,2);
ls_dx = localCoords(:,1).*(pv_lens(1).*ls_len2 + pv_lens(2).*ls_len2.*ls_len2);
ls_dy = localCoords(:,2).*(pv_lens(1).*ls_len2 + pv_lens(2).*ls_len2.*ls_len2);
ls_dx = ls_dx + 2*pv_lens(3).*localCoords(:,1).*localCoords(:,2)+pv_lens(4).*(ls_len2+2.*localCoords(:,1).*localCoords(:,1));
ls_dy = ls_dy + 2*pv_lens(4).*localCoords(:,1).*localCoords(:,2)+pv_lens(3).*(ls_len2+2.*localCoords(:,2).*localCoords(:,2));
localCoords(:,1) = localCoords(:,1) + ls_dx;
localCoords(:,2) = localCoords(:,2) + ls_dy;
%
pm_proj(1:3,1:3)=(pm_proj(1:3,1:3)./buildScaleFactor);
pm_proj(3,3)=1;
tmpcoords = localCoords(:,1:3)*(pm_proj(1:3,1:3));
coords=[tmpcoords(:,2),tmpcoords(:,1)];
%'d'





