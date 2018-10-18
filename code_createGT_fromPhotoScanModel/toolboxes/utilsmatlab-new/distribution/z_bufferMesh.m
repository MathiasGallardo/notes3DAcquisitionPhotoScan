function [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] = z_bufferMesh(camera,msh,light,options)
%zBufferMesh - function which renders a mesh with a given camera using
%z-buffering
%
% Syntax:  [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] =
% z_buffer2(camera,msh,light,options)
%
% Inputs:
%    camera - matlab structure holding Camera model. See cameraDef.m for
%    how to specify a camera structure
%
%    msh - matlab structure holding a mesh model. See medhDef.m for how to
%    specify a mesh structure
%
%    light - a 1xk cell array holding the k light models which illuminate the scene. See lightModelDef.m for
%    how to specify a light structure. Set light = [] to create some
%    defualt illumination.
%
%    Options struct. See the parseOptions function in this fil for guidence
%    for how to use this.
%
% Outputs:
%    imOut - RGB render of size n*m*3
%    msk - binary mask of size n*m. msk(i,j)=1 means that ray passing
%    through pixel (i,j) intersects msh.
%
%    baryMask - barycentric coordinate mask of size n*m*4. This gives the barycentric coorinates of each pixel reprojected onto msh. That is: baryMask(i,j,:)
%    = [faceID,b1,b2,b3].
%
%    ptsPix - the positions of the projected mesh vertices in pixels (of
%    size k*2) where ptsPix(i,:) = [xi,yi]
%
%    VisibFaces - A vector that holds the indices of those faces which are
%    visible to the camera
%
%    pMaps - These are various 'property maps' which the user may want to be returned. Currently 3 property maps are supported, these are:
%    'depth' 'textureMapVal' 'normals_cam'.
%    A property map has two fields:
%    pMap.type and
%    pMap.map
%    pMap.type is the string name of the property map, and can be one of
%    'depth' 'textureMapVal' 'normals_cam'
%     pMap.map  is an array of size h*w*dims, where h and w are the
%    height and width of the camera.  pMap.map(i,j,:) gives the value of
%    the property at pixel (i,j). So for example, for the depth property,
%    pMap.map(i,j) = d = the depth of pixel (i,j) (in pixels). A value of
%    nan means the surface did not project onto a pixel.
%
%    pMaps is a cell array with each element being a property map. The user
%    specifies which property maps they want computed with the options
%    field: options.propertyMaps. For example, if options.propertyMaps =
%    {'depth' 'normals_cam'}, then pMaps will be a cell array of 1x2
%    holding the depth and normals at each pixel.
%    Strictly speaking, imOut, msk and baryMask are each property maps.
%
%
% Example use:
%      Msh = read3dMesh('C:\collins\data\3dmodels\texturedBox\box.obj');
%      camera = initPerspectiveCam(Msh,op); %initialises a perspective
%      %camera that looks at the mesh.
%      light = []; %not specifying a light model
%      options.srcFrame = 'world';
%      options.shadingMethod='flat';
%      options.propertyMaps{1} = 'depth'; %lets get a depth map too.
%      [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] = z_bufferMesh(camera,Msh,light,options);
%
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008; Last revision: 20-Jan-2011

%------------- BEGIN CODE --------------
%% initialise outputs:
imOut=[];
pMaps=[];
msk=[];
baryMask=[];
ptsPix=[];
VisibFaces=[];
pMaps=[];

%% parse options struct:
options = parseOptions(options,msh);


%% get camera pixel dimensions:
rendH = camera.pixelResH;
rendW = camera.pixelResW;

if strcmp(camera.type,'orthographic')
    options.useAffineBarys=true;
end


%% If needeed, construct texture map mask. This
%% basically prevents any pixels in the texture map which are masked out from being rendered. A pixel is masked in the texture map if
%% msh.texMap.img(i,j,:) is a nan.
if options.withRender
    if strcmp(options.rendType,'textureMap')||strcmp(options.rendType,'mesh')
        options.texMapMask = ~isnan(msh.texMap.img(:,:,1));
        disp('using a masked texture map');
    end
