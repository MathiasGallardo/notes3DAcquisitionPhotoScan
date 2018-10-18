function write_obj2(filename,Msh, options)
%modified by collins

% write_off - write a mesh to an OBJ file
%
%   write_obj(filename, vertex, face, options)
%
%   vertex must be of size [n,3]
%   face must be of size [p,3]
%
%   Copyright (c) 2004 Gabriel Peyr?

if nargin<3
    options.null = 0;
end
vertex=Msh.vertexPos;
face=Msh.faces;
if size(vertex,2)~=3
    vertex=vertex';
end
if size(vertex,2)~=3
    error('vertex does not have the correct format.');
end


if size(face,2)~=3
    face=face';
end
if size(face,2)~=3
    error('face does not have the correct format.');
end

fid = fopen(filename,'wt');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

object_name = filename(1:end-4);
if isfield(Msh.texMap,'img')
    if ~isfield(Msh,'mtlFile')
    [aa,ab,ac] = fileparts(filename);
%    textureName = [aa '/' ab '.tif'];
%    mtlName = [aa '/' ab '.mtl'];
    textureName = [ab '.tif'];
    mtlName = [ab '.mtl'];
    if ischar(Msh.texMap.img)
        mtlOpts.textureFileName=Msh.texMap.img;       
    else
        imwrite(Msh.texMap.img,[aa '/' textureName]);
        mtlOpts.textureFileName=textureName;       
    end
    
    writeMTL([aa '/' mtlName],mtlOpts);
    [aa,ab,ac] = fileparts(mtlName);
    Msh.mtlFile.path=aa;
    Msh.mtlFile.fname=[ab ac];
    Msh.mtlFile.usemtl='material1';
    end
end

fprintf(fid, '# write_obj (c) 2008 Toby Collins\n');

if isfield(Msh,'mtlFile')
    %fprintf(fid, 'mtllib ./%s\n', Msh.mtlFile.fname);
    pp = [Msh.mtlFile.fname];
    fprintf(fid, 'mtllib %s\n', pp);
end
if isfield(Msh,'ID')
    object_name = Msh.ID;
else
    object_name = 'mshobj';
end




fprintf(fid, ['\n#\n# object ' object_name '\n#\n']);
fprintf(fid, ['g ' object_name '\n']);

if isfield(Msh,'mtlFile')
fprintf(fid, ['usemtl ' Msh.mtlFile.usemtl '\n']);
end


% vertex position
fprintf(fid, '# %d vertex\n', size(vertex,1));
fprintf(fid, 'v %f %f %f\n', vertex');

% vertex texture
if isfield(Msh.texMap,'vertexUVW')
    switch size(Msh.texMap.vertexUVW,2)
        case 2
             fprintf(fid, 'vt %f %f\n', Msh.texMap.vertexUVW');
        case 3
             fprintf(fid, 'vt %f %f %f\n', Msh.texMap.vertexUVW');
        otherwise
            error('bad texture vertex format');
            
    end   
   
%     nvert = size(vertex,1);
%     object_texture = zeros(nvert, 2);
%     m = ceil(sqrt(nvert));
%     if m^2~=nvert
%         error('To use normal map the number of vertex must be a square.');
%     end
%     x = 0:1/(m-1):1;
%     [Y,X] = meshgrid(x,x);
%     object_texture(:,1) = Y(:);
%     object_texture(:,2) = X(end:-1:1);
%     fprintf(fid, 'vt %f %f\n', object_texture');
else
    % create dummy vertex texture
    vertext = vertex(:,1:2)*0 - 1;
    % vertex position
    fprintf(fid, '# %d vertex texture\n', size(vertext,1));
    fprintf(fid, 'vt %f %f\n', vertext');
end

% use mtl
% fprintf(fid, ['g ' object_name '_export\n']);
% mtl_bump_name = 'bump_map';
% fprintf(fid, ['usemtl ' mtl_bump_name '\n']);

% face
fprintf(fid, '# %d faces\n', size(face,1));
if isfield(Msh.texMap,'vertexUVW')
    facesT = Msh.texMap.facesT;
else
    facesT=face;
    disp('not using texture faces');
end
face_texcorrd = [face(:,1), facesT(:,1), face(:,2), facesT(:,2), face(:,3), facesT(:,3)];
fprintf(fid, 'f %d/%d %d/%d %d/%d\n', face_texcorrd');

fclose(fid);


% % MTL generation
% if isfield(options, 'nm_file')
%     mtl_file = [object_name '.mtl'];
%     fid = fopen(mtl_file,'wt');
%     if( fid==-1 )
%         error('Can''t open the file.');
%         return;
%     end
%     
%     Ka = [0.59 0.59 0.59];
%     Kd = [0.5 0.43 0.3];
%     Ks = [0.6 0.6 0.6];
%     d = 1;
%     Ns = 2;
%     illum = 2;
%     
%     fprintf(fid, '# write_obj (c) 2004 Gabriel Peyr?\n');
%     
%     fprintf(fid, 'newmtl %s\n', mtl_bump_name);
%     fprintf(fid, 'Ka  %f %f %f\n', Ka);
%     fprintf(fid, 'Kd  %f %f %f\n', Kd);
%     fprintf(fid, 'Ks  %f %f %f\n', Ks);
%     fprintf(fid, 'd  %d\n', d);
%     fprintf(fid, 'Ns  %d\n', Ns);
%     fprintf(fid, 'illum %d\n', illum);
%     fprintf(fid, 'bump %s\n', options.nm_file);
%     
%     fprintf(fid, '#\n# EOF\n');
% 
%     fclose(fid);
% end