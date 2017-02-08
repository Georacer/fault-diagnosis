% Run "testrun.m" first

dm = GetDMParts(temp);
% X = temp.X;
% if length(dm.Mp.row)>0
%     Xp = X(dm.Mp.row,dm.Mp.col);
%     P = PSODecomposition(temp);
% 
%     prowstart = length(dm.rowp)-length(P.p)+1;
%     rowp = dm.Mp.row;
%     rowp = rowp(P.p);
%     dm.rowp(prowstart:end) = rowp;
% 
%     pcolstart = length(dm.colp)-length(P.q)+1;
%     colp = dm.Mp.col;
%     colp = colp(P.q);
%     dm.colp(pcolstart:end) = colp;
% end

plotVec = 1:length(dm.Mp.col);
table = temp.X(dm.Mp.row(plotVec),dm.Mp.col);
figure();
% spy(table);
pause on;
pause;

while true
    tempsum = sum(table,2);
    rowIndex = find(tempsum==1,1,'first');
    colIndex = find(table(rowIndex,:));

    if ~isempty(rowIndex)
        spy(table);
        hold on
        plot([1 size(table,2)],[rowIndex rowIndex],'r');
        plot([colIndex colIndex],[1 size(table,2)],'r');
        hold off
        table = table([1:rowIndex-1 rowIndex+1:end],[1:colIndex-1 colIndex+1:end]);
%         disp('Pausing');
        pause(0.3);     
    else
        break;
    end
end