end

% if strcmp(options.rendType,'mesh')
%         vertstmapPix = uv2PixCoords(msh.texMap.vertexUVW,size(msh.texMap.img,2),size(msh.texMap.img,1));
%         h=figure(1);
%         clf;
%         imshow(uint8(msh.texMap.img));
%         hold on;
%         gplot(msh.G.A,vertstmapPix,'r');
%         im = img_saveModified(h,size(msh.texMap.img,1),size(msh.texMap.img,2));
%         msh.texMap.img = im;
%         options.rendType = 'textureMap';
% end


%% compute mesh vertex positions in the camera's reference frame:
if strcmp(options.srcFrame,'world')
    M=[[camera.params.R,camera.params.T];[0,0,0,1]];
    ptsxyz_cam = homoMult(M,msh.vertexPos);
else
    if strcmp(options.srcFrame,'camera')
        ptsxyz_cam = msh.vertexPos;
    else
        error('badly specified field options.srcFrame. Must be either world or camera');
    end
    M = eye(4);
end

if isfield(msh,'vertexNormals')==0
    disp('Mesh does not contain vertex normals. These will be estimated');
    msh.vertexNormals=computeVertNorms(ptsxyz_cam,msh.faces);


end

%% check to see if mesh has normals computed at its vertices:
if isempty(msh.vertexNormals)
    disp('Mesh does not contain vertex normals. These will be estimated');
    msh.vertexNormals=computeVertNorms(ptsxyz_cam,msh.faces);

else

end


%% if the light model is empty - then create a directed light and an
%% ambient light. The directed light points along the camera's line of
%% sight.
if isempty(light)&&options.withRender
    Minv = inv(M);
    p0 = [0,0,0];
    p1 = [0.0,0.0,-1];
    camCent_w = homoMult(Minv,p0);
    p_w = homoMult(Minv,p1);
    camView = p_w-camCent_w;camView=camView./norm(camView);
%     light1 = create_brdfLight(camView,[0.5,0.5,0.5],0.02);
    %light2 = create_ambientLight([0.6,0.6,0.6]);
    light2 = create_ambientLight([0.5,0.5,0.5]);
    light3 = create_directedLight(camView,[0.7,0.7,0.7]);
    light1 = create_directedLight(-camView,[0.7,0.7,0.7]);
    light={light1,light2,light3};
% light={light3,light2};
    
    %light2 = create_ambientLight([1,1,1]);
    %light={light2};


    %light1 = create_directedLight(camView,[1,1,1]);
    %light2 = create_ambientLight([0.9,0.9,0.9]);
    %light={light1,light2};


    %light1 = create_ambientLight([0.2,0.2,0.2]);
    %light1 = create_ambientLight([1,1,1]);
    %light = {light1};



else
end


%% Project points to image pixels:

opts.src_coordSystem = 'camera';

switch camera.type
    case {'perspective','di3d','linear_perspective'}
        ptsPix = perspectiveProject(ptsxyz_cam,camera,opts);
    case 'orthographic'
        ptsPix = orthographicProject(ptsxyz_cam,camera,opts);
    case 'scaled_orthographic'
        ptsPix = s_orthographicProject(ptsxyz_cam,camera,opts);
end

%% Sanity check: are the mesh vertices in front of the camera?
if mean(ptsxyz_cam(:,3))<0
    disp('Possible error: the mean depth of the surface vertices is negative. However, the camera viewing direction is along the +VE Z AXIS');
    vert_depth = -ptsxyz_cam(:,3);
else
    vert_depth=ptsxyz_cam(:,3);
end

% Hold the depths of the mesh faces and sort them prior to zbuffering
fDepth = (vert_depth(msh.faces(:,1))+vert_depth(msh.faces(:,2))+vert_depth(msh.faces(:,3)))./3;
[ss,sa] = sort(fDepth);

