function pIntersect = line_plane_intersect3d_batch(p0,p1,p_plane,n_plane)
%line_plane_intersect3d_batch - function to compute the intersection
%between lines and planes (3D)
% Inputs:
%    p0, p1 - lines are defined by two endpoints. p0 and p1. These are
%    matrices of size n*3, where n is the number of lines.
%    planes are defined by a point lying on the plane (p_plane of size n*3) and their
%    normals (n_plane of size n*3)
%    
% Outputs:
% pIntersect- list of intersection points (size n*3)
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
%http://www.softsurfer.com/Archive/algorithm_0104/algorithm_0104B.htm


a = n_plane(:,1);
b = n_plane(:,2);
c = n_plane(:,3);

d = -(p_plane(:,1).*a+p_plane(:,2).*b+p_plane(:,3).*c);
u = p1-p0;
dts = u(:,1).*n_plane(:,1)+u(:,2).*n_plane(:,2)+u(:,3).*n_plane(:,3);

s = -(p0(:,1).*a+p0(:,2).*b+p0(:,3).*c+d)./dts;

pIntersect = p0+[s,s,s].*u;


