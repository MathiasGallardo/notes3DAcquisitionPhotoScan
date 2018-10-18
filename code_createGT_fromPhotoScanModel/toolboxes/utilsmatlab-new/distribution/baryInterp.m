function interpedProp = baryInterp(tris,vertProperty,barys)
%baryInterp - function which interpolates a property defined at each mesh
%vertex with barycentric interpolation.
% Syntax:  interpedProp = baryInterp(tris,vertProperty,barys)
%
% Inputs:
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    vertProperty- list of vertex properties. This is a n*d matrix where n
%    is the number of vertices and d is the dimension of the property.
%
%    barys-     barycentric coordinates of the positions of points on the
%    surface where we want the property computed. (size q*4) where q is the
%    number of query points. barys(i,:) = [faceID,b1,b2,b3]
%
% Outputs:
% interpedProp - properties computed for each query point (size q*d)
%
% Example use:
%      Msh = read3dMesh('C:\collins\data\3dmodels\texturedBox\box.obj');
%      fid = 5;
%      barysCoordds = rand(1,3);
%      barysCoordds = barysCoordds./norm(barysCoordds);
%      queryPt = [fid,barysCoordds]; %this defines a query point in terms
%      of barycentric coordinates
%      quertPtPos = baryInterp(Msh.faces,Msh.vertexPos,queryPt);
%
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
if isempty(barys)
    interpedProp = [];
    return;
end
    
interpedProp = nan(size(barys,1),size(vertProperty,2));
valids = barys(:,1)>0;
nve = barys(:,2)<-eps|barys(:,3)<-eps|barys(:,3)<-eps;

barySub = barys(valids,:);
%interpolate:
ts = tris(barySub(:,1),:);
v1 = ts(:,1);
v2 = ts(:,2);
v3 = ts(:,3);

i1 = repmat(barySub(:,2),1,size(vertProperty,2));
i2 = repmat(barySub(:,3),1,size(vertProperty,2));
i3 = repmat(barySub(:,4),1,size(vertProperty,2));

vals = vertProperty(v1,:).*i1 +...
    vertProperty(v2,:).*i2+...
    vertProperty(v3,:).*i3;

interpedProp(valids,:)=vals;
interpedProp(nve,:) = nan;



