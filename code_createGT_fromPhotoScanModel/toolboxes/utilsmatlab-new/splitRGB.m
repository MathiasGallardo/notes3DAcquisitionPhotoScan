function splitRGB(dirin,extension)
%Script tosplit a directory of images into their red, blue and green
%components. This creates sub-directories for each colour channel.
%Toby Collins 2009
%Example use:
%dirin = 'E:\myomaProject_data\database\hysterectomies_marked\thain_christiane_19530514__20130131_1301311003\Videos\rigidSubset1\undistorted';
%extension = 'tiff';

files = rdir([dirin],[ '/*.', extension]);
dirR = [dirin '/red'];
dirG = [dirin '/blue'];
dirB = [dirin '/green'];

mkdir(dirR);
mkdir(dirG);
mkdir(dirB);

%extension = 'tif';
for i=1:length(files)
   f = imread([dirin,'/',files(i).name]);
   [aa,ab,ac] = fileparts(files(i).name);
   fout = [dirR '/' ab '.' extension];
   imwrite(f(:,:,1),fout);
   
    fout = [dirG '/' ab '.' extension];
   imwrite(f(:,:,2),fout);
   
   fout = [dirB '/' ab '.' extension];
   imwrite(f(:,:,3),fout);
   
   
end
