function buildInvivoModelExample(dataDir,Ext,numViews)

if(nargin<3)
    Ext='tif'
end

dirOut = [dataDir '/invivoTemplate_001'];
model = InvivoSfMModel; % from utilsmatlab-new
model.surfaceMesh = read3dMesh([dataDir '/photoScanModel/modelCropped.obj']);
model.buildMethod = 'photoScan';
%model.rawFrameDir = 'E:\myomaProject_data\database\withMRI\internalMyoma\Joly_Patricia_\video\rigidSubset6\undistorted';
model.rawFrameDir = [dataDir '/undistorted'];
model.rawFrameDir;
model.rawFrameNames = rdir(model.rawFrameDir, ['/*.',Ext]);
model.camSeq = CameraSeq;
model.camSeq = model.camSeq.loadFromPhotoScan([dataDir '/photoScanModel/PSCameras.xml']);
mkdir(dirOut);
fout = [dirOut '/model.mat'];
save(fout,'model');
% Undistort the images and compute the Barycentric Maps
computeBaryMaps(fout,numViews);