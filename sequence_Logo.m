clc
clear
%display a sequence logo for a set of aligned nucleotide sequences.
startPos = 1;
endPos = 1;
nSymbols = 4;
aaSymbols = 'ARNDCQEGHILKMFPSTWYV';
ntSymbols = 'ACGT';
symbolList = char(ntSymbols(:));
P = {'ATTATAGCAAACTA',...
     'AACATGCCAAAGTA',...
     'ATCATGCAAAAGGA'}
 %seqlogo(S)
P = P(:);
P = strrep(P,' ','-'); % padding spaces are not considered 'align' chars
P = char(P); % now seqs must be a char array
seqs = upper(P);
[numSeq, nPos] = size(seqs); 
  uniqueList = unique(seqs);
m = length(uniqueList);
    pcM = zeros(m, nPos);
    for i = 1:nPos
        for j = 1:m
            pcM(j,i) = sum(seqs(:,i) == uniqueList(j));
        end
    end
    % Compute the weight matrix used for graphically displaying the logo
    % Not considering wild card or gap YET, only for real symbols
    freqM = [];
    [symbolList, tmpIdx] = regexpi(uniqueList', '[A-Z]', 'match');
    symbolList = char(symbolList');

    if ~isempty(tmpIdx)
        for i = 1:length(tmpIdx)
            freqM(i, :) = pcM(tmpIdx(i),:); %#ok
        end
    end

    % The observed frequency of a symbol at a particular sequence position
    freqM = freqM/numSeq;
%maxLen - the max sequence length in the set
maxLen = size(freqM, 2);

if endPos == 1
    endPos = maxLen;
end
freqM = freqM(:, startPos:endPos);
wtM = freqM; 
S_before = log2(nSymbols);
freqM(freqM == 0) = 1; % log2(1) = 0

% The uncertainty after the input at each position
S_after = -sum(log2(freqM).*freqM, 1);
R = S_before - S_after;
nPos = (endPos - startPos) + 1;
for i =1:nPos
    wtM(:, i) = wtM(:, i) * R(i);
end

if nargout >= 1
     % Create the seqLogo cell array
    W = cell(1,2);
    W(1,1) = {symbolList};
    W(1,2) = {wtM};
end

     [wtM, symbolList] = sortWeightOrder(wtM, symbolList);


% Display logo
hfig = [];


    
        hfig = seqshowlogo(wtM, symbolList, true, startPos);
        
        
   

