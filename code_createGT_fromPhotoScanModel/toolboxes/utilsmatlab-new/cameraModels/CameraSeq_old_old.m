classdef CameraSeq
    %addpath('C:\collins\sourceCode3\xmlStruct')
    properties
        CameraDevices
        numFrames;
    end
    methods
        function obj = set.numFrames(obj,n)
            assert(n>=0);
            obj.numFrames = n;
        end      
        function obj = setCamera(obj,cam,ind)
            obj.CameraDevices{ind} = cam;
        end  
        
         function obj = loadFromPhotoScan(obj,pth)
            assert(ischar(pth));
            camData = xml2struct2(pth);
            camData = camData.collection.cameras.camera;
            numCams = length(camData);
            obj.numFrames = numCams;
            obj.CameraDevices = cell(1,numCams);
            for i=1:numCams
               cam =  CameraP_D;
               cam = initFromPhotoScan(cam, camData{i});
               obj.CameraDevices{i} = cam;       
            end
         end 
        
         function obj = loadFrom3DSExport(obj,pth)
            assert(ischar(pth));
            Cam = computeCamMats_3ds(pth,'rot');
            obj.numFrames = length(Cam.sequence);
            obj.CameraDevices = cell(1,obj.numFrames);
            for i=1:obj.numFrames
               %cam =  CameraP_D;
               cam =  CameraP_virtual;
               cam.K = Cam.sequence(i).params.K;
               cam.R = Cam.sequence(i).params.R;
               cam.T = Cam.sequence(i).params.T;

                e = eye(3);
                e(2,2) = -1;
                cam.K = cam.K*e;
                cam.R = inv(e)*cam.R;
                cam.T = inv(e)*cam.T;

               
               cam.pixelResH = Cam.pixelResH;
               cam.pixelResW = Cam.pixelResW;
               obj.CameraDevices{i} = cam;       
            end
         end 
         
         
    end
    
end