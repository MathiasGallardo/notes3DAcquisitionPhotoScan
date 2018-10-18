classdef  CameraP_D_virtual <  CameraP_D
    %distorted perspective camera
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        render = Render;
    end
    methods
        
        function obj = initFromMesh(obj,msh,res)
            obj = initFromMesh@CameraP(obj,msh,res);
            obj.render = obj.render.setRenderDims(obj.pixelResW,obj.pixelResH);
        end
        function obj = doRender(obj,mesh3D,light)
            if isempty(obj.distort2PinholeMap)
                obj = setupDistort2PinholeMap(obj);
            end
            
            obj = rendZBuffer(mesh3D,obj,light);
            [i1,i2] = find(obj.render.rendMask*0+1);
            px = [i2,i1];
            wx = obj.distort2PinholeMap(:,:,1);
            wy = obj.distort2PinholeMap(:,:,2);
            
            wx = wx(:);
            wy = wy(:);
            
            ff = find(isnan(wx)==0);
            ws= double([wx(ff),wy(ff)]);
            r = ba_interp2(double(obj.render.RendRGB(:,:,1)),ws(:,1),ws(:,2));
            g = ba_interp2(double(obj.render.RendRGB(:,:,2)),ws(:,1),ws(:,2));
            b = ba_interp2(double(obj.render.RendRGB(:,:,3)),ws(:,1),ws(:,2));
            R = zeros(obj.pixelResH,obj.pixelResW);
            R(ff) = r;
            
            G = zeros(obj.pixelResH,obj.pixelResW);
            G(ff) = g;
            
            B = zeros(obj.pixelResH,obj.pixelResW);
            B(ff) = b;
            
            
            Rend = single(cat(3,R,G,B));
            %figure(1);
            %clf;
            %imshow(uint8(Rend));
            
            
            
            obj.render.RendRGB = Rend;
            %obj.render = render;
        end
               function rMap = getRMapNormalsCamView(obj)
            rMap = obj.rendMaps{1};
            
        end
        function rMap = getRMapShadeLambertian(obj)
            rMap = obj.rendMaps{2};
            
        end
       
        function rMap = doComputeMap(obj,M,className,dIn)
            switch  className
                case 'RMapNormalsCamView'
                    rMap = computeRMapNormalsCamView(obj,M);
                    %obj.rendMaps{1} = rMap;
                case 'RMapShadeLambertian'
                    rMap = computeRMapShadeLambertian(obj,M,dIn.L);
                    %obj.rendMaps{2} = rMap; 
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

function camera = setupDistort2PinholeMap(camera)

camera.distort2PinholeMap = single(zeros(camera.pixelResH,camera.pixelResW,2))*nan;
%[i1,i2] = find(camera.xDistort*0+1);
%ps = [i2,i1];
%xd = homoMult(inv(camera.K),ps);
%     syms xdx xdy kc1 kc2 kc3 kc4 kc5
%     syms dxx dxy
%     syms x y;
%     kc5 = 0;
%     kc = [kc1 kc2 kc3 kc4 kc5];
%     r = sqrt(x^2+y^2);
%     xn = [x;y];
%     c = 1+kc(1)*r.^2+kc(2)*r.^4+kc(5)*r.^6;
%     dxx = 2*kc(3)*x.*y+kc(4)*(r.^2+2*x.^2);
%     dxy = kc(3)*(r.^2+2*y.^2) + 2*kc(4)*x.*y;
%     xd = [xdx;xdy];
%     eq=  c*xn+[dxx;dxy] - xd;
%     ss = solve(eq,x,y);

wBuf = camera.pixelResW/4;
hBuf = camera.pixelResH/4;
wBuf = 0;
hBuf =0;
[XX,YY] = meshgrid(-wBuf:2:camera.pixelResW+wBuf,-hBuf:2:camera.pixelResH+hBuf);
ps = [XX(:),YY(:)];
% [i1,i2] = find(camera.xDistort*0+1);
% ps = [i2,i1];
xn = homoMult(inv(camera.K),ps);
x = xn(:,1);
y = xn(:,2);

