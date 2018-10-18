classdef CameraDevice
    properties
        pixelResH;
        pixelResW;
        R;
        T;
  
    end
    
    methods
        function obj = set.pixelResH(obj,pixelResH)
            assert(pixelResH>0);
            obj.pixelResH = pixelResH;
        end
        function pixelResH = get.pixelResH(obj)
            pixelResH = obj.pixelResH;
        end
        function obj = set.pixelResW(obj,pixelResW)
            assert(pixelResW>0);
            obj.pixelResW = pixelResW;
        end
        
        function pixelResW = get.pixelResW(obj)
            pixelResW = obj.pixelResW;
        end
        
        function obj = set.R(obj,R)
            assert(size(R,1)==3&size(R,2)==3);
            assert(norm(R'*R-eye(3))<=(1e-8));
            obj.R = R;
        end
        
        function R = get.R(obj)
            R = obj.R;
        end
        
        function obj = set.T(obj,T)
            assert(size(T,1)==3&size(T,2)==1);
            obj.T = T;
        end
        
        function T = get.T(obj)
            T = obj.T;
        end 
        function initFromCCToolbox(fin);
            
            
        end
        
        function psPix =project3D(psWorld)
           
        end
        function obj = viewMesh(obj,mesh)
           
        end  
    end
end

