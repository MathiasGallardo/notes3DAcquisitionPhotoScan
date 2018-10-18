classdef  CameraP < CameraDevice
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        K;
        Ks;
    end  
    methods
        function obj = set.K(obj,K)
            assert(size(K,1)==3&size(K,2)==3);
            assert(norm(K(3,:)-[0,0,1])<eps);
            obj.K = K;
        end
        function K = get.K(obj)
            K = obj.K;
        end
        
        function ps3dCam = ps3d2CamFrame(obj,ps3d)
            ps3dCam = obj.R*ps3d;
            ps3dCam(1,:) =  ps3dCam(1,:)+obj.T(1);
            ps3dCam(2,:) =  ps3dCam(2,:)+obj.T(2);
            ps3dCam(3,:) =  ps3dCam(3,:)+obj.T(3);
        end    
        
         function ps3dWorld = psCamFrame2World(obj,ps3dCam)
             M = [obj.R,obj.T];
             M(4,4) = 1;
             Minv = inv(M);
             Rinv = Minv(1:3,1:3);
             Tinv = Minv(1:3,end);
             
            ps3dWorld = Rinv*ps3dCam;
            ps3dWorld(1,:) =  ps3dWorld(1,:)+Tinv(1);
            ps3dWorld(2,:) =  ps3dWorld(2,:)+Tinv(2);
            ps3dWorld(3,:) =  ps3dWorld(3,:)+Tinv(3);
         end    
        
            
        function ps2d = project(obj,ps3d)
            ps3dCam = obj.R*ps3d;
            ps3dCam(1,:) =  ps3dCam(1,:)+obj.T(1);
            ps3dCam(2,:) =  ps3dCam(2,:)+obj.T(2);
            ps3dCam(3,:) =  ps3dCam(3,:)+obj.T(3);
            ps2d = obj.K*ps3dCam;
            ps2d(1,:) = ps2d(1,:)./ps2d(3,:);
            ps2d(2,:) = ps2d(2,:)./ps2d(3,:);
            ps2d = ps2d(1:2,:);
           
        end
        
        
        function obj = initFromMesh(obj,msh,resWH)
            resW = resWH(1);
            resH = resWH(2);
            
            cmOpt.res = [resW,resH];
            camera = initPerspectiveCam(msh,cmOpt);
            obj.pixelResH = resH;
            obj.pixelResW = resW;
            obj.K = camera.params.K;
            obj.R = camera.params.R;
            obj.T = camera.params.T;       
        end  
        
        function obj = viewMesh(obj,mesh)
           mm = mean(mesh.vertexPos,1);
           mm(3) = min(mesh.vertexPos(:,3));
           T = eye(4);
           T(1:3,end) = -mm;
           v = homoMult(T,mesh.vertexPos);
           maxX = max(v(:,1));
           maxY = max(v(:,2));
           
           minX = min(v(:,1));
           minY = min(v(:,2));
           
%            syms k11 k12 k13;
%            syms k21 k22 k23;
%            syms k31 k32 k33;
%            
%            K = [k11 k12 k13;k21 k22 k23;k31 k32 k33;];
%            syms x y z d xPix yPix;
%            px = (K(1,:)*[x;y;z+d])/(K(3,:)*[x;y;z+d]) - xPix;
%            py = (K(2,:)*[x;y;z+d])/(K(3,:)*[x;y;z+d]) - yPix;
%            ss1 = solve(px,d);
%            ss2 = solve(py,d);
           
           xPixL = obj.pixelResW/15;
           yPixT = obj.pixelResH/15;
           
           xPixR = obj.pixelResW- obj.pixelResW/15;
           yPixB = obj.pixelResH - obj.pixelResH/15;
           
           if obj.K(1,1)>0
               x = minX;
           else
               x = maxX;
           end
           if obj.K(2,2)>0
                y = minY;
           else
               y = maxY;
           end
           z = 0;
           d1 = - z - (obj.K(1,1)*x + obj.K(1,2)*y - xPixL*(obj.K(3,1)*x + obj.K(3,2)*y))/(obj.K(1,3) - obj.K(3,3)*xPixL);
           d2 = - z - (obj.K(2,1)*x + obj.K(2,2)*y - yPixT*(obj.K(3,1)*x + obj.K(3,2)*y))/(obj.K(2,3) - obj.K(3,3)*yPixT);
           d = max([d1,d2]);
           obj.T = [0;0;d]-mm';
           obj.R = eye(3);

           
        end
        
    end   
end

