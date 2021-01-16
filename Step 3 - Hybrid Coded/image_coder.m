%% Initialize
%% Add data being written and read from text file
clc; clear all; close all;

%% Read Image 
pic = imread('pic.bmp');         %Read Image

%% Input Quantization Level [High Q => Low Quality]
Q = 0.2;                     %Quantization Level 


%% Define Variables
DC = [];                     %DC array
AC = [];                     %AC array
Bsize = 8;                   %Block Size
Mat = dctmtx(Bsize);         %DCT matrix of size Bsize

    Qmat = [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];    %Standard JPEG matrix

%% 
%%
%%  E       N       C       O       D       E       R
%%
%%

%% Forward Transformation and Quantization

[h,w] = size(pic);               %Get width and height of pic

show = pic;                 %Copy image to display
pic = double(pic);          %Convert Image to double precision (For Matrix Mul.)

figure;
imshow(show);               %Show Original

pic = pic-128;              %Shift values by 128 to make a center zero matrix

fprintf('Forward Transforming \n');

C = cell(h/Bsize,w/Bsize);          %Define cell array
for i=1:h/Bsize
    for j=1:w/Bsize
        temp = pic(Bsize*(i-1)+1:Bsize*(i),Bsize*(j-1)+1:Bsize*(j)); %Get Bsize x Bsize block from pic
        C{i,j} = temp;
        C{i,j} = Mat*C{i,j}*Mat';                                    %Forward DCT transform
        C{i,j} = C{i,j}./(Qmat*Q);                                   %Quantization
        C{i,j} = ceil(C{i,j});                                       %Round Up
        C{i,j} = zigzag(C{i,j});                                     %Get zigzag (Now its an array)
        temp   = C{i,j};                                             
        DC = [DC temp(1)];                                           %Get first element into DC   
        AC = [AC temp(2:end)];                                       %Get rest of the elements into AC
    end
end



dclen = length(DC);                     %Store DC array length !!!PASS THIS INTO MAIN!!!
RunLengthCoded = RunLengthEnco(AC);     %Runlength code the AC array
tohuffman = [DC RunLengthCoded];        %Pass DC and AC into huffman coding algorithm


% Find frequencies
[G,GN,symbol] = grp2idx(tohuffman(:));      %Group the same-kind elements
frequency = accumarray(G,1);                %Create an array by accumulation - step by 1
probability = frequency./(length(G));       %Calculate the probability of each intensity level
T = table(symbol,frequency,probability);    %Table the values
T(1:length(symbol),:);


%plot probability distributions
figure; bar(symbol,probability); title('Probability distribution for symbols'); 
xlabel('Symbol'); ylabel('Probability'); grid on; xlim([-200 200]);

%% Huffman Code Dictionary Generation

%For Grayscale
table = [double(symbol),double(probability)]; %store probability and symbol values in one table
table = sortrows(table,2,'ascend'); %sort the rows in ascending order of probability (for easiness)
symbol_g = table(:,1); prob_i = table(:,2); %separate symbols and probabilities after sorting
r_matrix = zeros(length(table)-1,1); %initiate rearrangement matrix

for i = 1:length(table)-2              %repeat until 2 values are remaining
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
for i = 1:length(table)-2
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

fprintf('Huffman Encoding \n');
encoded = huffmanenco(tohuffman(:),dict); 
encoded = encoded';

%% Write Encoded Image to Text file

text = 'coded_image.txt'; fid = fopen(text,'w'); 
fprintf(fid,num2str(encoded)); fclose(fid);    %write Video data to text file
fprintf('Image Data written to text file succesfully! \n');

%%
%%
%%      D       E       C       O       D       E       R
%%
%%

%% Read Image Data from Text files

fid=fopen('coded_image.txt'); textformat='%f'; fromhuffman = fscanf(fid,textformat); fclose(fid);
fromhuffman = fromhuffman';                     %read vid data from text file
fprintf('Image Data read from text file succesfully! \n');

fprintf('Huffman Decoding \n');
fromhuffman = huffmandeco(fromhuffman,dict);        %Decode from huffman

DC_d = fromhuffman(1:dclen);                    %DC array
AC_d = fromhuffman(dclen+1:end);                %AC array
AC_d = RunLengthDeco(AC_d);                     %Runlength Decode the AC array

fprintf('Inverse Transforming \n');

D = cell(h/Bsize,w/Bsize);                      %Initialize cell array
idx =1;
for i=1:h/Bsize
    for j=1:w/Bsize
        temp = [DC_d(idx) AC_d(((Bsize^2)-1)*(idx-1)+1:((Bsize^2)-1)*idx)]; %Get DC and AC parts of block
        D{i,j} = reshape(temp,Bsize,Bsize);                                 %Reshape the array into block
        D{i,j} = izigzag(D{i,j},Bsize,Bsize);                               %Inverse zigzag the DC and AC array
        D{i,j} = D{i,j}.*(Qmat*Q);                                          %Inverse quantize the block
        D{i,j} = Mat'*D{i,j}*Mat;                                           %Inverse DCT transform the block
        idx=idx+1;
    end
end

decoded = cell2mat(D);          %Transform cell array into matrix
decoded = decoded+128;          %Add 128 to reverse previous operation
figure;
imshow(uint8(decoded));         %Show decoded figure

filtered = filter2(fspecial('average',4),decoded);      %Image after applying average filter
figure;                                                 %4 was selected after examining the psnr
imshow(uint8(filtered));                                %Reconstructed Image
