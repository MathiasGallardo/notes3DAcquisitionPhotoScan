classdef  Render
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    properties
        RendRGB;       
        rendMask;
        dMap;
        baryMap;
    end  
    methods
        function obj = setRenderDims(obj,rendW,rendH)
           obj.RendRGB = single(zeros(rendH,rendW,3));
           obj.rendMask = logical(zeros(rendH,rendW));
           obj.dMap = single(zeros(rendH,rendW))*1;
           obj.baryMap = single(zeros(rendH,rendW,4));        
        end
    end
    
end