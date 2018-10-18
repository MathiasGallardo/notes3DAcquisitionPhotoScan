function vecsn= computeVertNorms(verts,faces)
%computeVertNorms - function to compute the surface normals at each vertex
%given a triangluation
% Syntax: vecsn= computeVertNorms(verts,faces);
%
% Inputs:
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    verts- list of vertex positions. This is a n*3 matrix where n
%    is the number of vertices.
% Outputs:
% norms - vertex normals
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

normsF=computeTriNorms(faces,verts);
%now compute the normals at the vertices:
[vertN,hasTris] = face2vertexProperty(faces,verts,normsF);
%renormalise the normals:
vecsn = normaliseVectors(vertN,2);
 