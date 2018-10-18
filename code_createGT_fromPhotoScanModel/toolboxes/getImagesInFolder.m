function [ images, imagefiles ] = getImagesInFolder( folderpath, formatImages )
% get all images in a folder using matlab dir.
% images is a cell array
imagefiles = dir([folderpath '*.', formatImages]);      
nfiles = length(imagefiles);    % Number of files found
images = cell(1,nfiles);
for ii=1:nfiles
   currentfilename = [ folderpath imagefiles(ii).name];
   currentimage = imread(currentfilename);
   images{ii} = currentimage;
end
end

