function G = graph_buildTableNode2x(G,property,returnCell)
%GRAPH_BUILDTABLENODE2X Summary of this function goes here
%   Detailed explanation goes here

switch property
    case 'edges'
        T = Node2Edges(G);
        if returnCell
            D = sparseMat2Cell(T,1);
        else
            D=T;
        end
        G.tables.nodes_2_edges = D;
end






function T = Node2Edges(G)
%returns a sparse table
%size = mxn, where m = number of nodes, n = number of edges
%0 = vertex is not connected to edge
%1 = vertex is first vertex for edge
%2 = vertex is second vertex for edge

if ~isfield(G,'E')
    error('Graph must have Edge structure built');

end
i1 = [G.E.edgeList(:,1)];
i2 = [G.E.IDs];
v1 = ones(length(i1),1)*1;

j1 = [G.E.edgeList(:,2)];
j2 = [G.E.IDs];
u1 = ones(length(i1),1)*2;

T = sparse([i1;j1],[i2;j2],[v1;u1],G.numNodes,G.E.numEdges);
