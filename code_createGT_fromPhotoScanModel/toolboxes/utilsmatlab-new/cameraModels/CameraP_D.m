classdef  CameraP_D < CameraP
    %distorted perspective camera
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        kc;
        distort2PinholeMap;
        
        %%do not use
        k1;
        k2;
        k3;
        p1;
        p2;
        
        
    end  
    methods
        function obj = set.kc(obj,kc)
            assert(size(kc,1)==5&size(kc,2)==1);
            obj.kc = kc;
        end
        function kc = get.kc(obj)
            kc = obj.kc;
        end
        
        function obj = initFromCCToolbox(obj, fin)
            %resW = res(1);
            %resH = res(2);
            
            cmOpt.res = [resW,resH];
            camera = initPerspectiveCam(msh,cmOpt);
            obj.pixelResH = resH;
            obj.pixelResW = resW;
            obj.K = camera.params.K;
            obj.R = camera.params.R;
            obj.T = camera.params.T;       
        end  
        
        function obj = initFromPhotoScan(obj,camDataPS)
            %resW = res(1);
            %resH = res(2);
            obj.pixelResH = str2num(camDataPS.resolution.Attributes.height);
            obj.pixelResW = str2num(camDataPS.resolution.Attributes.width);
            if(isfield(camDataPS,'transform'))
            M = str2num( camDataPS.transform.Text);
            M = reshape(M,[4,4])';
            M  = inv(M );
            obj.R = M(1:3,1:3);
            obj.T = M(1:3,end);
            
            K = eye(3);
            K(1,1) =  str2num(camDataPS.calibration.fx.Text);
            K(2,2) =  str2num(camDataPS.calibration.fy.Text);
            K(1,2) =  str2num(camDataPS.calibration.skew.Text);
            K(1,3) =  str2num(camDataPS.calibration.cx.Text);
            K(2,3) =  str2num(camDataPS.calibration.cy.Text);
            obj.K = K;
            obj.kc = zeros(5,1);
            obj.kc(1) = str2num(camDataPS.calibration.k1.Text);
            obj.kc(2) = str2num(camDataPS.calibration.k2.Text);
            obj.kc(5) = str2num(camDataPS.calibration.k3.Text);
            
            obj.kc(3) = str2num(camDataPS.calibration.p1.Text);
            obj.kc(4) = str2num(camDataPS.calibration.p2.Text);                
            end
            
            
        end 
        function obj = initFromPhotoScan2(obj,camDataPS,sensorData)
           
            obj.pixelResH = str2num(sensorData.resolution.Attributes.height);
            obj.pixelResW = str2num(sensorData.resolution.Attributes.width);
            if(isfield(camDataPS,'transform'))
            M = str2num( camDataPS.transform.Text);
            M = reshape(M,[4,4])';
            M  = inv(M );
            obj.R = M(1:3,1:3);
            obj.T = M(1:3,end);
            K = eye(3);
            if(iscell(sensorData.calibration))
            calibration=sensorData.calibration{1};
            else
            calibration=sensorData.calibration;    
            end
                        
            K(1,1) =  str2num(calibration.fx.Text);
            K(2,2) =  str2num(calibration.fy.Text);
            K(1,2) =  0;%str2num(sensorData.calibration{1}.skew.Text);
            K(1,3) =  str2num(calibration.cx.Text);
            K(2,3) =  str2num(calibration.cy.Text);
            obj.K = K;
            obj.kc = zeros(5,1);
            if(isfield(calibration,'k1'))
            obj.kc(1) = str2num(calibration.k1.Text);
            end
            if(isfield(calibration,'k2'))
            obj.kc(2) = str2num(calibration.k2.Text);
            end
            if(isfield(calibration,'k3'))
            obj.kc(5) = str2num(calibration.k3.Text);            
            end
            if(isfield(calibration,'p1'))
            obj.kc(3) = str2num(calibration.p1.Text);
            end
            if(isfield(calibration,'p2'))
            obj.kc(4) = str2num(calibration.p2.Text);                
            end
            end
            
        end 
        
    end   
end

