
function write_ply_asciiFast(triPoints,triTris,filename)

noFaces = size(triTris,1);
noVerts = size(triPoints,1);

%header:
s= ['ply\nformat ascii 1.0\ncomment created by MATLAB write_ply_asciiFast (c) Toby Collins 2007\nelement vertex '...
     int2str(noVerts) '\nproperty float x\nproperty float y\nproperty float z\nelement face ' ...
      'element face ' int2str(noFaces) '\nproperty list uchar short vertex_indices\nend_header'];
% ply
% format ascii 1.0
% comment created by MATLAB write_ply_asciiFast (c) Toby Collins 2007
% element vertex 7047
% property float x
% property float y
% property float z
% element face 13560
% property list uchar short vertex_indices
% end_header

fid = fopen(filename,'w');
fprintf(fid,'%s\n','ply');
fprintf(fid,'%s\n','format ascii 1.0');
fprintf(fid,'%s\n','comment created by MATLAB write_ply_asciiFast (c) Toby Collins 2007');
fprintf(fid,'%s %s\n','element vertex',int2str(noVerts));
fprintf(fid,'%s\n','property float x');
fprintf(fid,'%s\n','property float y');
fprintf(fid,'%s\n','property float z');
fprintf(fid,'%s %s\n','element face',int2str(noFaces));
fprintf(fid,'%s\n','property list uchar short vertex_indices');
fprintf(fid,'%s\n','end_header');
fclose(fid);
D1 = triPoints;
D2 = [ones(size(triTris,1),1)*3,triTris-1];

dlmwrite(filename, D1,'-append','delimiter', ' ');
dlmwrite(filename, D2,'-append','delimiter', ' ');