r = sqrt(x.^2+y.^2);
c = 1+camera.kc(1)*r.^2+camera.kc(2)*r.^4+camera.kc(5)*r.^6;
dxx = 2*camera.kc(3)*x.*y+camera.kc(4)*(r.^2+2*x.^2);
dxy = camera.kc(3)*(r.^2+2*y.^2) + 2*camera.kc(4)*x.*y;

xd = [c,c].*xn + [dxx,dxy];
xp = homoMult((camera.K),xd);
M = meshImage(size(XX,1),size(XX,2),1);
%M.vertexPos = xp;
%M.vertexPos(:,3) = 0;
figure(10);
clf;
plot(xp(:,1),xp(:,2),'r.');

msk = logical(zeros(camera.pixelResH,camera.pixelResW));
dMap = single(ones(camera.pixelResH,camera.pixelResW)*1e10);
baryMap = single(ones(camera.pixelResH,camera.pixelResW,4)*-1);
vs = single(xp');
T = uint32(M.faces')-1;
%T= [T(1,:);T(3,:);T(2,:)];
vDepths = single(ones(size(vs,2),1))*1;
pixelMeshIntersect2D(msk,dMap,baryMap,vs,T,vDepths);
figure(1)
clf
imshow(uint8(msk)*255);
fs = baryMap(:,:,1);fs = fs(:)+1;
bs1 = baryMap(:,:,2);bs1 = bs1(:);
bs2 = baryMap(:,:,3);bs2 = bs2(:);
bs3 = baryMap(:,:,4);bs3 = bs3(:);

vld = fs>0;
B = [fs,bs1,bs2,bs3];
posVld = baryInterp(M.faces,ps,B(vld,:));

mx = zeros(camera.pixelResH,camera.pixelResW)*nan;
my = zeros(camera.pixelResH,camera.pixelResW)*nan;

mx(vld)= posVld(:,1);
my(vld)= posVld(:,2);

camera.distort2PinholeMap(:,:,1) = mx;
camera.distort2PinholeMap(:,:,2) = my;

end

function camera = rendZBuffer(msh,camera,light)
mode = uint32(0);
mode = uint32(1);
%mesh must be a texturemapped mesh.
%large = 1e10;
camera = z_bufferMeshLW_wrapper(msh,camera,light,mode);
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
        %nMapCam = getRMapNormalsCamView(cam,msh);
        nMapCam = computeRMapNormalsCamView(cam,msh);
        
        
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

%if isfield(msh,'vertNorms')==0|isempty(msh.vertNorms)
 %   disp('Mesh does not contain vertex normals. These will be estimated');
 %   vertNorms = computeVertNorms(ptsxyz_cam',msh.faces);
%else
 %   vertNorms = (camera.R*msh.vertNorms');
%end


rMap.pixelResH = cam.pixelResH;
rMap.pixelResW = cam.pixelResW;

bf = cam.render.baryMap(:,:,1); bf=bf(:);
b1 = cam.render.baryMap(:,:,2); b1=b1(:);
b2 = cam.render.baryMap(:,:,3); b2=b2(:);
b3 = cam.render.baryMap(:,:,4); b3=b3(:);
vld = (bf>0);
B = [bf,b1,b2,b3];
B = B(vld,:);


% 
% if isfield(msh,'faceNorms')
%     faceNorms =msh.faceNorms;
%     faceNorms = (cam.R*faceNorms')';
% else
%     faceNorms =computeTriNorms(msh.faces,ptsxyz_cam');
% end



if isfield(msh,'vertNorms')
   
   
else
    msh.vertNorms=computeVertNorms(ptsxyz_cam',msh.faces);
 msh.vertNorms = (cam.R* msh.vertNorms')';
end


pixN = baryInterp(msh.faces,msh.vertNorms,B);
    lv = sqrt(pixN(:,1).^2 + pixN(:,2).^2 + pixN(:,3).^2);
    pixN = pixN./[lv,lv,lv];
    pixN = (cam.R*pixN')';



%pve = pixN(:,3)>0;
%pixN(pve,:) = -pixN(pve,:);



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