%% do the z-bufferring:
if strcmp(options.rendType,'textureMap')
    %if rendering with the texturemep, it is possible to handle texture
    %maps with masks. For any pixel in the image if it back projects onto texture map in a region that is masked out, it will not be rendered.
    %The mask is determined by
    if isfield(msh.texMap,'mask')
        tmapMask = msh.texMap.mask;
    else
        %the mask can be constructed from any colours in the texture map with
        %nan vaules:
        tmapImg = msh.texMap.img;
        if ischar(tmapImg)
            %load in texture map if it is stored as a string
            tmapImg = imread(tmapImg);
            disp('texture map loaded from an image file. No texture map mask is used');
        end
        tmapMask = ~isnan(sum(tmapImg,3));
    end
    vertstmapPix = uv2PixCoords(msh.texMap.vertexUVW,size(msh.texMap.img,2),size(msh.texMap.img,1));
    %call to zbuffer mex:
    featureFaceInds_ = zbuffer(rendH,rendW,ptsPix(:,1),ptsPix(:,2),int32(msh.faces(sa,1)),int32(msh.faces(sa,2)),int32(msh.faces(sa,3)),vert_depth,1,double(tmapMask),vertstmapPix(:,1),vertstmapPix(:,2));
else
    %call to zbuffer mex without a texture map mask:
    featureFaceInds_ = zbuffer(rendH,rendW,ptsPix(:,1),ptsPix(:,2),int32(msh.faces(sa,1)),int32(msh.faces(sa,2)),int32(msh.faces(sa,3)),vert_depth,0);
end


%% now do the rendering:
%get all the pixels whose rays intersect with the mesh:
ff = find(featureFaceInds_);
[i1,i2] = ind2sub([rendH,rendW],[1:rendH*rendW]);
ptsQ_c=[i2(ff)',i1(ff)']-0.5;
ptsQ_p=[i2(ff)',i1(ff)'];

%ptsQ_c=[i2(ff)',i1(ff)']-0.5;
%ptsQ_p=[i2(ff)',i1(ff)'];


featureFaceInds=featureFaceInds_(ff);
featureFaceInds=sa(featureFaceInds);


%% compute the barycentric coordinates of each pixel that intersects with
%% the mesh:
if options.useAffineBarys
    %using affine barycentric coordinates:
    barysOut = points2BarysKnownTri(ptsPix,msh.faces,ptsQ_c,featureFaceInds);
else
    % using perspective barycentric coordinates.  To do this we intersect
    % the rays with the surface, and compute the barycentric coordinates of
    % the intersection points in 3D:
    rs = imgPts2Rays(camera,ptsQ_c);
    ns = computeTriNorms(msh.faces,ptsxyz_cam);
    cents = computeTriCentroids(ptsxyz_cam,msh.faces);
    nsIntersect = ns(featureFaceInds,:);
    centsIntersect = cents(featureFaceInds,:);
    %get intersection points:
    pIntersect = line_plane_intersect3d_batch(rs(:,1:3),rs(:,4:end),centsIntersect,nsIntersect);
    %compute barycentric coordinates:
    barysOut = points2BarysKnownTri(ptsxyz_cam,msh.faces,pIntersect,featureFaceInds);

end
if isempty(barysOut)
    b1=[];
    b2=[];
    b3=[];
else
    b1=barysOut(:,2);
    b2=barysOut(:,3);
    b3=barysOut(:,4);

end

%compute the projection mask. This is of the same size as the image render,
%and stores a 1 or 0 at each pixel location depending on whether the
%pixel's ray intersect the surface:
ins=find(featureFaceInds);
iid = sub2ind([rendH,rendW],ptsQ_p(ins,2),ptsQ_p(ins,1));
msk = zeros(rendH,rendW);
msk(iid)=1;


