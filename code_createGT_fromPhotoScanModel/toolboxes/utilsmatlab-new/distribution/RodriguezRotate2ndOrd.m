function R = RodriguezRotate2ndOrd(vs,returnCells)
%magnitued of vs is the rotation angle
%this function returns a rotation matrix R equivalent to the rotation
%vectors specified in vs.
%this size of vs is nx3 where n is the number of rotation vectors.
%returnCells is a flag which if returnCells=1, then R will be a cell
%array. If returnCells=0, then R will be a 3D matrix of 3x3xn

%Toby Collins 2006
vs=vs+eps;
v1=vs(:,1);
v2=vs(:,2);
v3=vs(:,3);
if nargin<2
    returnCells=true;
end
numVecs = size(v1,1);

% if norm(vin)<eps
%    R = eye(3);
%    return;
% end

t1 = v1 .^ 2;
t2 = v2 .^ 2;
t3 = v3 .^ 2;
t4 = t1 + t2 + t3;
t5 = sqrt(t4);
t6 = cos(t5);
t7 = 0.1e1 - t6;
t8 = 0.1e1 ./ t4;
t9 = t3 .* t8;
t10 = t2 .* t8;
t14 = sin(t5);
t16 = 0.1e1 ./ t5;
t17 = t14 .* v3 .* t16;
t19 = t8 .* v1;
t20 = t7 .* v2 .* t19;
t23 = t14 .* v2 .* t16;
t24 = t7 .* v3;
t25 = t24 .* t19;
t28 = t1 .* t8;
t33 = t14 .* v1 .* t16;
t35 = t24 .* t8 .* v2;
cg1_1_1 = 0.1e1 + t7 .* (-t9 - t10);
cg1_1_2 = -t17 + t20;
cg1_1_3 = t23 + t25;
cg1_2_1 = t17 + t20;
cg1_2_2 = 0.1e1 + t7 .* (-t9 - t28);
cg1_2_3 = -t33 + t35;
cg1_3_1 = -t23 + t25;
cg1_3_2 = t33 + t35;
cg1_3_3 = 0.1e1 + t7 .* (-t10 - t28);

R=zeros(numVecs*3,3);

i1 = 1:3:3*numVecs;
R(i1,1)=cg1_1_1;
R(i1,2)=cg1_1_2;
R(i1,3)=cg1_1_3;

i1 = 2:3:3*numVecs;
R(i1,1)=cg1_2_1;
R(i1,2)=cg1_2_2;
R(i1,3)=cg1_2_3;

i1 = 3:3:3*numVecs;
R(i1,1)=cg1_3_1;
R(i1,2)=cg1_3_2;
R(i1,3)=cg1_3_3;

if numVecs>1&returnCells
   R=mat2cell(R,repmat(3,1,numVecs),3);
   return;
end

R = zeros(3,3,numVecs);
R(1,1,:)=cg1_1_1;
R(1,2,:)=cg1_1_2;
R(1,3,:)=cg1_1_3;
R(2,1,:)=cg1_2_1;
R(2,2,:)=cg1_2_2;
R(2,3,:)=cg1_2_3;
R(3,1,:)=cg1_3_1;
R(3,2,:)=cg1_3_2;
R(3,3,:)=cg1_3_3;









