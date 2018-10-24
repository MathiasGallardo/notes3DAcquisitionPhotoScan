% b_compute3D_from2Dpoints.m
% This script estimates the 3D location of the image points using the
% barycentric map computed by 01_createGT_fromPhotoScanModel.m
%
% PREREQUISITES:
% imagePoints: the 2D points for which we want the 3d location in the
% camera coordinates of the camera view defined by numViews
%
% Authors: Mathias Gallardo
% E-mail: Mathias.Gallardo@gmail.com
% Date: 18/10/2018
%

%% PATHS
path2Data = '.'; % path to the root of the folder 'undistorted' and 'photoScanModel'
path2Undistort = [path2Data '/undistorted/']; % path to the undistorted images computed from PhotoScan or others

path23DModel = [path2Data '/3DModel/'];
path2PhotoScanModel = [path2Data '/photoScanModel/img_0001.obj'];
path2PhotoScanCameras = [path2Data '/photoScanModel/PSCameras.xml'];
path2Undistorted = [path2Data '/undistorted/'];
path2ImagePts = './imagePoints/';
formatImagesUndistorted = 'png';

numViews = 17; % the views index for which you want to compute the 3D points; can be a list

scalePS2mm = 1; % the scale between the real distance and the distance on the 3D model (here, it is fixed arbitrarily)

%% LOAD THE 2D IMAGE POINTS GIVEN BY THE USER
C = load([path2ImagePts 'imagePoints.mat']);

%% LIST ALL IMAGES IN THE FOLDER
nfiles = dir([path2Undistorted '*.' formatImagesUndistorted]);

%% COMPUTE THE 3D OF THE IMAGE POINTS
for i = 1:length(numViews)
    % Get the 3D data for each view
    GT = load([path23DModel '/views_undistorted/',nfiles(numViews(i)).name(1:end-4),'_GT']);
    faces = GT.P.faces;
    vertexPos = GT.P.vertexPos';
    baryMask = GT.P.B;
    
    % Load the associated image
    image = imread([path2Undistorted,nfiles(numViews(i)).name(1:end-4) '.' formatImagesUndistorted]);

    % Get the image points given by the user
    pts2D = C.imagePoints.ptsImg{numViews(i)};

    % Estimate the closest mesh face for each image point
    FMap = ba_interp2(double(baryMask(:,:,1)),pts2D(1,:),pts2D(2,:),'nearest');

    % Estimate the barycentric weights for each image point
    b1Map = ba_interp2(double(baryMask(:,:,2)),pts2D(1,:),pts2D(2,:),'nearest');
    b2Map = ba_interp2(double(baryMask(:,:,3)),pts2D(1,:),pts2D(2,:),'nearest');
    b3Map = ba_interp2(double(baryMask(:,:,4)),pts2D(1,:),pts2D(2,:),'nearest');

    % Clean
    idx0 = find(FMap<1);
    FMap(idx0) = [];
    b1Map(idx0) = [];
    b2Map(idx0) = [];
    b3Map(idx0) = [];

    px = pts2D(1,:);
    py = pts2D(2,:);
    px(idx0) = [];
    py(idx0) = [];

    % Compute the 3D points using the barycentric weights and mesh faces
    P1=vertexPos(:,faces(FMap,1));
    P2=vertexPos(:,faces(FMap,2));
    P3=vertexPos(:,faces(FMap,3));
    pts3D = zeros(length(b1Map),3);
    for j = 1:length(b1Map)
        pts3D(j,:)=b1Map(j).*P1(:,j)+b2Map(j).*P2(:,j)+b3Map(j).*P3(:,j);
    end


    % Put the 3D at the correct scale
    pts3D = pts3D*scalePS2mm;
    
    % Display
    figure(i);
    clf;
    subplot(121);
    imshow(image);
    hold on;
    plot(pts2D(1,:),pts2D(2,:),'r+');
    hold off;
    title(['2D correspondences for ' nfiles(numViews(i)).name(1:end-4)]);
    subplot(122);
    plot3(pts3D(:,1),pts3D(:,2),pts3D(:,3),'r.');
    axis equal;
    title(['3D correspondences for ' nfiles(numViews(i)).name(1:end-4)]);
end