function E = buildEdgeStruct(e1,e2,type,opts)
%buildEdgeStruct - function which builds a structure holding a graph's edge
%data
% Author: Toby Collins
% Work address
% email: toby.collins@gmail.com
% Website: http://isit.u-clermont1.fr/content/Toby-Collins
% Jan 2008

if nargin<4
   opts=struct; 
   opts.withIDs = true;
   opts.withDecoder = true;
end

E.type=type;
if isempty(e1)
    E.edgeList=zeros(0,2);
    E.IDs=[];
    E.numEdges=0;
    E.Decoder=[];
    return;
end
switch type
    case 'directed'
        E.edgeList = [e1,e2];
    case 'undirected'
        es = sort([e1,e2],2);
        A = sparse(es(:,1),es(:,2),ones(length(e1),1),max(es(:)),max(es(:)));
        [e1,e2]=find(A);
        E.edgeList =[e1,e2];
        clear A;
end
E.numEdges = size(E.edgeList,1);
if opts.withIDs 
E.IDs = ([1:size(E.edgeList,1)])';
end


%decoder:
if opts.withDecoder 
i1 = E.edgeList(:,1);
i2 = E.edgeList(:,2);

vals=E.IDs;

switch type
    case 'directed'
        Decoder = sparse(i1,i2,vals,max(es(:)),max(es(:)));
    case 'undirected'
        Decoder = sparse([i1;i2],[i2;i1],[vals;vals],max(es(:)),max(es(:)));
end
E.Decoder=Decoder;
end





