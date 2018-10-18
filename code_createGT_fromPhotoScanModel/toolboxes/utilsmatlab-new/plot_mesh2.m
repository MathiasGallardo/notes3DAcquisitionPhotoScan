function h = plot_mesh2(vertex,face,options)

% plot_mesh - plot a 3D mesh.
%
%   plot_mesh(vertex,face, options);
%
%   'options' is a structure that may contains:
%       - 'normal' : a (nvertx x 3) array specifying the normals at each vertex.
%       - 'edge_color' : a float specifying the color of the edges.
%       - 'face_color' : a float specifying the color of the faces.
%       - 'face_vertex_color' : a color per vertex or face.
%       - 'vertex'
%
%   See also: mesh_previewer.
%
%   Copyright (c) 2004 Gabriel Peyr�


if nargin<2
    error('Not enough arguments.');
end
if nargin<3
    options.null = 0;
end

if isfield(options,'plotEdges')
   doPlotEdges =  options.plotEdges;
else
    doPlotEdges=true;
end

% can flip to accept data in correct ordering
if (size(vertex,1)==3 || size(vertex,1)==2) && size(vertex,2)~=3
    vertex = vertex';
end
if size(face,1)==3 && size(face,2)~=3
    face = face';
end

if size(face,2)~=3 || (size(vertex,2)~=3 && size(vertex,2)~=2)
    error('face or vertex does not have correct format.');
end


% doPlotEdges=false;



if nargin==3
   h = patch('vertices',vertex,'faces',face,'facecolor',[1,0.8,0],'edgecolor',[0 0 0],'LineWidth',0.05);  %0.65
%    h = patch('vertices',vertex,'faces',face,'facecolor',[11/255,227/255,246/255],'edgecolor',[0 0 0],'LineWidth',0.05);  %0.65
    if doPlotEdges
    
	else
		set(h,'EdgeColor','none');
	end
  
end

if isfield(options, 'normal')
    normal = options.normal;
else
    normal=[];
end


if isfield(options, 'edge_color')
    edge_color = options.edge_color;
else
    edge_color=0;
end

if isfield(options, 'face_color')
    face_color=options.face_color;
    h = patch('vertices',vertex,'faces',face,'facecolor',face_color,'edgecolor',edge_color);    
    return;
end

if isfield(options, 'face_vertex_color')
    face_vertex_color=options.face_vertex_color;
    nverts = size(vertex,1);
    % vertex_color = rand(nverts,1);
    if size(face_vertex_color,1)==size(vertex,1)
        shading_type = 'interp';
    else
        shading_type = 'flat';
    end
    h = patch('vertices',vertex,'faces',face,'FaceVertexCData',face_vertex_color, 'FaceColor',shading_type,'BackFaceLighting','phong');
end
% camlight infinite;
%colormap gray(256);
lighting phong;
%camlight infinite; 
%camproj('perspective');
%axis square; 
axis off;
% % %% RFIA/ECCV
% disp('Light for RFIA/ECCV papers');
% %creasedPaper12
% set(h,'AmbientStrength',0.6);
% light('Position',[-0.5 0 0.5],'Style','local');

% % creasedPaper11
% set(h,'AmbientStrength',0.8);
% light('Position',[-400 0 500],'Style','local');
%% BMVC
% disp('Light for BMVC paper');
% 
% % creasedPaper29
% set(h,'AmbientStrength',0.6);
% light('Position',[-200 1000 0],'Style','local');

% set(h,'AmbientStrength',0.6);
% % light('Position',[-300 100 0],'Style','local'); %creasedPaper07
% light('Position',[0 1000 0],'Style','local'); %creasedPaper09
% % light('Position',[700 2000 100],'Style','local');

% light('Position',[-1 0 0.5],'Style','local'); %creasedPaper11
% camlight('Position',[0 0 0],'Style','local');
% camlight(-8,-94)

%% BMVCFinal Version
% disp('Light for BMVC final version');
% 
% set(h,'AmbientStrength',0.8);
% light('Position',[-100 0 400],'Style','local');

disp('Light for ICCV final version');
set(h,'AmbientStrength',0.8);
light('Position',[-100 0 400],'Style','local');

% disp('Light for handBag01');
% set(h,'AmbientStrength',0.5);
% light('Position',[-100 0 400],'Style','local');

% disp('Light for pillowCover01');
% set(h,'AmbientStrength',0.3);
% light('Position',[00 0 -400],'Style','local');

% set(h,'AmbientStrength',0.3);
% light('Position',[100 0 -100],'Style','local');

if doPlotEdges
    
else
    set(h,'EdgeColor','none');
end

if ~isempty(normal)
    % plot the normals
    hold on;
    quiver3(vertex(:,1),vertex(:,2),vertex(:,3),normal(:,1),normal(:,2),normal(:,3),0.8);
    hold off;
end

%axis tight;
axis equal;


%cameramenu;
