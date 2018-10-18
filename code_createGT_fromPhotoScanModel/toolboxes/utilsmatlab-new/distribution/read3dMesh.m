function M = read3dMesh(filename,options)
%READ3DMESH - function which reads a mesh file and constructs a mesh
%structure. Supported file types are '.smf' '.wrl' '.ply' '.off' '.3ds' '.di3d' and '.obj'
%
% Syntax:  [M,camData] = read3dMesh(filename,options)
%
% Inputs:
%    filename - mesh file name
%
%
%    Options struct. With the following optional fields:
%    options.removeDupedVerts (true or false). If options.removeDupedVerts = true, duplicated vertices will be removed.
%    Default: options.removeDupedVerts = false;
%
% Outputs:
% M - structure holding the 3D mesh. See meshDef.m for the specification of
% a mesh structure. At the very least it will have the following two
% fields:
%M.verts - nx3 matrix of 3d points
%M.faces - mx3 matrix of triangles (i.e. faces)

%Depending on available data, other fields in M will be filled. e.g.
%M.Tverts - ntx3 matrix of UVW texture vertices
%M.textureMap- texturemap
%
%
% Example use:
%       [Msh] = read3dMesh([drive '\collins\sourceCode3\projectiveGeom\testData\scene.3ds']);
%       camera = initPerspectiveCam(Msh,op);
%       light = [];
%       options.srcFrame = 'world';
%       options.propertyMaps{1} = 'depth';
%       [imOut,msk,baryMask,ptsPix] = z_buffer2(camera,Msh,light,options)
%
% Other m-files required: read_smf  read_wrl read_plyFull read_off model3d
% getVertsAndTriangs readDI3D
% Subfunctions: none
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

if nargin<2
    options = struct;
end


withTexMap = false;
withMTLFile = false;
[aa,ab,extension] = fileparts(filename);
M = struct;
switch lower(extension)
    case '.smf'
        [vertex,face] = read_smf(filename);
    case '.wrl'
        [vertex, face] = read_wrl(filename);
    case '.ply'
        [d, face] = read_plyFull(filename);
        vertex=[d.x,d.y,d.z];
        M.extraData = d;
        
    case '.off'
        verbose=false;
        [d,face] = read_off(filename);
        vertex=double(d');
        face=double(face');
        
        
    case '.3ds'
        m = model3d(filename);
        %[vertex,face] = getVertsAndTriangs(m,[3,2,1]);
        [vertex,face] = getVertsAndTriangs(m,0);
        vertex=double(vertex);
        face=double(face);
        
        
%    case '.di3d'
%    no longer supported.
%         if (~(isfield(options,'computeFullResM')|isfield(options,'computeLowResM')))
%             disp('Asked to read di3d file but reading M options not set. See readDI3D.m for details.')
%             return
%         else
%             scan3d = readDI3D(filename,options);
%             camData = scan3d;
%             camData.type = 'di3d';
%         end
%         if (isfield(options,'computeFullResM'))
%             vertex = scan3d.pointCloud;
%             face = scan3d.tris;
%         else
%             vertex = scan3d.lowResM.pointCloud;
%             face = scan3d.lowResM.tris;
%         end
        
    case '.obj'
        %[M,vertex,face] = read_obj_collins2(filename);
        [vertex,face,F4,VT,F3T,mtlFile,usemtl]=loadawobj(filename);
        vertex=vertex';
        face=face';
        M=struct;
        if ~isempty(VT)
            withTexMap=true;
            vertexT=VT';
            faceT=F3T';
        end
        if ~isempty(mtlFile)
            withMTLFile=true;
            [aa,ab,ac] = fileparts(filename);
            mtlFilePth = aa;
            mtlFileName = mtlFile;
            
        end
    otherwise
        disp('Unknown method.')
        return;
end

if size(face,2)>3
    face = quadmesh2trimesh(face);
end
if isfield(options,'removeDupedVerts')
    if options.removeDupedVerts
        [vertex,face] = removeDupedVerts(vertex,face);
    end
else
    
end

%build the mesh:
M = build3dMesh(vertex,face,options);
if withTexMap
    M.texMap.vertexUVW = vertexT;
    M.texMap.facesT = faceT;
end

if withMTLFile
    M.mtlFile.path = mtlFilePth;
    M.mtlFile.fname = mtlFileName;
    M.mtlFile.usemtl=usemtl;
    [d1,d2] = fileparts(mtlFileName);
    if isempty(d1)
        M.mtlFile.data = read_MTL_file([mtlFilePth '/' mtlFileName]);
        try
        %M.texMap.img = M.mtlFile.data.mtl.map_Ka;
        catch
            'no k map';
        end
    else
        if strcmp(d1(1),'.')
            M.mtlFile.data = read_MTL_file([mtlFilePth '/' mtlFileName(3:end)]);
        else
            M.mtlFile.data = read_MTL_file([mtlFileName]);
        end
        
    end
     try
        M.texMap.img = M.mtlFile.data.mtl.map_Ka;
        catch
            'no k map';
        end
   
    
end
M.vertexNormals = [];