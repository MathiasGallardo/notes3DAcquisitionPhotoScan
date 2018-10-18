function didWrite = write3dMesh(mesh,filename,opts)
if iscell(mesh.vertexPos)
    v=mesh.vertexPos{opts.vertexPosInd};
    mesh=rmfield(mesh,'vertexPos');
    mesh.vertexPos = v;
end
%camData=struct;

%paths:
%[aa,ab,ac] = sourceRoot();
%addpath([aa 'collins\sourceCode2\3DFormatConversion\3dsReaderM\model3d']);
%addpath([aa 'collins\sourceCode2\3DFormatConversion\3dsReaderM\model3d\@model3d']);
%addpath([aa 'collins\sourceCode3\graphAlgorithms\toolbox_graph']);

%Mesh.vertexPos;
%Mesh.faces;


%WRITEDMESH writes a 3d mesh to the following formats:
%   smf
%   wrl
%   ply
%   off
%   obj
%   -3ds
%   Toby Collins 2007

%options.applyTransMat {true,false}  - if available


%outputs:
%mesh.verts - nx3 matrix of 3d points
%mesh.faces - mx3 matrix of triangles (i.e. faces)

%optional, depending on available data:
%mesh.Tverts - ntx3 matrix of UVW texture vertices
%mesh.textureMap- texturemap

%mesh.curv - nx4 matrix of min,max,mean,gaussian curvature values, one for
%each vertex

%mesh.transMat - homogeneous transformation matrix of mesh in world
%reference frame

%camData: camera data used for rendering the mesh (if available)
%camData.type {'di3d','3dsmax'}

[aa,ab,extension] = fileparts(filename);
switch lower(extension)
    case '.smf'
         write_smf(filename, mesh.vertexPos, mesh.faces);
         didWrite=true;
         
    case '.wrl'
        %[vertex, face] = read_wrl(filename);
        write_wrl(filename, mesh.vertexPos, mesh.faces);
        didWrite=true;
        
    case '.ply'
        %write_ply
        write_ply_asciiFast(mesh.vertexPos, mesh.faces,filename);
        didWrite=true;
        %[d, face] = read_plyFull(filename);
        %vertex=[d.x,d.y,d.z];
        %Mesh.extraData = d;
        
    case '.off'
        write_off(filename, mesh.vertexPos, mesh.faces);
        didWrite=true;
        %verbose=false;
        %[d,face] = read_off(filename, verbose);
        %vertex=double(d');
        %face=double(face');
        
    case '.obj'
        %write_obj2(filename, mesh.vertexPos, mesh.faces);
        %write_obj(filename, mesh.vertexPos, mesh.faces);
        if isfield(mesh,'mtlFile')
            mesh = rmfield(mesh,'mtlFile');
        end
        write_obj2(filename, mesh);
        
        didWrite=true;
        
        
%     case '.3ds'
%         m = model3d(filename);
%         %[vertex,face] = getVertsAndTriangs(m,[3,2,1]);
%         [vertex,face] = getVertsAndTriangs(m,0);
%         vertex=double(vertex);
%         face=double(face);
%         
%     case '.di3d'
%         if (~(isfield(options,'computeFullResMesh')|isfield(options,'computeLowResMesh')))
%             disp('Asked to read di3d file but reading mesh options not set. See readDI3D.m for details.')
%             return
%         else
%             scan3d = readDI3D(filename,options);
%             camData = scan3d;
%             camData.type = 'di3d';
%         end
%         if (isfield(options,'computeFullResMesh'))
%             vertex = scan3d.pointCloud;
%             face = scan3d.tris;
%         else
%             vertex = scan3d.lowResMesh.pointCloud;
%             face = scan3d.lowResMesh.tris     
%         end
    otherwise
        disp('Unknown method.')
        return;
end
% if nargin>1
% if isfield(options,'applyTransMat')
%     applyTransMat = options.applyTransMat;
%     if applyTransMat
%         mesh.transMat = myReadMatrix([aa ab '.tns']);
%         if trans == -1
%             disp(['Asked to apply transformation matrix but error reading ' aa ab '.tns']);
%         else
%             ptsNew = [mesh.verts';ones(1,size(mesh.verts,2))];
%             ptsNew = mesh.transMat*ptsNew;
%             ptsNew = ptsNew';
%             vertex = ptsNew(:,1:3);           
%         end
%     end
% end
% end
% 
% if ~isfield(mesh,'transMat')
%     Mesh.transMat = eye(4,4);
% end
% 
% 
% 
% Mesh.vertexPos = vertex;
% Mesh.faces = face;
% 


%options.computeFullResMesh {true,false}
%options.computeLowResMesh {0-1, where 0.1 means low res mesh is sampled at

