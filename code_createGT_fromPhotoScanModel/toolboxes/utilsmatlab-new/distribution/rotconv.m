function [rm_R] = rotconv(pv_rot)

%pv_rot = pv_rot/norm(pv_rot); % Check unit vector!

rm_R = zeros(3);

% Quaternion representation first...

w = cos(pv_rot(4)/2.0);
x = pv_rot(1) * sin(pv_rot(4)/2.0);
y = pv_rot(2) * sin(pv_rot(4)/2.0);
z = pv_rot(3) * sin(pv_rot(4)/2.0);

n = sqrt(x*x + y*y + z*z + w*w);
x = x/n;
y = y/n;
z = z/n;
w = w/n;

% Convert to matrix form...

rm_R(1,1) = 1-2*(y*y + z*z);
rm_R(1,2) = 2*(x*y - z*w);
rm_R(1,3) = 2*(x*z + y*w);
rm_R(2,1) = 2*(x*y + z*w);
rm_R(2,2) = 1-2*(x*x + z*z);
rm_R(2,3) = 2*(y*z - x*w);
rm_R(3,1) = 2*(x*z - y*w);
rm_R(3,2) = 2*(y*z + x*w);
rm_R(3,3) = 1-2*(x*x + y*y);

%rm_R(1,1) = w^2 + x^2 - y^2 - z^2;
%rm_R(1,2) = 2*x*y + 2*w*z;
%rm_R(1,3) = 2*x*z - 2*w*y;
%rm_R(2,1) = 2*x*y - 2*w*z;
%rm_R(2,2) = w^2 - x^2 - y^2 - z^2;
%rm_R(2,3) = 2*y*z + 2*w*x;
%rm_R(3,1) = 2*x*z + 2*w*y;
%rm_R(3,2) = 2*y*z - 2*w*x;
%rm_R(3,3) = w^2 + x^2 + y^2 + z^2;

