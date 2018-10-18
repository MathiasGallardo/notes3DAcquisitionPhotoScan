function batchUndistort(calibf,im_dir,im_ext)
%Script to batch undistort a directory of images using a matlab calibration
%from the Camera Calibration Toolbox
%Toby Collins 2009
%
%Example use:
%calibf = 'F:\data_colonoscope\laserTests1\calib\Calib_Results';
%im_dir = 'F:\data_colonoscope\laserTests1\laserChecker\';
%im_ext = 'bmp';
calibData = load(calibf);
if isfield(calibData,'calibData')
    calibData = calibData.calibData
end
close all
%load(calibf,'fc','cc','kc','alpha_c') ;
KK = [calibData.fc(1) calibData.alpha_c*calibData.fc(1) calibData.cc(1);0 calibData.fc(2) calibData.cc(2) ; 0 0 1];
%n_ima = 1 ;
%ind_active = 259 ;
%calib_name ='Untitled' ;
%format_image ='jpg' ;
imgs = dir([im_dir '/*.' im_ext]);
mkdir(sprintf('%s/undistorted',im_dir)) ;
for i=1:length(imgs)
    i
    imName = [im_dir imgs(i).name];
    switch im_ext
        
        case 'mat'
            I = load(imName); I = I.im_unV;
        otherwise   
             I = im2double(imread(imName)) ;
             
    end
    %fprintf(sprintf('%s/%s%04d.%s\n',im_dir,im_name,im_active(i),im_ext)) ;
   
    %figure(1); imshow(I);
    I2(:,:,1) = rect(I(:,:,1),eye(3),calibData.fc,calibData.cc,calibData.kc,calibData.alpha_c,KK);
    I2(:,:,2) = rect(I(:,:,2),eye(3),calibData.fc,calibData.cc,calibData.kc,calibData.alpha_c,KK);
    I2(:,:,3) = rect(I(:,:,3),eye(3),calibData.fc,calibData.cc,calibData.kc,calibData.alpha_c,KK);
   
    [aa,ab,ac] = fileparts(imName);  
     switch im_ext       
        case 'mat'
             imOutf = [im_dir 'undistorted/' ab '.mat' ];
             save(imOutf,'I2');          
         otherwise   
             I2 = im2uint8(I2) ;
             imOutf = [im_dir 'undistorted/' ab '.tif' ];
             imwrite(I2,imOutf) ;
     end  
    clear I1 I2; 
end
%keyboard;