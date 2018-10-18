function Dout = conv_faces2x(F,numNodes,typeOut)
%conv_adjMat2x - function which converts a face list to another data
%structure according to typeOut
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
switch lower(typeOut)
    case 'adjmat'
        %returns a symmetric adjacency matrix.
        edg = [F(:,1),F(:,2);F(:,1),F(:,3);F(:,2),F(:,3)];
        A=sparse(edg(:,1),edg(:,2),ones(size(edg,1),1),numNodes,numNodes);
        A=A|A';
        Dout = double(A);
    case 'edges'
         A = conv_faces2x(F,numNodes,'AdjMat');
         E = conv_adjMat2x(A ,numNodes,'Edges_undirected');
         Dout = E;                  
end