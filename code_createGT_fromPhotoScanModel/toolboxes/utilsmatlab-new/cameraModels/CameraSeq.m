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
                i
               cam =  CameraP_D;
               cam = initFromPhotoScan(cam, camData{i});
               obj.CameraDevices{i} = cam;       
            end
         end 
         function obj = loadFromPhotoScan2(obj,pth)
            assert(ischar(pth));
            camData = xml2struct2(pth);
            sensorData=camData.document.chunk.sensors.sensor;
            camData = camData.document.chunk.cameras.camera;
            numCams = length(camData);
            obj.numFrames = numCams;
            obj.CameraDevices = cell(1,numCams);
            for i=1:numCams
               cam =  CameraP_D;
               cam = initFromPhotoScan2(cam, camData{i}, sensorData);
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
         function obj = loadFromTheia(obj,pth) % pth = dir with '*.tif.pose' files   
            posefile=dir([pth '/*.jpg.pose']);
            obj.numFrames = length(posefile);
            if(length(posefile)==0)
                disp(['[Error] ''' pth ''' contents no ''pose'' files.']);
            end
            obj.CameraDevices = cell(1,obj.numFrames);
            for i=1:obj.numFrames
                T = zeros(3,1);
                R = zeros(3,3);
                K = zeros(3,3);
                kc = zeros(3,1);
                cam = CameraP_D;
                
                disp(['Reading ' pth posefile(i).name]);
                fid = fopen([pth posefile(i).name]);
                data = textscan(fid, '%s','delimiter','\r\n');
                data = data{1,1};
                % -- translation
                T = [str2double(data(2)); str2double(data(3)); str2double(data(4))];
                % -- rotation
%                 format long;
                R(1,:) = str2double(strsplit(char(data(7))));
                R(2,:) = str2double(strsplit(char(data(8))));
                R(3,:) = str2double(strsplit(char(data(9))));
                % -- calibration
                K(1,:) = str2double(strsplit(char(data(12))));
                K(2,:) = str2double(strsplit(char(data(13))));
                K(3,:) = str2double(strsplit(char(data(14))));
                % -- distortions
                disto = str2double(strsplit(char(data(17))));
                kc = [disto(1);disto(2);0;0;0];
                % -- size
                size = str2double(strsplit(char(data(20))));
                W = size(1);
                H = size(2);
                T
                R
                K
                W
                H
                cam.T = T;
                cam.R = R;
                cam.K = K;
                cam.kc = kc;
                cam.pixelResW = W;
                cam.pixelResH = H;
                obj.CameraDevices{i} = cam;
              
                fclose(fid);
            end
         end
    end
    
end