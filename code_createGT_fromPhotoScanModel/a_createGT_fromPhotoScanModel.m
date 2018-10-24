% a_createGT_fromPhotoScanModel.m
% This script creates ground-truth data from a model constructed with
% PhotoScan. For each desired view, it outputs the mesh
% vertices/faces/barycentric map (in '*_GT.mat')
%
% PREREQUISITES:
% photoScanModel: the .mtl, .obj and the .png (texture-map) files and the
% .xml file with all cameras aligned by PhotoScan (Workflow -> Align
% Cameras; Photo -> Export Camera -> name the file 'PSCameras.xml'
% undistorted: all the undistorted images used to computed the 3D model
% with PhotoScan
%
% Authors: Mathias Gallardo
% E-mail: Mathias.Gallardo@gmail.com
% Date: 18/10/2018
%

%% TOOLBOXES
addpath(genpath('./toolboxes/'));

%% PATHS
path2Data = '.'; % path to the root of the folder 'undistorted' and 'photoScanModel'
path2Undistort = [path2Data '/undistorted/']; % path to the undistorted images computed from PhotoScan or others

path23DModel = [path2Data '/3DModel/'];
path2PhotoScanModel = [path2Data '/photoScanModel/img_0001.obj'];
path2PhotoScanCameras = [path2Data '/photoScanModel/PSCameras.xml'];
path2Undistorted = [path2Data '/undistorted/'];
formatImagesUndistorted = 'png';

%% DEFINE THE DESIRED VIEWS 
numViews = 17; % the views index for which you want to compute the barycentric map; can be a list

scalePS2mm = 1; % the scale between the real distance and the distance on the 3D model (here, it is fixed arbitrarily)

%% LIST ALL IMAGES IN THE FOLDER
nfiles = dir([path2Undistort '*.' formatImagesUndistorted]);

%% 
build3DModelFromPhotoScan(path23DModel,...
                            path2PhotoScanModel,...
                            path2PhotoScanCameras,...
                            path2Undistorted,...
                            formatImagesUndistorted,...
                            numViews);

%% LOAD THE MODEL
model = load([path23DModel '/model.mat']);  % generated automatically
model = model.model;

%% COMPUTE THE BARYCENTRIC MAP FOR EACH VIEW
for i = 1:length(numViews)
    
    load([path23DModel '/views_undistorted/',nfiles(numViews(i)).name(1:end-4),'_BaryMap.mat']);    % generated automatically

    vertexPos = model.surfaceMesh.vertexPos';

    % Get camera parameters
    K=model.camSeq.CameraDevices{numViews(i)}.K;
    R=model.camSeq.CameraDevices{numViews(i)}.R;
    T=model.camSeq.CameraDevices{numViews(i)}.T;
    
    % Move vertexPos to camera origin
    vertexPos = R*vertexPos+repmat(T,1,size(vertexPos,2));
    vertexPos = vertexPos';
    faces = model.surfaceMesh.faces;   
    
    %
    P.vertexPos = vertexPos; % scalePS2mm should be put as factor if you want to put the GT at the correct scale. 
    % Be careful: if you plan to use the GT to compute later the 3D
    % position of other 2D points using the barycentric map, REMOVE the
    % scale!!!
    
    P.faces = faces;
    P.B = B; % Add the barycentric map
    save([path23DModel '/views_undistorted/',nfiles(numViews(i)).name(1:end-4),'_GT'],'P');    
end
