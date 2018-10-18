classdef  CameraVirtual < CameraDevice
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        render = Render;
    end  
    methods
        %function obj = set.K(obj,K)
        %    assert(size(K,1)==3&size(K,2)==3);
        %    assert(norm(K(3,:)-[0,0,1])<eps);
        %    obj.K = K;
        %end
        function render = doRender(mesh3D)
          
        end
        
    end
    
end