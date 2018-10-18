function [barysOut,distsOut] = points2BarysKnownTri(vertexPos,tris,queryPts,quertTriInds)
%points2BarysKnownTri - function to compute the barycentric coordinates of
%a set of 3D query points from a triangluated mesh. It is assumed that the triangles which enclose these points are known.
%
% Syntax:  [barysOut,distsOut] = points2BarysKnownTri(vertexPos,tris,queryPts,quertTriInds)
%
% Inputs:
%    vertexPos- list of vertex positions. This is a n*3 matrix where n is
%    the number of vertices.
%    tris - list of mesh triangles (k*3 matrix, indexing starts at 1)
%    queryPts - list of query points in 3D. This is a q*3 matrix where q is
%    the number of query points
%    quertTriInds - list of triangle indices into tris that enclose each
%    query point. This is of size q*1.
%
% Outputs:
% barysOut- barycentric coordinates of the query points. This is size q*4,
% where barysOut(i,:) = [faceID,b1,b2,b3]
%
% distsOut - the distance from each query point to the plane defined by the
% enclosing triangle. If the query points lie on the surface, then this
% should be zero.
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
vertexPos = double(vertexPos);
queryPts = double(queryPts);

zeroLowTol =1e-10
barysOut=ones(size(queryPts,1),4)*-1;
distsOut=inf(size(queryPts,1),1);

validQs = find(quertTriInds>0);
queryPts=queryPts(validQs,:);
quertTriInds=quertTriInds(validQs,:);


%colinear causes problems

%compute sPointTRIle centres:
%barys = zeros(size(queryPts,1),4);

% for i=1:size(queryPts,1)
%     if i==253
%         'asd'
%     end

swapped = false;
t = tris(quertTriInds,:);
p1 = vertexPos(t(:,1),:);
p2 = vertexPos(t(:,2),:);
p3 = vertexPos(t(:,3),:);

if size(queryPts,2)>2
    n = (cross((p2-p1)',(p3-p1)'))';
    n=n./norm(n);
    if abs((abs(n(1))-1))<=eps
        %degenerate case: Fix this by temporarily swapping points:
        p1 = [p1(2),p1(1),p1(3)];
        p2 = [p2(2),p2(1),p2(3)];
        p3 = [p3(2),p3(1),p3(3)];
        queryPts = [queryPts(:,2),queryPts(:,1),queryPts(:,3)];
        swapped=true;
    end
end

if size(queryPts,2)>2
    n = (cross((p2-p1)',(p3-p1)'))';
    n=n./norm(n);
    c = p1;
    %a = dot(n,repmat(queryPts(:,:),size(c,1),1)-c,2);
    a = (dot((n)',(queryPts-c)'))';
    p =queryPts-repmat(a,1,3).*n;
else
    p =  queryPts;
end
A = p1(:,1)-p3(:,1);
B = p2(:,1)-p3(:,1);
C = p3(:,1)-p(:,1);
D = p1(:,2)-p3(:,2);
E = p2(:,2)-p3(:,2);
F = p3(:,2)-p(:,2);
if size(queryPts,2)>2
    G = p1(:,3)-p3(:,3);
    H = p2(:,3)-p3(:,3);
    I = p3(:,3)-p(:,3);
    alphas = (B.*(F+I)-C.*(E+H))./(A.*(E+H)-B.*(D+G));
    betas  = (A.*(F+I)-C.*(D+G))./(B.*(D+G)-A.*(E+H));
else
    alphas = (B.*(F)-C.*(E))./(A.*(E)-B.*(D));
    betas  = (A.*(F)-C.*(D))./(B.*(D)-A.*(E));
end

ff = find(alphas<0&-zeroLowTol<alphas);
alphas(ff) = 0;

ff = find(betas<0&-zeroLowTol<betas);
betas(ff) = 0;


gammas = 1-alphas-betas;
barys=[double(quertTriInds),alphas,betas,gammas];
badMatches = (~(alphas>=-zeroLowTol&betas>=-zeroLowTol&alphas+betas<=1+zeroLowTol));
barys(badMatches,:)=-1;
if size(queryPts,2)>2
    dists =a;
    distsOut(validQs,:)=dists;
end
barysOut(validQs,:)=barys;
if swapped
    barys=[barys(:,1),barys(:,3),barys(:,2),barys(:,4)];
end
