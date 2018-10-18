function camera = z_bufferMeshLW_wrapper(msh,camera,light,mode)


mode = uint32(mode);
%%%
%msh.texMap.img = msh.texMap.imgs{1};
%%%%

if ischar(msh.texMap.img)
   msh.texMap.img = imread(msh.texMap.img);
end

if size( msh.texMap.img,3)==1
     msh.texMap.img = repmat( msh.texMap.img,[1,1,3]);
end


hasTextureMap = isfield(msh.texMap,'img');
%mesh must be a texturemapped mesh.
large = 1e10;




%%%%%%%%%%%%%
% ptsxyz_cam = ((camera.R*msh.vertexPos'));
% ptsxyz_cam(1,:) = ptsxyz_cam(1,:)+camera.T(1);
% ptsxyz_cam(2,:) = ptsxyz_cam(2,:)+camera.T(2);
% ptsxyz_cam(3,:) = ptsxyz_cam(3,:)+camera.T(3);
% 
% Kinv= (inv(camera.K));
% ppix = camera.K*ptsxyz_cam;
% vx = ppix(1,:)./ppix(3,:);
% vy = ppix(2,:)./ppix(3,:);
% vx = round(vx);
% vy = round(vy);
% 
% ss = Kinv*[vx;vy;ones(1,size(vy,2))];
% ss = ss.*[ptsxyz_cam(3,:);ptsxyz_cam(3,:);ptsxyz_cam(3,:)];
% msh.vertexPos = ss';
% 
% MM = [camera.R,camera.T];
% MM(4,4) = 1;
% msh.vertexPos = homoMult(inv(MM),msh.vertexPos);
%%%%%%%%%%


%get vertex coordinates in camera coordinate frame
ptsxyz_cam = ((camera.R*msh.vertexPos'));
ptsxyz_cam(1,:) = ptsxyz_cam(1,:)+camera.T(1);
ptsxyz_cam(2,:) = ptsxyz_cam(2,:)+camera.T(2);
ptsxyz_cam(3,:) = ptsxyz_cam(3,:)+camera.T(3);


if isfield(msh,'faceNormals')==0|isempty(msh.faceNormals)
    disp('Mesh does not contain face normals. These will be estimated');
    fNormals=computeTriNorms(msh.faces,ptsxyz_cam')';
else
    fNormals = (camera.R*msh.faceNormals');
end
fNormals = single(fNormals);

Kinv= (inv(camera.K));
ppix = camera.K*ptsxyz_cam;
vx = ppix(1,:)./ppix(3,:);
vy = ppix(2,:)./ppix(3,:);
%vDepths = single(ppix(3,:));
vs = single([vx;vy]);
if hasTextureMap
vsTexture = single(msh.texMap.vertexUVW(:,1:2)');
TTexture =  uint32(msh.texMap.facesT')-1;
else
    vsTexture=single([]);
    TTexture = uint8([]);
end
T = uint32(msh.faces')-1;


%TmapImg = single(imread(msh.texMap.img));
if hasTextureMap
TmapImg = single((msh.texMap.img));
else
   TmapImg = single([]); 
end
% rOpts = struct;
% rOpts.srcFrame = 'world';
%
% tic;
% [Img,msk] = z_bufferMesh(camera,msh,[],rOpts);
% toc;
% figure(1);
% clf;
% imshow(uint8(Img));

if size(camera.render.dMap,1)~=camera.pixelResH||size(camera.render.dMap,2)~=camera.pixelResW
    camera.render.dMap = single(ones(camera.pixelResH,camera.pixelResW))*large;
end
if size(camera.render.RendRGB,1)~=camera.pixelResH||size(camera.render.RendRGB,2)~=camera.pixelResW
    camera.render.RendRGB = single(zeros(camera.pixelResH,camera.pixelResW,3));
end
if size(camera.render.rendMask,1)~=camera.pixelResH||size(camera.render.rendMask,2)~=camera.pixelResW
    camera.render.rendMask = logical(zeros(camera.pixelResH,camera.pixelResW));
end
if size(camera.render.baryMap,1)~=camera.pixelResH||size(camera.render.baryMap,2)~=camera.pixelResW
    camera.render.baryMap = single(ones(camera.pixelResH,camera.pixelResW,4))*-1;
end



ptsxyz_cam = single(ptsxyz_cam);
%behind = ptsxyz_cam(3,:)<=0;
%ptsxyz_cam(:,behind) = 2*large;

Kinv= single(Kinv);
camera.render.dMap(:) = large;
camera.render.RendRGB(:) = 0;
camera.render.rendMask(:) = 0;
camera.render.baryMap(:) = -1;
%tic;
%load segFaultState;
%addpath('e:\collins\sourceCode3\projectiveGeom\zBuferLightweight\zBufferLW\x64\Debug');

zBufferLW(camera.render.RendRGB,camera.render.rendMask,camera.render.dMap,camera.render.baryMap,vs,vsTexture,T,TTexture,TmapImg,ptsxyz_cam,fNormals,Kinv,mode,hasTextureMap);
camera.render.baryMap(:,:,1) = camera.render.baryMap(:,:,1)+1;
camera.render.dMap(camera.render.dMap>large/2)=nan;

camera.render.dMap = camera.render.dMap(2:end,2:end,:);
camera.render.RendRGB = camera.render.RendRGB(2:end,2:end,:);
camera.render.rendMask = camera.render.rendMask(2:end,2:end,:);
camera.render.baryMap = camera.render.baryMap(2:end,2:end,:);

camera.render.dMap(:,end+1)=nan;
camera.render.dMap(end+1,:)=nan;

camera.render.RendRGB(:,end+1,:)=nan;
camera.render.RendRGB(end+1,:,:)=nan;

camera.render.rendMask(:,end+1,:)=0;
camera.render.rendMask(end+1,:,:)=0;

camera.render.baryMap(:,end+1,:)=-1;
camera.render.baryMap(end+1,:,:)=-1;

if isempty(light)
    return;
end

light.type = 'Spotlight';

switch light.type
    
    case 'Directed'
        L = LightDistant;
        L.dir = [0;0;1];
        dIn.L = L;
        rMap = camera.doComputeMap(msh,'RMapShadeLambertian',dIn);
        rMap = rMap.map;
        rMap(rMap<0) = 0;
        rMap(rMap<0.1) = 0.1;
        shadMap = rMap;
        
        %shadMap = pw;
        %shadMap = shadMap+0.05;
         
        camera.render.RendRGB(:,:,1) = camera.render.RendRGB(:,:,1).*shadMap;
        camera.render.RendRGB(:,:,2) = camera.render.RendRGB(:,:,2).*shadMap;
        camera.render.RendRGB(:,:,3) = camera.render.RendRGB(:,:,3).*shadMap;
        
        
    case 'Spotlight'
        M = [camera.R,camera.T];
        M(4,4) = 1;
        lightPos3d_c = homoMult(M,light.pos3D_w')';
        %change this: must be for true distances:
        ds = camera.render.dMap-lightPos3d_c(3);
        pw = light.power*1./(ds.^(1.5));
        %pw = light.power*1./(ds);
        
        L = LightDistant;
        L.dir = [0;0;1];
        dIn.L = L;
        rMap = camera.doComputeMap(msh,'RMapShadeLambertian',dIn);
        rMap = rMap.map;
        rMap(rMap<0) = 0;
        rMap(rMap<0.1) = 0.1;
        shadMap = rMap.*pw;
        
        %shadMap = pw;
        %shadMap = shadMap+0.05;
         
        camera.render.RendRGB(:,:,1) = camera.render.RendRGB(:,:,1).*shadMap;
        camera.render.RendRGB(:,:,2) = camera.render.RendRGB(:,:,2).*shadMap;
        camera.render.RendRGB(:,:,3) = camera.render.RendRGB(:,:,3).*shadMap;

case 'Spotlight_noShade'
        M = [camera.R,camera.T];
        M(4,4) = 1;
        lightPos3d_c = homoMult(M,light.pos3D_w')';
        %change this: must be for true distances:
        ds = camera.render.dMap-lightPos3d_c(3);
        pw = light.power*1./(ds.^(1.5));
        %pw = light.power*1./(ds);
        
       
        
        shadMap = pw;
        %shadMap = shadMap+0.05;
         
        camera.render.RendRGB(:,:,1) = camera.render.RendRGB(:,:,1).*shadMap;
        camera.render.RendRGB(:,:,2) = camera.render.RendRGB(:,:,2).*shadMap;
        camera.render.RendRGB(:,:,3) = camera.render.RendRGB(:,:,3).*shadMap;

        
end
    
    






