function [cost] = pricelist( varType )
% Return the implementaion cost of a variable type

cost = 0;

switch varType
    case 0
        cost = 0;
    case '1'
        cost = 1;
    case 'D'
        cost = 10;
    case 'X'
        cost = 10;
    case 'I'
        cost =1000;
    case 'T'
        cost = 1;
    otherwise
        s = sprintf('Unsupported variable type!!! %c',varType);
        disp(s);
        return;
end

end