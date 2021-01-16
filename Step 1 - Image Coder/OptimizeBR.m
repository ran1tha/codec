function [vqm,bitrate,decoded] = OptimizeBR(mov,Q)

[h,w,channels,frames] = size(mov);  %Get height, width, channels and number of frames of video

%% Parameters 
Bsize = 8;                      %Block size
DClen = 0;                      %Lengths of DC parts
framelength = zeros(1,frames);  %Length of each coded frame
encoded = [];                   %Huffman encoded array
dictionary  = cell(1,frames);   %Dictionary cell array
pframes = 4;                    %Number of P frames after an I frame (Make praframes+1 a factor of frames)
M = 24;                         %Search Area for removing temporal redundancies

%%
%%
%%      E    N    C    O     D     E     R
%%
%%
%%

%% Remove Temporal Redundancies (Inter Coding)
numberofgops = frames/(pframes+1);            %Number of frame sets (Starting with an I frame and rest is P frames)
gop = zeros(h,w,pframes+1,numberofgops); %Initialize Frame Set
idx=1;

%Define each frame set
for i=1:(pframes+1):frames-pframes
        gop(:,:,1:1+pframes,idx) = mov(:,:,:,i:i+pframes);     
        idx=idx+1;
end

%Get the motion vector and the residual by removing temporal redundancies
temporalremoved = zeros(h,w,frames);
totpframes = numberofgops*pframes;  %Total number of P frames in the movie
totblocks = (h*w)/(Bsize)^2;        %Total number of blocks
X2vec = zeros(totpframes,totblocks);
Y2vec = zeros(totpframes,totblocks);
id = 1;

for j=1:numberofgops
    currentset = gop(:,:,:,j);
    temporalremoved(:,:,j*(pframes+1)-pframes) = currentset(:,:,1);
    for k = 1:pframes
        [X2,Y2,residual] = removetemporal(currentset(:,:,1),currentset(:,:,k+1),M,Bsize);
        temporalremoved(:,:,j*(pframes+1)-pframes+k) = residual;
        X2vec(id,:) = X2; Y2vec(id,:) = Y2;
        fprintf('Temporal Redundancies Removed %d/%d \n',id,pframes*numberofgops);   
        id =id+1;
    end
end


    
%% Huffman Encode frames
 
for i=1:frames
    [encoded,framelength(i),DClen,D] = huffcode(temporalremoved(:,:,i),encoded,Q,Bsize,i,frames);
    dictionary{i} = D;
end

%% Huffman Encode Motion Vectors
fprintf('Huffman Encoding Motion Vectors \n');
% Encode X2vec
X2enc = [];
for i=1:totpframes
    [X2enc,Xlength(i),Xd]= vec2huff(X2vec(i,:),X2enc);
    X2dic{i} = Xd;
end

% Encode Y2vec
Y2enc = [];
for i=1:totpframes
    [Y2enc,Ylength(i),Yd]= vec2huff(Y2vec(i,:),Y2enc);
    Y2dic{i} = Yd;
end

%%
%%
%%      D    E    C    O     D     E     R
%%
%%
%%
fromhuffman = encoded; X2dec = X2enc; Y2dec = Y2enc;
%% Huffman Decode frames

decoded = zeros(h,w,channels,frames);            %Decoded frames
idx = 0;

for j=1:length(framelength)
    framearray = fromhuffman(idx+1:idx+framelength(j));     %Get the array of the frame that needs to be decoded
    decoded(:,:,:,j) = huffdeco(framearray,DClen,dictionary{j},Q,Bsize,w,h,j,frames); %Decode the frame
    idx = idx+framelength(j);
end

%% Huffman Decode Motion Vectors

fprintf('Huffman Decoding Motion Vectors\n');
% Decode X2vec
X2vec = zeros(totpframes,totblocks);
id =0;
for i=1:totpframes
    startid = id+1;
    endid = id+Xlength(i);
    X2vec(i,:)= huff2vec(X2dec(startid:endid),X2dic{i});
    id = id+Xlength(i);
end

% Decode Y2vec
Y2vec = zeros(totpframes,totblocks);
id =0;
for i=1:totpframes
    startid = id+1;
    endid = id+Ylength(i);
    Y2vec(i,:)= huff2vec(Y2dec(startid:endid),Y2dic{i});
    id = id+Ylength(i);
end

%% Add Temporal Redundancies

numberofgops = frames/(pframes+1);              %Number of frame sets (Starting with an I frame and rest is P frames)
gop = zeros(h,w,pframes+1,numberofgops);   %Initialize Frame Set
idx=1;

%Define X1 and Y1 vectors
X1 = []; Y1 = [];
for i = 1:Bsize:h-Bsize+1
    for j = 1:Bsize:w-Bsize+1
        X1 = [X1,j]; Y1 = [Y1,i];
    end
end

%Define each frame set
for i=1:(pframes+1):frames-pframes
        gop(:,:,1:1+pframes,idx) = decoded(:,:,:,i:i+pframes);
        idx=idx+1;
end

%Get the reconstructed image by motion vector and residual
temporaladded = zeros(h,w,channels,frames);
id =1;
for j=1:numberofgops
    currentset = gop(:,:,:,j);
    temporaladded(:,:,:,j*(pframes+1)-pframes) = currentset(:,:,1);
    for k = 1:pframes
        index = (j-1)*pframes+k;
        X2 = X2vec(index,:); Y2 = Y2vec(index,:);
        reconstructed = addtemporal(currentset(:,:,1),currentset(:,:,k+1),Bsize,X1,Y1,X2,Y2,h,w);
        temporaladded(:,:,:,j*(pframes+1)-pframes+k) = reconstructed;
        fprintf('Temporal Redundancies Added %d/%d \n',id,pframes*numberofgops);
        id=id+1;
    end
end

decoded = uint8(temporaladded);           %Convert to integer

%% Calculating VQM (Video Quality Measurement) for Analysing the optimum bitrate

vqmsum = 0;

%Calculate VQM for all the frames
for i=1:frames
    
    peaksnr = psnr(decoded(:,:,i),mov(:,:,i));
    denom = exp(0.17*(peaksnr-25.66));
    vqmf = 1/(1+denom);
    vqmsum = vqmsum+vqmf;
    
end

%Average the VQM over all the frames to give a single quality metric per
%decoded video

vqm = vqmsum/frames;

%% Calculating the Bitrate

bitrate = (length(encoded)+length(X2enc)+length(Y2enc)+length(Xlength)+length(Ylength)+length(framelength));
bitrate = bitrate/1000000;

fprintf('Bitrate at %.3f Quantization level: %.3f Mbps \n',Q,bitrate);
fprintf('VQM: %.3f \n',vqm);
