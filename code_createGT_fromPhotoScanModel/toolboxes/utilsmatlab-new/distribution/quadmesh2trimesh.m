function facesTri = quadmesh2trimesh(facesQuad)
%quadmesh2trimesh - function which converts a quad mesh to a triangle mesh.
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

v1s= facesQuad(:,1);
v2s= facesQuad(:,2);
v3s= facesQuad(:,3);
v4s= facesQuad(:,4);

f1s = [v1s,v2s,v3s];
f2s = [v1s,v3s,v4s];
facesTri=[f1s;f2s];



