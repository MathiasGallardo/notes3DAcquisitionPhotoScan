function renderSpinningBox
%renderSpinningBox - an example of how to render a 3d surface with time
%varying vertex positions, and changing the texture map.

% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

Msh = read3dMesh('/home/raquel/Workspace/Uterus/distribution/testData/box.obj');
camOp = struct;
camOp.res = [500,500];
camera = initPerspectiveCam(Msh,camOp); %initialises a perspective

%camera that looks at the mesh.
light = []; %not specifying a light model
options.srcFrame = 'world';
options.shadingMethod='flat';


mm = mean(Msh.vertexPos,1);

%loop a sequence of rotations
rvec = [1,0,0];
angles = linspace(0,2*pi,30);
vertsPosBox = Msh.vertexPos;
for i=1:length(angles)
   r =  rvec*angles(i);
   R = RodriguezRotate2ndOrd(r);
   R(4,4) = 1;
   MT = eye(4);
   MT(1:3,end) = -mm;
   Mbox = inv(MT)*R*MT;
   vertsFrame = homoMult(Mbox,vertsPosBox);
   Msh.vertexPos = vertsFrame;
   [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] =       z_bufferMesh(camera,Msh,light,options);
   figure(1);
   clf;
   imshow(uint8(imOut));
   
end

%change the texture map:
texture2 = imread('./testData/texture2.jpg');
Msh.texMap.img = texture2;

%rerender:
for i=1:length(angles)
   r =  rvec*angles(i);
   R = RodriguezRotate2ndOrd(r);
   R(4,4) = 1;
   MT = eye(4);
   MT(1:3,end) = -mm;
   Mbox = inv(MT)*R*MT;
   vertsFrame = homoMult(Mbox,vertsPosBox);
   Msh.vertexPos = vertsFrame;
   [imOut,msk,baryMask,ptsPix,VisibFaces,pMaps] =       z_bufferMesh(camera,Msh,light,options);    
   figure(1);
   clf;
   imshow(uint8(imOut));
end







