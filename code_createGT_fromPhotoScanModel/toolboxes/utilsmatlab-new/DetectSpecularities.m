function mask=DetectSpecularities(I,alpha)
if(nargin<2)
 alpha=220;   
end
 mask=255.*ones(size(I,1),size(I,2));
pidx=find(I(:,:,1)>alpha & I(:,:,2)>alpha & I(:,:,3)>alpha);
mask(pidx)=0;
end
