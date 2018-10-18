function M = build3dMesh(vertex,face,options)
%BUILD3DMESH - function which builds a 3D mesh from vertices+triangle
%faces.
%
% Syntax:  M = build3dMesh(vertex,face,options);
%
% Inputs:
%   vertexPos:                     Holds the mesh vertices [nx3 double] These are specified in the coordinate system given by coordSys
%   faces:                         Holds the mesh faces [fx3 double]. Indexing
%                                  starts at 1.
%   options:                       Options struct (optional). This has the
%                                  following fields:
%                                  options.removeDupedVerts: State whether
%                                  to remove duplicated vertices (binary)
%                                  options.coordSys: coordinate system of
%                                  vertexPos. Can be either 'world' or
%                                  'camera'.

%
% Outputs:
%    M - mesh structure. See meshDef.m for details.
%
%
% Example use:
%       pts = rand(100,2);
%       T = delaunay(pts(:,1),pts(:,2));
%       pts(:,3) = 0;
%       M = build3dMesh(pts,T,options);
%
% Other m-files required: removeDupedVerts.m, buildGraph.m,
% graph_buildTableNode2x.m
%
% Subfunctions: none
% MAT-files required: none
%
% See also: meshDef.m, read3dMesh.m

% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008


if nargin<3
    options=struct;
end
if isfield(options,'removeDupedVerts')
    if options.removeDupedVerts
    [vertex,face] = removeDupedVerts(vertex,face);
    end
else
    
end

if isfield(options,'coordSys')
    
else
    options.coordSys='world';
end


vertexCol = zeros(size(vertex,1),3);
meshCol = 'r'; %default mesh colour.
switch meshCol
    case 'r'
        vertexCol(:,1) = 255;
    case 'g'
        vertexCol(:,2) = 255;
    case 'b'
        vertexCol(:,3) = 255;
    case 'k'
        vertexCol(:) = 255;
end

M.coordSys = options.coordSys;

M.vertexPos = vertex;
M.faces = face;
M.faceColour.mode = 'rgb'; %rgb, scaled
M.faceColour.val=[];

M.vertexColour.mode = 'rgb'; %rgb, scaled
M.vertexColour.val = vertexCol;

M.edgeColour.mode = 'rgb'; %rgb, scaled
M.edgeColour.val = [];

% M.renderData.shading_type = 'interp';
% %M.renderData.shading_type = 'flat';
% M.renderData.colormap = 'gray_256';
% M.renderData.lighting = 'gouraud'; %'flat','gouraud', 'phong';
% M.renderData.camlight = 'infinite';
% M.renderData.renderEdges = true;

M.noVertexPos = size(vertex,1);
M.noFaces = size(face,1);
G = buildGraph(M.faces,size(vertex,1),'Faces');
G = graph_buildTableNode2x(G,'edges',true);
M.G= G;
M.texMap=struct;


