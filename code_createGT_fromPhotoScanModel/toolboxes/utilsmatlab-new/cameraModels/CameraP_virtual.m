classdef  CameraP_virtual < CameraP
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        render = Render;
        rendMaps;
    end
    methods
        
        function obj = initFromMesh(obj,msh,res)
            obj = initFromMesh@CameraP(obj,msh,res);
            obj.render = obj.render.setRenderDims(obj.pixelResW,obj.pixelResH);
        end
        function obj = doRender(obj,mesh3D,mode,illumModel)
            if nargin<3
                mode = 1;
            end
            if nargin<4
                illumModel = [];
            end
            
            obj = rendZBuffer(mesh3D,obj,mode,illumModel);
            %obj.render = render;
        end
        
        function rMap = getRMapNormalsCamView(obj)
            rMap = obj.rendMaps{1};
            
        end
        function rMap = getRMapShadeLambertian(obj)
            rMap = obj.rendMaps{2};
            
        end
       
        function obj = doComputeMap(obj,M,className,dIn)
            switch  className
                case 'RMapNormalsCamView'
                    rMap = computeRMapNormalsCamView(obj,M);
                    obj.rendMaps{1} = rMap;
                case 'RMapShadeLambertian'
                    rMap = computeRMapShadeLambertian(obj,M,dIn.L);
                    obj.rendMaps{2} = rMap; 
                case 'OcclusionEdgeMap'
%                     F = obj.render.baryMap(:,:,1);
%                     %[XX,YY] = meshgrid([1:size(F,2)],[1:size(F,1)]);
%                     %px = [XX(:),YY(:)];
%                     [r,c,t] = find(obj.render.rendMask);
%                     px = [c,r];
%                     pxN1 = px;
%                     pxN1(:,1) = pxN1(:,1)+1;
%                     
%                     pxN2 = px;
%                     pxN2(:,2) = pxN2(:,2)+1;
%                     
%                     pxN3 = px;
%                     pxN3(:,1) = pxN3(:,1)+1;
%                     pxN3(:,2) = pxN3(:,2)+1;
%                     
%                     f1s = interp2(F,px(:,1),px(:,2),'nearest');
%                     
%                     g1s = interp2(F,pxN1(:,1),pxN1(:,2),'nearest');
%                     g2s = interp2(F,pxN2(:,1),pxN2(:,2),'nearest');
%                     g3s = interp2(F,pxN3(:,1),pxN3(:,2),'nearest');
%                     
%                     fEdges = [f1s,g1s;f1s,g2s;f1s,g3s];
%                     ins = fEdges(:,1)>0&fEdges(:,2)>0;
%                     fEdges = fEdges(ins,:);
%                     
%                     ns = isnan(sum(fEdges,2));
%                     fEdges = fEdges(ns==0,:);
%                     
%                     sm = (fEdges(:,1)==fEdges(:,2));
%                     fEdges = fEdges(sm==0,:);
%                     fEdges = sort(fEdges,2);
%                     
%                     G = buildGraph(M.faces,size(M.vertexPos,1),'faces');
%                     G = graph_buildTableFaces2x(G,'faces',false);
%                     
%                     is = sub2ind(size(G.tables.faces_2_faces),fEdges(:,1),fEdges(:,2));
%                     vs = full(G.tables.faces_2_faces(is));
                    
                    
                    
            end
            
        end
        
    end
end




function camera = rendZBuffer(msh,camera,mode,illumModel)
mode = uint32(mode);
%mesh must be a texturemapped mesh.
%large = 1e10;

camera = z_bufferMeshLW_wrapper(msh,camera,illumModel,mode);

end




function rMap = computeRMapShadeLambertian(cam,msh,L)
%light is in the camera's coordinate frame. No Shadows yet
rMap = RMapShade;

rMap.pixelResH = cam.pixelResH;
rMap.pixelResW = cam.pixelResW;

switch class(L)
    case 'LightDistant'
        if L.dir(3)>0
            lvec =  -L.dir;
            
        else
            lvec = L.dir;
        end
        nMapCam = getRMapNormalsCamView(cam,msh);
        sh = nMapCam.map(:,:,1).*lvec(1)+nMapCam.map(:,:,2).*lvec(2)+nMapCam.map(:,:,3).*lvec(3);
        rMap.map = sh;
        
end
end

function rMap = computeRMapNormalsCamView(cam,msh)
rMap = RMapNormalsCamView;
ptsxyz_cam = ((cam.R*msh.vertexPos'));
ptsxyz_cam(1,:) = ptsxyz_cam(1,:)+cam.T(1);
ptsxyz_cam(2,:) = ptsxyz_cam(2,:)+cam.T(2);
ptsxyz_cam(3,:) = ptsxyz_cam(3,:)+cam.T(3);

if isfield(msh,'vertNorms')==0|isempty(msh.vertNorms)
    disp('Mesh does not contain vertex normals. These will be estimated');
    vertNorms = computeVertNorms(ptsxyz_cam',msh.faces);
else
    vertNorms = (camera.R*msh.vertNorms');
end

faceNorms =computeTriNorms(msh.faces,ptsxyz_cam');




rMap.pixelResH = cam.pixelResH;
rMap.pixelResW = cam.pixelResW;

bf = cam.render.baryMap(:,:,1); bf=bf(:);
b1 = cam.render.baryMap(:,:,2); b1=b1(:);
b2 = cam.render.baryMap(:,:,3); b2=b2(:);
b3 = cam.render.baryMap(:,:,4); b3=b3(:);
vld = (bf>0);
B = [bf,b1,b2,b3];
B = B(vld,:);
pixN = baryInterp(msh.faces,vertNorms,B);
lv = sqrt(pixN(:,1).^2 + pixN(:,2).^2 + pixN(:,3).^2);
pixN = pixN./[lv,lv,lv];

%pve = pixN(:,3)>0;
%pixN(pve,:) = -pixN(pve,:);
pixN = faceNorms(B(:,1),:);


mpx = zeros(rMap.pixelResH,rMap.pixelResW)*nan;
mpx(vld) = pixN(:,1);

mpy = zeros(rMap.pixelResH,rMap.pixelResW)*nan;
mpy(vld) = pixN(:,2);

mpz = zeros(rMap.pixelResH,rMap.pixelResW)*nan;
mpz(vld) = pixN(:,3);

rMap.map = cat(3,mpx,mpy,mpz);

 %128.5000  138.5000

% nx = ba_interp2(double(rMap.map(:,:,1)),128,138);
% ny = ba_interp2(double(rMap.map(:,:,2)),128,138);
% nz = ba_interp2(double(rMap.map(:,:,3)),128,138);
% ng = [nx;ny;nz];
% 
% bb =  cam.render.baryMap(128,138,:);
% fs = msh.faces(714,:);
% vs = ptsxyz_cam(:,fs);
% p = fitplane(vs);
% p = p(1:3);
% p = p.'/norm(p);
% p = p*-1;












end