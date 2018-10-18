function [ images, imagefiles ] = getImagesInFolder( folderpath )
% get all .jpg images in a folder using matlab dir.
% images is a cell array
curdir = pwd;
cd(folderpath);
imagefiles = dir('*.JPG');      
nfiles = length(imagefiles);    % Number of files found
for ii=1:nfiles
   currentfilename = imagefiles(ii).name;
   currentimage = imread(currentfilename);
   images{ii} = currentimage;
end
% keyboard;
cd(curdir);
end

