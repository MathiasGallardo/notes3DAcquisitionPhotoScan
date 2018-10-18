function dirs=rdir(directory,extension)

dirs=dir([directory,extension]);
for i=1:length(dirs)
    dirs(i).name=[dirs(i).name];
end
