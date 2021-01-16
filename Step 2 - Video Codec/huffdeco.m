function  out = huffdeco(framearray,DClen,dict,Q,Bsize,w,h,num,frames);

Mat = dctmtx(Bsize);         %DCT matrix of size Bsize

    Qmat = [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];    %Standard JPEG matrix
%% Decode from huffman

fprintf('Huffman Decoding %d/%d\n',num,frames);
fromhuffman = huffmandeco(framearray,dict);     %Decode from huffman

DC_d = fromhuffman(1:DClen);                    %DC array
AC_d = fromhuffman(DClen+1:end);                %AC array
AC_d = RunLengthDeco(AC_d);                     %Runlength Decode the AC array

fprintf('Inverse Transforming %d/%d \n',num,frames);

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

% figure; imshow(uint8(decoded)); %Show decoded BLOCKY image

filtered = filter2(fspecial('average',4),decoded);       %Image after applying average filter
                                                     %4 was selected after examining the psnr
                                                         
% figure; imshow(uint8(filtered)); %Show filtered image                                                         

out = filtered;
