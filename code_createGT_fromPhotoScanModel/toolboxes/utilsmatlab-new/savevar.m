% Save data in raw format
function savevar(var,pathfile)
fd=fopen(pathfile,'w');
if(fd==-1)
    disp('[ERROR] Cannot create file')
end
count=fwrite(fd,size(var),'integer*4');
if(count<2)
    disp('[ERROR] Cannot write var size to file')
end
count=fwrite(fd,var','float');
if(count<length(var(:)))
    disp('[ERROR] Cannot write all variable elements to file')
end
fclose(fd);