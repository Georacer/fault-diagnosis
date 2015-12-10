function LineGraph = GraphConvertToLineGraph(Graph)
%{
Graph = GraphLoad('c:\Users\LevMuchnik\Documents\MFiles\Complexity\Graph\News2ru_2010_02_22_a\Data\Graph.asc');
LineGraph = GraphConvertToLineGraph(Graph)
%}
%% Sort Graph links by source, dest
[~, SO] = sort(Graph.Data(:,1)*(max(max(Graph.Data(:,1:2)))+1)  + Graph.Data(:,2),'ascend');
Links = Graph.Data(SO,1:2); 
clear SO;
[Degree x] = hist(Links(:,1),1 : max(Links(:)));
SourceIndex= [0 cumsum(Degree)];
i=17;
Links(SourceIndex(i)+1 : SourceIndex(i+1),:)
ResultLinks = zeros(size(Links,1),2,'uint32');
CurrentLinksIndex = 1;
NonZeroIndesex = find(Degree~=0);
for SourceLinkIndexes = 1 : numel(NonZeroIndesex)
     SourceNodeID = x(NonZeroIndesex(SourceLinkIndexes));
     FromIndex = SourceIndex(NonZeroIndesex(SourceLinkIndexes))+1 ;
     ToIndex = SourceIndex(NonZeroIndesex(SourceLinkIndexes)+1);
     DestNodeIDs = Links(FromIndex: ToIndex,2);
     SourceNodeLinks = SourceIndex(SourceNodeID)+1 : SourceIndex(SourceNodeID+1);
     for i = 1 : numel(DestNodeIDs)
        LinkID = (SourceIndex(NonZeroIndesex(SourceLinkIndexes))+i);
        Links1 = [ ones( Degree(SourceNodeID),1)*LinkID SourceNodeLinks(:)];
        Links2 = [ LinkID*ones(Degree(DestNodeIDs(i)),1) [SourceIndex(DestNodeIDs(i))+1: SourceIndex(DestNodeIDs(i)+1)].' ];
        Links1 (Links1(:,1)==Links1(:,2),:) = [];
        Links2 (Links2(:,1)==Links2(:,2),:) = [];
        
        if size(Links1,1)+size(Links2,1)+CurrentLinksIndex-1>size(ResultLinks,1)
            NewResultLinks = zeros(size(ResultLinks,1)+max(size(Links1,1)+size(Links2,1),size(ResultLinks,1)) ,2,'uint32');
            NewResultLinks(1:CurrentLinksIndex-1,:)= ResultLinks(1:CurrentLinksIndex-1,:);
            ResultLinks = NewResultLinks; clear NewResultLinks;
        end
        ResultLinks(CurrentLinksIndex:CurrentLinksIndex+ size(Links1,1)-1,:) = uint32(Links1);
        ResultLinks(CurrentLinksIndex+ size(Links1,1):CurrentLinksIndex+ size(Links1,1)++ size(Links2,1)-1,:) = uint32(Links2);
        CurrentLinksIndex = CurrentLinksIndex+ size(Links1,1)++ size(Links2,1);
%         if any(Links(Links2(:,2),1)~=DestNodeIDs(i)), error('sdsad'); end
     end
%     if any(nnz(Links(Links(:,1)==SourceNodeID,2)~=DestNodeIDs)), error('sdasdasd'); end   
%     CurrentlinkID = CurrentlinkID+1;
end
LineGraph = ObjectCreateGraph([],mfilename);
LineGraph.Data = ResultLinks;