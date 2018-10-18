function computeBaryMaps(modelf,numViews)


[dirIn,ab,ac] = fileparts(modelf);
mkdir(sprintf('%s/views_undistorted',dirIn)) ;
model = load(modelf);
model=model.model;


for i=numViews'
    i
    cam = model.camSeq.CameraDevices{i};   
    if(length(cam.K)>0)
        model.rawFrameNames(i).name
        img = imread([model.rawFrameDir,'/',model.rawFrameNames(i).name]);   
        fc = [cam.K(1,1);cam.K(2,2)];
        cc = cam.K(1:2,end);
        kc = cam.kc;
        alpha_c = cam.K(1,2);   
        I_u = doUndistort(img,fc,cc,kc,alpha_c,cam.K);
        figure(1);
        clf;
        imshow(uint8(I_u));   
        [aa,ab,ac] = fileparts([model.rawFrameDir,'/',model.rawFrameNames(i).name]);
        fout = [dirIn '/views_undistorted/' ab '.tif'];
        imwrite(uint8(I_u),fout);    
        cam_ = CameraP_virtual;
        cam_.K = cam.K;
        cam_.pixelResH = cam.pixelResH;
        cam_.pixelResW = cam.pixelResW;
        cam_.R = cam.R;
        cam_.T = cam.T;   
        %cam_.R = eye(3);
        %cam_.T(3) = cam_.T(3)-10;
        %m2 =  read3dMesh('E:\tmp\msh2.obj');
    %    figure(4);
    %    clf;
    %    plot3(cam_.T(1),cam_.T(2),cam_.T(3),'k.');
    %    hold on;    
    %    %plot3(m2.vertexPos(:,1),m2.vertexPos(:,2),m2.vertexPos(:,3),'r.');
    %    %hold on;
    %    plot3(model.surfaceMesh.vertexPos(:,1),model.surfaceMesh.vertexPos(:,2),model.surfaceMesh.vertexPos(:,3),'b.');
    %    axis equal;    
        cam_ = cam_.doRender(model.surfaceMesh);
        %figure(2);
        %clf;
        %imshow(uint8(cam_.render.RendRGB));    
        figure(2);
        clf;
        imshow(uint8((cam_.render.baryMap(:,:,1)>0)*255));  
    %    figure(5);
    %    clf;
        %plot_mesh(model.surfaceMesh.vertexPos,model.surfaceMesh.faces);
    %    axis equal;
        B = cam_.render.baryMap;
        fout = [dirIn '/views_undistorted/' ab '_BaryMap.mat'];
        save(fout,'B');   
    end
end


function I2 = doUndistort(I,fc,cc,kc,alpha_c,KK);
I = double(I);
for ii=1:size(I,3)
    %figure(1); imshow(I);
    I2(:,:,ii) = rect(I(:,:,ii),eye(3),fc,cc,kc,alpha_c,KK);
end