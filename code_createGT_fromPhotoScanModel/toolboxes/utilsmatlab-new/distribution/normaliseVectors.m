function vecsn = normaliseVectors(vecs,dim)
%normaliseVectors - function to normalises a collection of vectors stored in matrix vecs along dimension
%specified by dim. The norm of vecsn along this dimension will be 1.
% Inputs:
%    vecs -  matrix of size n*d, where n is the number of vectors and d is the
%    dimension of the vectors.
%
%    dim -   dimension to normalise
%    
% Outputs:
% vecsn- normalised vectors
%
% Author: Toby Collins
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
if dim==1;
    vecs=vecs';
end
numDims =  size(vecs,2);
ll = distance_vec(vecs',zeros(numDims,1));
vecsn=vecs./repmat(ll,1,numDims);
if dim==1;
    vecsn=vecsn';
end
