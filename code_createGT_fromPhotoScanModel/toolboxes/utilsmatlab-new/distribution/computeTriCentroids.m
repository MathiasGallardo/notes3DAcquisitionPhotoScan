function cs = computeTriCentroids(verts,tris)
%computeTriCentroids - function to compute the centroids of a set of
%triangles
% Syntax:   cs = computeTriCentroids(verts,tris)
%
% Inputs:
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    verts- list of vertex positions. This is a n*3 matrix where n
%    is the number of vertices.
% Outputs:
% cs - triangle centres
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

cs = (verts(tris(:,1),:)+verts(tris(:,2),:)+verts(tris(:,3),:))/3;
