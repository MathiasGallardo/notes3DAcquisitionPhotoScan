function succes=writeCameraxml(ImageSize,CalibFile,OutputFile)
load(CalibFile);
fid = fopen(OutputFile,'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<calibration>\n');
fprintf(fid,'<width>%d</width>\n',ImageSize(2));
fprintf(fid,'<height>%d</height>\n',ImageSize(1));
fprintf(fid,'<fx>%f</fx>\n',KK(1,1));
fprintf(fid,'<fy>%f</fy>\n',KK(2,2));
fprintf(fid,'<cx>%f</cx>\n',KK(1,3));
fprintf(fid,'<cy>%f</cy>\n',KK(2,3));
fprintf(fid,'<skew>%f</skew>\n',KK(1,2));
fprintf(fid,'<k1>%f</k1>\n',kc(1));
fprintf(fid,'<k2>%f</k2>\n',kc(2));
fprintf(fid,'<k3>%f</k3>\n',kc(3));
fprintf(fid,'<p1>%f</p1>\n',kc(4));
fprintf(fid,'<p2>%f</p2>\n',kc(5));
fprintf(fid,'<date>%s</date>\n',date);
fprintf(fid,'</calibration>\n');
fclose(fid);
end
