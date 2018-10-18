function norms=computeTriNorms(tris,verts)
%computeTriNorms - function to compute the surface normals of a list of 3d
%triangles.
%triangles
% Syntax:  norms=computeTriNorms(tris,verts)
%
% Inputs:
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    verts- list of vertex positions. This is a n*3 matrix where n
%    is the number of vertices.
% Outputs:
% norms - triangle normals
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

pts1 = verts(tris(:,1),:);
pts2 = verts(tris(:,2),:);
pts3 = verts(tris(:,3),:);

v12 = pts2-pts1;
v13 = pts3-pts1;

%norms = cross(v12,v13);
nx = v12(:,2).*v13(:,3)-v12(:,3).*v13(:,2);
ny = v12(:,3).*v13(:,1)-v12(:,1).*v13(:,3);
nz = v12(:,1).*v13(:,2)-v12(:,2).*v13(:,1);

norms=[nx,ny,nz];

    
normMag = sqrt(sum(norms(:,1).^2+norms(:,2).^2+norms(:,3).^2,2));
norms= norms./repmat(normMag,1,3);



