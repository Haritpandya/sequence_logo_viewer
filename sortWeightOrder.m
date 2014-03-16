function [p,s] = sortWeightOrder(weight, symbollist)
% Sort weight matrix by the sort of symbol list in ASCII direction order
% Here only needed for AA
[s, index] = sort(symbollist);
p=weight;
for i = 1:size(weight, 2)
    x=weight(:,i);
    p(:,i) = x(index);
end
end %sortWeightOrder

