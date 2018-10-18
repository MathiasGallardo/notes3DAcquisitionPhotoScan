function [V,F3,F4,VT,F3T,mtlFile,usemtl]=loadawobj(modelname)
%modified by collins

% loadobj
% Load an Wavefront/Alias obj style model. Will only consider polygons with 
% 3 or 4 vertices.
% Programme will also ignore normal and texture data. It will also ignore any
% part of the obj specification that is not a polygon mesh, ie nurbs, these
% deficiencies can probably be remedied relatively easily
%
% [v,f3,f4,f5,f6]=loadobj(modelname)
%
% W.S. Harwin, University Reading, 2006
% See also Anders Sandberg's vertface2obj.m and saveobjmesh.m

if nargin <1 
  disp('specify model name')  
end


fid = fopen(modelname,'r');
if (fid<0)error(['can not open file: ' modelname]);end

vnum=1;
f3num=1;
f4num=1;
vtnum=1;
vnnum=1;
gnum=1;

%preallocation:
V=zeros(3,50000);
VT=zeros(3,50000);
F3=zeros(3,50000);
F3T=zeros(3,50000);
F4=zeros(4,0);
mtlFile=[];
usemtl=[];
hasMTL = false;
% Line by line passing of the obj file
Lyn=fgets(fid);
while Lyn>=0
  s=sscanf(Lyn,'%s',1);
  l=length(Lyn);
  if l==0  % isempty(s) ; 
    disp(['empty' Lyn]);
  end
    switch s
    case '#' % comment
      disp(Lyn);
    case 'mtllib' % what is this??
      hasMTL=true;
      mtlFile=sscanf(Lyn(7:l),'%s');
    case 'usemtl' % what is this??
      usemtl=sscanf(Lyn(7:l),'%s');
    case 'v' % vertex
      v=sscanf(Lyn(2:l),'%f');
  
      V(:,vnum)=v;
     
      vnum=vnum+1;
    case 'vt'			% textures
      %if vtnum==1
        vt=sscanf(Lyn(3:l),'%f');      
        if length(vt)==2
           vt=[vt;0]; 
        end
        %disp(Lyn);
        VT(:,vtnum)=vt;
        vtnum=vtnum+1;
      %end
    case 'g' % mesh??
      disp(Lyn);
    case 'usemtl' % what is this??
        disp(Lyn);
    case 'vn' % normals
      if vnnum==1 
        disp(Lyn);
        vnnum=vnnum+1;
      end
    case 'f' % faces
      Lyn=deblank(Lyn(3:l));
      Lyn = strrep(Lyn,'//','/0/');
      nvrts=length(findstr(Lyn,' '))+1;
      fstr=findstr(Lyn,'/');
      nslash=length(fstr);
      if nvrts == 3
        if nslash ==3 % vertex and textures
          fLin=sscanf(Lyn,'%f/%f');
          f1=fLin([1 3 5]);
          f1T=fLin([2 4 6]);       
        elseif nslash==6 % vertex, textures and normals, 
          fLin=sscanf(Lyn,'%f/%f/%f');
          f1=fLin([1 4 7]);
          f1T=fLin([2 5 8]);    
           
        elseif nslash==0
          f1=sscanf(Lyn,'%f');
          f1T=[0;0;0];   
        else
          disp(['xyx' Lyn])
          f1=[];
        end
        F3(:,f3num)=f1;
        F3T(:,f3num)=f1T;
        f3num=f3num+1;
      elseif nvrts == 4
        if nslash == 4
          f1=sscanf(Lyn,'%f/%f');
          f1=f1([1 3 5 7]);
        elseif nslash == 8
          f1=sscanf(Lyn,'%f/%f/%f');
          f1=f1([1 4 7 10]);
        elseif nslash ==0
          f1=sscanf(Lyn,'%f');
        else
          disp(['xx' Lyn])
          f1=[];
        end
        F4(:,f4num)=f1;
        f4num=f4num+1;
      end 
     
    otherwise 
      if ~strcmp(Lyn,char([13 10]))
        disp(['unprocessed ' Lyn]);
      end
    end
  
  Lyn=fgets(fid);
end

fclose(fid);

V=V(:,1:vnum-1);
VT=VT(:,1:vtnum-1);
F3=F3(:,1:f3num-1);
F3T=F3T(:,1:f3num-1);



% plot if no output arguments are given
if nargout ==0
  if exist('F3','var') 
    patch('Vertices',V','Faces',F3','FaceColor','g');
  end
  if exist('F4','var')
    patch('Vertices',V','Faces',F4','FaceColor','b');
  end
  axis('equal')
  clear V F3 F4
end