%For each pixel whose ray intersects the surface, we need to compute its
%reflectance. For this a Lambertian model is used (extensions will come!)
if options.withRender
    if strcmp(options.rendType,'faceColour')||strcmp(options.rendType,'textureMap')
        [r,backFacing] = computeReflectance(rendH,rendW,ptsQ_p,ptsxyz_cam,msh,light,featureFaceInds,b1,b2,b3,options);
        %now do the rendering:
        switch  options.rendType
            %render using vertex colours:
            case 'faceColour'
                imOut = faceColourRend(rendH,rendW,ptsQ_p,msh,featureFaceInds,r);
                %render using the texture map:
            case 'textureMap'
                imOut=  textureMapRend(rendH,rendW,ptsQ_p,msh,featureFaceInds,b1,b2,b3,r,options.withBackfacing,backFacing);
        end
    end
    if ~options.doubleOut
        imOut=uint8(imOut);
    end
    out = find(~msk(:));

    %if a background colour has been specified, then colour the background
    %pixels:
    if options.colourBackground
        [texImgH,texImgW,numImgDims] = size(imOut);
        for i=1:numImgDims
            Img =  imOut(:,:,i);
            Img(out)=options.bgCol(i);
            imOut(:,:,i)=Img;
        end
    end

    %show the image:
    %figure(1);
    %clf;
    %imshow(uint8(imOut));
end


%% Now process the optional output arguments:
if nargout>2
    %Compute the barycentric mask:
    T = zeros(rendH,rendW,1);
    T(ff)=featureFaceInds;
    B1 = zeros(rendH,rendW,1);
    B2 = zeros(rendH,rendW,1);
    B3 = zeros(rendH,rendW,1);
    B1(ff)=b1;
    B2(ff)=b2;
    B3(ff)=b3;
    baryMask = cat(3,T,B1,B2,B3);
    VisibFaces=unique(featureFaceInds);
    msk=T>0;
