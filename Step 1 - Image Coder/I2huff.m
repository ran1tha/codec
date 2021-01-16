function [out,Ilen,D] = I2huff(in,encoded_Iframes)

tohuffman = in(:);        %Pass DC and AC into huffman coding algorithm


% Find frequencies
[G,GN,symbol] = grp2idx(tohuffman(:));      %Group the same-kind elements
frequency = accumarray(G,1);                %Create an array by accumulation - step by 1
probability = frequency./(length(G));       %Calculate the probability of each intensity level


% %plot probability distributions !!DELETE LATER!!!
% figure; bar(symbol,probability); title('Probability distribution for symbols'); 
% xlabel('Symbol'); ylabel('Probability'); grid on;

%% Huffman Code Dictionary Generation

table_d = [double(symbol),double(probability)]; %store probability and symbol values in one table
table_d = sortrows(table_d,2,'ascend'); %sort the rows in ascending order of probability (for easiness)
symbol_g = table_d(:,1); prob_i = table_d(:,2); %separate symbols and probabilities after sorting
r_matrix = zeros(length(table_d)-1,1); %initiate rearrangement matrix

for i = 1:length(table_d)-2              %repeat until 2 values are remaining
    first_two = prob_i(1)+prob_i(2);     %add the first two probabilities
    prob_i = [first_two;prob_i(3:end)];  %rearrange the probabilities
    [prob_i,idx_i] = sortrows(prob_i);   %sort and save the index after rearranging
    
    idx_i_d = idx_i;        %copy the index into a dummy variable
    
        for j=1:length(symbol)-i         %find the positions that index varies
            pos = find(idx_i==j);
            idx_i_d(j)=pos(1,1);
        end
        
    idx_i_d = [idx_i_d;zeros(i-1,1)];        %apply padding for idx_i
    r_matrix = [r_matrix, idx_i_d];        %build r_matrix
end

r_matrix = fliplr(r_matrix);  %Flip rearrangement matrix horizontally
r_matrix = r_matrix(:,1:length(r_matrix)-1); %delete last column

code = cell(1,2);  %Initiate cell array to store code words
code{1} = [1]; code{2} = [0]; %initiate the first two code words
dummy = cell(1); %initiate dummy cell

%Create Code Words
for i = 1:length(table_d)-2
   mul_idx = r_matrix(1:i+1,i); %select index for multiplication
   mul_idx = mul_idx';
   code = code(mul_idx); %rearrange code words
   
   for j = i+2:-1:3
    code{j} = code{j-1}; %shift the code words by 1 position except for the first two
   end
   
   dummy{1} = code{1};
   code{1} = [dummy{1},1]; %Add 1 after the code word in postition 1
   code{2} = [dummy{1},0]; %Add 0 after the code word in postition 2
   
   
end

%% Encode the using generated dictionary

dict = [num2cell(symbol_g), code']; %create dictionary using symbols and code words

encoded = huffmanenco(tohuffman(:),dict); 
encoded = encoded';

%% Create bit string of the frame

D = dict;
Ilen = length(encoded);
out = [encoded_Iframes encoded];
end