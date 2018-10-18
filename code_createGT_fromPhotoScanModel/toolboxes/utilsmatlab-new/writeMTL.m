function writeMTL(mtl_file,opts)
opts.mtlName='material1'; 
opts.kaMapName=opts.textureFileName;
opts.kdMapName=opts.textureFileName;
fid = fopen(mtl_file,'wt');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end


fprintf(fid,'# 3ds Max Wavefront OBJ Exporter v0.94b - (c)2007 guruware\n');
fprintf(fid,'# File Created: 11.04.2009 11:44:11\n');

fprintf(fid, 'newmtl %s\n', opts.mtlName);
fprintf(fid,'Ns 10.0000\n');
fprintf(fid,'Ni 1.5000\n');
fprintf(fid,'d 1.0000\n');
fprintf(fid,'Tr 1.0000\n');
fprintf(fid,'Tf 1.0000 1.0000 1.0000 \n');
fprintf(fid,'illum 2\n');
fprintf(fid,'Ka 0.0000 0.0000 0.0000\n');
fprintf(fid,'Kd 0.5882 0.5882 0.5882\n');
fprintf(fid,'Ks 0.0000 0.0000 0.0000\n');
fprintf(fid,'Ke 0.0000 0.0000 0.0000\n');
fprintf(fid, 'map_Ka %s\n', opts.kaMapName);
fprintf(fid, 'map_Kd %s\n', opts.kdMapName);
fclose(fid);