end
if isfield(options,'propertyMaps')
    %go through each of the properties, and compute their values:
    %These include the follows:
    %depth: The depth map. pMap.map(i,j) = d = the depth of pixel (i,j)
    %
    %
    %textureMapVal: The values of each pixel back projected onto the
    %texture map. pMap.map(i,j,:) = [r,g,b] = the RGB colour of pixel (i,j)
    %backprojected onto the mesh's texture map.
    %
    %
    %normals_cam: The values of the surface normal (in camera coordinate
    %space at each pixel.
    %pMap.map(i,j,:) = [nx,ny,nz] = the normal at of pixel (i,j) (in camera
    %coordinates)
    for i=1:length(options.propertyMaps)
        switch options.propertyMaps{i}
            case 'depth'
                dpths = baryInterp(msh.faces,ptsxyz_cam(:,3),[featureFaceInds,b1,b2,b3]);

                %d = baryInterp(msh.faces,ptsxyz_cam(:,3),[featureFaceInds(2254),b1(2254),b2(2254),b3(2254)]);



                DMap = zeros(rendH,rendW,1)*nan;
                DMap(ff)=dpths;
                pMap.type =  'depth';
                pMap.map =DMap;
              
            case 'textureMapVal'
                r=ones(length(b1),size(imOut,3));
                textureMapVal = textureMapRend(rendH,rendW,ptsQ_p,msh,featureFaceInds,b1,b2,b3,r,options.withBackfacing,backFacing);
                pMap.type =  'textureMapVal';
                pMap.map =textureMapVal;

            case 'normals_cam'
                norms_v_cam=computeVertNorms(ptsxyz_cam,msh.faces);
                norms_v_cam=-norms_v_cam;
                ns = baryInterp(msh.faces,norms_v_cam,[featureFaceInds,b1,b2,b3]);
                ns=normaliseVectors(ns,2);
                Nx = zeros(rendH,rendW,1)*nan;
                Ny = zeros(rendH,rendW,1)*nan;
                Nz = zeros(rendH,rendW,1)*nan;
                Nx(ff)=ns(:,1);
                Ny(ff)=ns(:,2);
                Nz(ff)=ns(:,3);
                NMap = cat(3,Nx,Ny,Nz);





                %
                %                 nMapx_ = Nx./Nz;
                %                 nMapy_ = Ny./Nz;
                %
                %
                %                 H_edgeR = zeros(3,3);
                % H_edgeR(2,2) = -1;
                % H_edgeR(3,2) = 1;
                % H_edgeC = H_edgeR';
                % T_edgeC=convmtx2(H_edgeC,1500,1500);
                % T_edgeR=convmtx2(H_edgeR,1500,1500);
                %
                % dR = T_edgeC*DMap(:);
                % dC = T_edgeR*DMap(:);
                %
                % Dr = reshape(dR, [1500,1500]+[3 3]-1);
                % Dc = reshape(dC, [1500,1500]+[3 3]-1);
                %
                % Dr__ = conv2(DMap,H_edgeR);
                %  Dr_ = imfilter(DMap,H_edgeR,'replicate');
                %  Dc_ = imfilter(DMap,H_edgeC,'replicate');

                pMap.type =  'normals_cam';
                pMap.map =NMap;
            case 'pixPos3D_cam'
                [XX,YY] = meshgrid([1:camera.pixelResW],[1:camera.pixelResH]);
                pts_img = [XX(:),YY(:)];
                pts_imgPlane = homoMult(inv(camera.params.K),pts_img);
                pts_imgPlane(:,3) = 1;
                depths = DMap(:);
                pixPos3D = [pts_imgPlane(:,1).*depths,pts_imgPlane(:,2).*depths,pts_imgPlane(:,3).*depths];
                pos3DCamx = zeros(camera.pixelResH,camera.pixelResW,1)*nan;
                pos3DCamy = zeros(camera.pixelResH,camera.pixelResW,1)*nan;
                pos3DCamz = zeros(camera.pixelResH,camera.pixelResW,1)*nan;
                pos3DCamx(:) = pixPos3D(:,1);
                pos3DCamy(:) = pixPos3D(:,2);
                pos3DCamz(:) = pixPos3D(:,3);
                pos3DCam = cat(3,pos3DCamx,pos3DCamy,pos3DCamz);
                pMap.type =  'pixPos3D_cam';
                pMap.map =pos3DCam;

        end
        pMaps{i} = pMap;
    end
end
function imOut=faceColourRend(rendH,rendW,ptsQ,msh,featureFaceInds,r)
%Function to do the rendering using the mesh face colours.
%Inputs:
%rendH: render height
%rendW: render width
%ptsQ:  pixel positions
%msh:   mesh to be rendered
%r: reflectances of each pixel
%
%Outputs:
%imOut: RGB image of size (rendH,rendW,3)


ins=find(featureFaceInds);
if ~isfield(msh,'faceColour')
    disp('rendering with face colours, but the mesh has no faceColour field. Using default RGB colour (255,0,0)');
    msh.faceColour.val=zeros(size(msh.faces,1),1);
    msh.faceColour.val(:,1)=255;
else
    if isempty(msh.faceColour.val)
        disp('rendering with face colours, but the mesh has an empty faceColour field. Using default RGB colour (255,0,0)');
        msh.faceColour.val=zeros(size(msh.faces,1),3);
        msh.faceColour.val(:,1)=255;
    end
end

% now compute the intensities of each pixel based on the reflectance and
% face colour (using a Lambertian model)
cl = msh.faceColour.val(featureFaceInds,:);
col = cl.*r;

% build output image:
imoutr = zeros(rendH,rendW)*nan;
imoutg = zeros(rendH,rendW)*nan;
imoutb = zeros(rendH,rendW)*nan;
iid = sub2ind([rendH,rendW],ptsQ(ins,2),ptsQ(ins,1));
imoutr(iid) = col(:,1);
imoutg(iid) = col(:,2);
imoutb(iid) = col(:,3);
imOut = (cat(3,imoutr,imoutg,imoutb));


function imOut = textureMapRend(rendH,rendW,ptsQ,msh,featureFaceInds,b1,b2,b3,r,withBackfacing,backFacing)
%Function to do the rendering using the mesh texture map.
%Inputs:
%rendH: render height
%rendW: render width
%ptsQ:  pixel positions
%msh:   mesh to be rendered
%featureFaceInds: face indices of each pixel
%b1,b2,b3  barycentric coordinates of each pixel
%r: reflectances of each pixel
%
%Outputs:
%imOut: RGB image of size (rendH,rendW,3)

if ischar(msh.texMap.img)
    %load in texture map if it is stored as a string
    img = imread(msh.texMap.img);
else
    img=msh.texMap.img;
end

img=double(img);
iid = sub2ind([rendH,rendW],ptsQ(:,2),ptsQ(:,1));
[texImgH,texImgW,numImgDims] = size(img);

%get the positions of each visible pixel in the mesh's texture map:
uvws = baryInterp(msh.texMap.facesT,msh.texMap.vertexUVW,[featureFaceInds,b1,b2,b3]);
uv_pixCoords = uv2PixCoords(uvws(:,1:2),texImgW,texImgH);

% build the output image:
imOut = zeros(rendH,rendW,numImgDims)*nan;
for i=1:numImgDims
    %compute intensities with linear interpolation:
    Z = ba_interp2(double(img(:,:,i)),uv_pixCoords(:,1),uv_pixCoords(:,2), 'linear');
    if withBackfacing
    else
        Z(backFacing) = 0; %
    end
    A = zeros(rendH,rendW,1)*nan;
    %compute intensities based on lambertian model:
    A(iid)=Z.*r(:,i);
    imOut(:,:,i)=A;
end

function [r,backFacing] = computeReflectance(rendH,rendW,ptsQ,ptsCam,msh,light,ff,b1,b2,b3,options)
%Function to compute the reflectance of each pixel acording to the
%lambertian model.
%Inputs:
%rendH: render height
%rendW: render width
%ptsQ:  pixel positions
%ptsCam: mesh vertex position in camera coordinates
%msh:   mesh to be rendered
%light: cell array of lights
%featureFaceInds: face indices of each pixel
%b1,b2,b3  barycentric coordinates of each pixel
%options: options structure.
%
%
%Outputs:
%r: reflectance of each pixel. This computed by accumumating the amount of
%light striking the surface from each light source acording to the lambertian model.
%backFacing: binary vector indicating whether the surface projected at each
%pixel is backfacing or not.

flipNorms = options.flipNorms;
withBackFacing  = options.withBackfacing;
shadingMethod = options.shadingMethod;

if ~isfield(msh.texMap,'img');
    img = cat(3,ones( rendH,rendW)*255,zeros( rendH,rendW)*255,zeros( rendH,rendW)*255);
else
    if ischar(msh.texMap.img)
        img = imread(msh.texMap.img);
    else
        img=msh.texMap.img;
    end
end
iid = sub2ind([rendH,rendW],ptsQ(:,2),ptsQ(:,1));
[texImgH,texImgW,numImgDims] = size(img);
norms_v=msh.vertexNormals;
if strcmp(shadingMethod,'smooth')
    norms_pix = baryInterp( msh.faces,norms_v,[ff,b1,b2,b3]);
    norms_pix=normaliseVectors(norms_pix,2);
end
if strcmp(shadingMethod,'flat')
    norms_f=computeTriNorms(msh.faces,ptsCam);
    norms_pix=norms_f(ff,:);
end
if flipNorms
    norms_pix=norms_pix*-1;
end
backFacing=norms_pix(:,3)>0;
ss = sum(backFacing)/length(backFacing);
disp([num2str(ss*100) '% of pixels are backfacing']);

r = zeros(length(iid),numImgDims);
for d = 1:numImgDims
    for j=1:length(light)
        L = light{j};
        switch L.type
            case 'directedLight'
                dts = (L.viewDir(1).*norms_pix(:,1)+L.viewDir(2).*norms_pix(:,2)+L.viewDir(3).*norms_pix(:,3));
                dts(dts<0)=0;
                r(:,d)=r(:,d)+dts*L.intens(d);
            case 'ambientLight'
                r(:,d)=r(:,d)+L.intens(d);
            case 'brdfLight'
                fr=model_Torrance(L,norms_pix);
                r(:,d)=r(:,d)+fr*L.intens(d);
        end
        if withBackFacing
        else
            r(backFacing,d)=0;
        end
    end
end


function options = parseOptions(options,msh)
%Function to parse the options structure holding various rendering options. The options structure has the
%following fields:
%
%srcFrame              The coordinate frame of the vertices of the mesh (msh.vertexPos) This is either 'world' or 'camera'
%
%flipNorms             Set options.flipNorms = true if you want to flip the
%                      surface normals
%                      Default: options.flipNorms = false;
%
%colourBackground      Set options.colourBackground = true if you want to colour the background.
%                      Default: options.colourBackground = false
%
%bgCol                 If options.colourBackground = true, then set options.bgCol = [r,g,b] to set the background colour to [r,g,b]
%                      Default: options.colourBackground = [255,255,255]
%
%
%rendType              The rendering type. This can be 'faceColour' or
%                      'textureMap' if it is 'faceColour', then the colours of the mesh faces are
%                      used for the rendering (i.e. it uses the field msh.faceColour. If it is
%                      'textureMap', then rendering is done with a texture map  (i.e. it uses the
%                      field msh.texMap.
%                      Default: options.rendType = faceColour
%
%doubleOut             Set options.doubleOut = true if you want the output
%                      image to be a double, otherwise it will be uint8.
%                      Default: options.doubleOut = false
%
%withoutRender         Set options.withoutRender = true if you do not want
%                      to render the image. This may be used to speed up some time if you only
%                      want to compute other properties, such as the normal map or depth map.
%                      Default: options.withoutRender = false
%
%useAffineBarys        Set options.useAffineBarys = true if you want to
%                      compute the barycentric coordinates of each pixel according to affine
%                      image projection (this is faster to do than using the perspective model,
%                      but it loses accuracy if the projetion of a face is very perspective.
%                      Default: options.useAffineBarys = false

%withBackfacing        Set options.withBackfacing = true if you want to
%                      render the backfacing surfaces. Otherwise they will be rendered as black.
%                      Default: options.withBackfacing = true
%
%shadingMethod         Set options.shadingMethod if you want to specify
%                      either 'smooth' or 'flat' shading
%                      Default: options.shadingMethod = 'smooth'
%
%propertyMaps          Set options.propertyMaps if you want to compute
%                       additional render properties at each pixel. This is a 1xn cell array where
%                       each entry is the name of a property. The property names can be one of the
%                       following: depth, textureMapVal, normals_cam. An entry in
%                       options.propertyMaps means that this property will be computed at each
%                       pixel, in idion to the render. The possible
%                       properties are as follows:
%                       depth: The depth map. pMap.map(i,j) = d = the depth of pixel (i,j)
%
%
%                       textureMapVal: The values of each pixel back projected onto the
%                       texture map. pMap.map(i,j,:) = [r,g,b] = the RGB colour of pixel (i,j)
%                       backprojected onto the mesh's texture map.
%
%
%                       normals_cam: The values of the surface normal (in camera coordinate
%                       space at each pixel.
%                       pMap.map(i,j,:) = [nx,ny,nz] = the normal at of pixel (i,j) (in camera
%                       coordinates)
%
%                       For example, if options.propertyMaps =
%                       {'depth' 'normals_cam'}, then pMaps will be a cell array of 1x2 holdin
%                       the depth and normals of each pixel.

if isfield(options,'flipNorms')
else
    options.flipNorms=false; %true,false
end
if isfield(options,'colourBackground')
else
    options.colourBackground=false;  %true,false
end
if isfield(options,'rendType')
else
    %msh.texMap.facesT
    if isfield(msh.texMap,'vertexUVW')
        %has texture vertices - so do texturemap rendering:
        options.rendType='textureMap'; %'faceColour' 'textureMap'
    else
        options.rendType='faceColour'; %'faceColour' 'textureMap'
    end

end



if isfield(options,'doubleOut')
else
    options.doubleOut=false;  %true,false
end
if isfield(options,'bgCol')
else
    options.bgCol=[255,255,255];
end
if isfield(options,'withRender')
else
    options.withRender=true; %true,false
end
if isfield(options,'useAffineBarys')
else
    options.useAffineBarys=false; %true,false
end
if isfield(options,'withBackfacing')
else
    options.withBackfacing=true; %true,false
end

%if isfield(options,'texMapMask')
%else
%    options.texMapMask=[];
%end

if isfield(options,'shadingMethod')
else
    options.shadingMethod='smooth'; %'smooth' 'flat';
end

