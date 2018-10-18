function maskimages(th)
files=dir('*.tif');
for i=[1:length(files)]
basename=strtok(files(i).name,'.tif');
I=imread(files(i).name);
I(I<th)=0;
I(I>=th)=255;
imshow(I);
imwrite(I,['masks/',basename,'_mask.tif']);
end
