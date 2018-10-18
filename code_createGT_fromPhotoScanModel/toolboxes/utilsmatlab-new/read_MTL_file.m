function mtlData = read_MTL_file(fin)
%read_MTL_file - function to read a mtl file (from the obj 3d file format.)
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

fid=fopen(fin);
mtlData = struct;
numMaterials = 0;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    disp(tline);
    [T,R] = strtok(tline);
    switch T
        case '#'
            continue
            
         case 'newmtl'
             numMaterials=numMaterials+1;
             if numMaterials==1
                 
             else
                 mtlData(numMaterials-1).mtl = mtl;
             end
             mtl=struct;
           [T,R] = strtok(R);
           mtl.newmtl=T;
         case 'Ns'
             
         case 'map_Ka'
            % [T,R] = STRTOK(R);
             mtl.map_Ka=R(2:end);
             if strcmp(mtl.map_Ka(1:2),'.\')
                 [aa,ab,ac] = fileparts(fin);
                 mtl.map_Ka = [aa '\' mtl.map_Ka(3:end)];
                 
             end
        case 'map_Kd'
            % [T,R] = STRTOK(R);
             mtl.map_Ka=R(2:end);
             if strcmp(mtl.map_Ka(1:2),'.\')
                 [aa,ab,ac] = fileparts(fin);
                 mtl.map_Ka = [aa '\' mtl.map_Ka(3:end)];
                 
             end
        otherwise
        
    end
        
end
mtlData(numMaterials).mtl = mtl;
 
fclose(fid);


% 
% 	Ns 10.0000
% 	Ni 1.5000
% 	d 1.0000
% 	Tr 1.0000
% 	Tf 1.0000 1.0000 1.0000 
% 	illum 2
% 	Ka 0.0000 0.0000 0.0000
% 	Kd 0.5882 0.5882 0.5882
% 	Ks 0.0000 0.0000 0.0000
% 	Ke 0.0000 0.0000 0.0000
% 	map_Ka E:\Documents and Settings\s0455374\My Documents\My Pictures\happy_birthday_cupcake.jpg
% 	map_Kd E:\Documents and Settings\s0455374\My Documents\My Pictures\happy_birthday_cupcake.jpg