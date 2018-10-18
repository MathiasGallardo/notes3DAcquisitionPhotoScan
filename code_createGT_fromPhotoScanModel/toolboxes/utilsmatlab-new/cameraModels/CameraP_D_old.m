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
            obj.pixelResH = str2num(camDataPS{1}.resolution.Attributes.height);
            obj.pixelResW = str2num(camDataPS{1}.resolution.Attributes.width);
            if(isfield(camDataPS{1},'transform'))
            M = str2num( camDataPS{1}.transform.Text);
            M = reshape(M,[4,4])';
            M  = inv(M );
            obj.R = M(1:3,1:3);
            obj.T = M(1:3,end);
           
            K = eye(3);
            if length(camDataPS{2}.sensor)>1 % more than one camera
                if length(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration)>1
                    K(1,1) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.fx.Text);
                    K(2,2) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.fy.Text);
                    K(1,2) =  1e-10;%str2num(camDataPS.calibration.skew.Text);
                    K(1,3) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.cx.Text);
                    K(2,3) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.cy.Text);
                    obj.K = K;
                    obj.kc = zeros(5,1);
%                     obj.kc(1) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.k1.Text);
%                     obj.kc(2) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.k2.Text);
%                     obj.kc(5) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration{2}.k3.Text);
                else
                    K(1,1) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.fx.Text);
                    K(2,2) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.fy.Text);
                    K(1,2) =  1e-10;%str2num(camDataPS.calibration.skew.Text);
                    K(1,3) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.cx.Text);
                    K(2,3) =  str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.cy.Text);
                    obj.K = K;
                    obj.kc = zeros(5,1);
%                     obj.kc(1) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.k1.Text);
%                     obj.kc(2) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.k2.Text);
%                     obj.kc(5) = str2num(camDataPS{2}.sensor{str2num(camDataPS{1}.Attributes.sensor_id)+1}.calibration.k3.Text);
                end
                
            else
                if length(camDataPS{2}.sensor.calibration)>1
                    K(1,1) =  str2num(camDataPS{2}.sensor.calibration{2}.fx.Text);
                    K(2,2) =  str2num(camDataPS{2}.sensor.calibration{2}.fy.Text);
                    K(1,2) =  1e-10;%str2num(camDataPS.calibration.skew.Text);
                    K(1,3) =  str2num(camDataPS{2}.sensor.calibration{2}.cx.Text);
                    K(2,3) =  str2num(camDataPS{2}.sensor.calibration{2}.cy.Text);
                    obj.K = K;
                    obj.kc = zeros(5,1);
%                     obj.kc(1) = str2num(camDataPS{2}.sensor.calibration{2}.k1.Text);
%                     obj.kc(2) = str2num(camDataPS{2}.sensor.calibration{2}.k2.Text);
%                     obj.kc(5) = str2num(camDataPS{2}.sensor.calibration{2}.k3.Text);
                else
                    K(1,1) =  str2num(camDataPS{2}.sensor.calibration.fx.Text);
                    K(2,2) =  str2num(camDataPS{2}.sensor.calibration.fy.Text);
                    K(1,2) =  1e-10;%str2num(camDataPS.calibration.skew.Text);
                    K(1,3) =  str2num(camDataPS{2}.sensor.calibration.cx.Text);
                    K(2,3) =  str2num(camDataPS{2}.sensor.calibration.cy.Text);
                    obj.K = K;
                    obj.kc = zeros(5,1);
%                     obj.kc(1) = str2num(camDataPS{2}.sensor.calibration.k1.Text);
%                     obj.kc(2) = str2num(camDataPS{2}.sensor.calibration.k2.Text);
%                     obj.kc(5) = str2num(camDataPS{2}.sensor.calibration.k3.Text);
                end
            end
            
%             
%             obj.kc(3) = 1e-10;%str2num(camDataPS.calibration.p1.Text);
%             obj.kc(4) = 1e-10;%str2num(camDataPS.calibration.p2.Text);                
            end
            
            
        end 
        
        
    end   
end

