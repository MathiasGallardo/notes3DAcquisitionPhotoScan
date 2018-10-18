function [vertProperty,hasTris] = face2vertexProperty(tris,verts,triProperties,faceAreas)
%zBufferMesh-  function to compute the corresponding vertex properties from a list of face properties. For example, call this
%if you want to compute the vertex colours, given a list of face colours.
%The method does this simply by averaging the properties of the faces that
%belong to each vertex.
%
% Syntax:  [vertProperty,hasTris] = face2vertexProperty(tris,verts,triProperties,faceAreas)
%
% Inputs:
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    verts- list of vertex positions. This is a n*3 matrix where n
%    is the number of vertices
%    triProperties - list of triangle properties (of size k*d, where d is
%    the dimensions of the property vector.
%
%    faceAreas (optional)  - list of the face areas. Use this if you want
%    to do weighted averaging based on face areas.
%
% Outputs:
%    vertProperty - list of vertex properties (of size n*d, where d is
%    the dimensions of the property vector.
%
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

noverts = size(verts,1);
notris = size(tris,1);
vertProperty=zeros(noverts,size(triProperties,2));
i1 = [tris(:,1);tris(:,2);tris(:,3)];
i2 = [[1:size(tris,1)]';[1:size(tris,1)]';[1:size(tris,1)]'];

for i=1:size(triProperties,2)
    if nargin==4
        s1 = repmat(triProperties(:,i).*faceAreas,3,1);
        s2 = repmat(faceAreas,3,1);
        S=sparse(i1,i2,s1,noverts,notris);
        SFlg=sparse(i1,i2,s2,noverts,notris);
    else
        s1 = repmat(triProperties(:,i),3,1);
        s2 = ones(size(s1,1),1);
        S=sparse(i1,i2,s1,noverts,notris);
        SFlg=sparse(i1,i2,s2,noverts,notris);    
    end    
    hasTris = find(sum(SFlg,2)>0);
    vertProperty(hasTris,i)=sum(S(hasTris,:),2)./sum(SFlg(hasTris,:),2);
end
