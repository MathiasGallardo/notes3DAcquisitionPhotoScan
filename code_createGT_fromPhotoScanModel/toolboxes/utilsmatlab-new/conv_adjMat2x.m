function dout = conv_adjMat2x(A,numNodes,typeOut,opts)
%conv_adjMat2x - function which converts an adjacency matrix according to
%typeOut
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

switch typeOut
    case 'Edges_undirected'
        [e1,e2] = find(A);
        if (sum(sum(A-A'))~=0)
            error('Adjacency matrix must be undirected');
        end
            E = sort([e1,e2],2);           
            A = sparse(E(:,1),E(:,2),ones(length(e1),1),numNodes,numNodes);
            [e1,e2] = find(A);
            clear A;
            if nargin<4
                E = buildEdgeStruct(e1,e2,'undirected');
            else
                E = buildEdgeStruct(e1,e2,'undirected',opts);
            end

            
            dout = E;
    case 'Edges_directed'
        [e1,e2] = find(A);
        E = buildEdgeStruct(e1,e2,'directed');
        dout = Edges;

end


