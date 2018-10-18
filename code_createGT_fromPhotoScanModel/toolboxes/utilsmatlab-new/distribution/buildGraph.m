function G = buildGraph(din,numNodes,dtype)
%BUILD3DMESH - function which builds a graph structure from din
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008
switch lower(dtype)
    case 'faces'
        G.F = din;
        G.A = conv_faces2x(G.F,numNodes,'AdjMat');
        G.E = conv_faces2x(G.F,numNodes,'Edges');
    case 'adjmat'
        G.A = din;
        G.E = conv_adjMat2x(G.A,numNodes,'Edges_directed');
    case 'edgelist'    
    
end
G.numNodes =numNodes;