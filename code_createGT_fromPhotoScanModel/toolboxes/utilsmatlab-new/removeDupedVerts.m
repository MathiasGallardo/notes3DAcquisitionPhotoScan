function [newPoints,newTri,convertTable,vertIndsInOrig] = removeDupedVerts(oldPoints,oldTri)
%removeDupedVerts - function to remove duplicated vertices in a mesh
%triangulation
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008


[a,b,c] = unique(oldPoints(:,1));
g=hist(c,1:length(a));
nonduped1 = a(find(g==1));
m=oldPoints(:,1);
[C,IA1,IB] = intersect(m,nonduped1);

[a,b,c] = unique(oldPoints(:,2));
g=hist(c,1:length(a));
nonduped2 = a(find(g==1));
m=oldPoints(:,2);
[C,IA2,IB] = intersect(m,nonduped2);

if (size(oldPoints,2)==2)
    nondupedVerts = union(IA1,IA2);
else
    [a,b,c] = unique(oldPoints(:,3));
    g=hist(c,1:length(a));
    nonduped3 = a(find(g==1));
    m=oldPoints(:,3);
    [C,IA3,IB] = intersect(m,nonduped3);
    nondupedVerts = union(union(IA1,IA2),IA3);
end



dupedVerts=setdiff([1:size(oldPoints,1)],nondupedVerts);
tree = kdtree(oldPoints);

[index,nearestPoints]=kdtree_closestpoint(tree,oldPoints(dupedVerts,:));
[a,b,c] = unique(index);

inds2remove = setdiff(dupedVerts,index);
inds2keep = setdiff([1:size(oldPoints,1)],inds2remove);


convertTable= repmat([1:size(oldPoints,1)]',1,2);
convertTable(nondupedVerts,2)=[1:length(nondupedVerts)];
convertTable(dupedVerts,2)=c+length(nondupedVerts);

%newTri=oldTri(1:length(nondupedVerts),:);
newTri=oldTri;
newTri(:,1)=convertTable(oldTri(:,1),2);
newTri(:,2)=convertTable(oldTri(:,2),2);
newTri(:,3)=convertTable(oldTri(:,3),2);

newPoints=zeros(length(nondupedVerts)+length(a),3);
newPoints(1:length(nondupedVerts),:)=oldPoints(nondupedVerts,:);
newPoints(length(nondupedVerts)+1:length(nondupedVerts)+length(a),:)=oldPoints(a,:);

vertIndsInOrig = [nondupedVerts;a];


