function bitrate = OptimizeQ(mov,Q)

[h,w,channels,frames] = size(mov);  %Get height, width, channels and number of frames of video

%% Setting Up Quantization Optimization


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

bitrate = (length(encoded)+length(X2enc)+length(Y2enc)+length(Xlength)+length(Ylength)+length(framelength));
bitrate = bitrate/1000000;
fprintf('Bitrate at %.5f Quantization level: %.3f Mbps \n',Q,bitrate);
