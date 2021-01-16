function [out,framelength,DClen,d] = huffcode(X,enco,Q,blocksize,num,frames)

DC = [];                     %DC array
AC = [];                     %AC array
Bsize = blocksize;           %Block Size
Mat = dctmtx(Bsize);         %DCT matrix of size Bsize

    Qmat = [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];    %Standard JPEG matrix

%% Encode

%% Forward Transformation and Quantization

pic = X;         %Read Image
[h,w] = size(pic);               %Get width and height of pic
pic = double(pic);          %Convert Image to double precision (For Matrix Mul.)

pic = pic-128;              %Shift values by 128 to make a center zero matrix

fprintf('Forward Transforming %d/%d \n',num,frames);

C = cell(h/Bsize,w/Bsize);          %Define cell array
for i=1:h/Bsize
    for j=1:w/Bsize
        temp = pic(Bsize*(i-1)+1:Bsize*(i),Bsize*(j-1)+1:Bsize*(j)); %Get Bsize x Bsize block from pic
        C{i,j} = temp;
        C{i,j} = Mat*C{i,j}*Mat';                                    %Forward DCT transform
        C{i,j} = C{i,j}./(Qmat*Q);                                   %Quantization
        C{i,j} = round(C{i,j});                                       %Round Up
        C{i,j} = zigzag(C{i,j});                                     %Get zigzag (Now its an array)
        temp   = C{i,j};                                             
        DC = [DC temp(1)];                                           %Get first element into DC   
        AC = [AC temp(2:end)];                                       %Get rest of the elements into AC
    end
end

RunLengthCoded = RunLengthEnco(AC);     %Runlength code the AC array
tohuffman = [DC RunLengthCoded];        %Pass DC and AC into huffman coding algorithm


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

fprintf('Huffman Encoding %d/%d \n',num,frames);
encoded = huffmanenco(tohuffman(:),dict); 
encoded = encoded';

%% Create bit string of the frame

out = [enco encoded];                        %Encoded string
DClen = length(DC);                          %Store DC array length 
framelength = length(encoded);               %Store frame length
d = dict;

