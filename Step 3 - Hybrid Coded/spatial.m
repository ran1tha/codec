clc; clear all; close all;

pic = imread('pic.bmp');
ori = pic;

[h,w] = size(pic);
Bsize = 8;
dfd = zeros(h,w); dfd(1:8,1:8)=ori(1:8,1:8);
ori = double(ori);

for i=1:Bsize:h
    for j=1:Bsize:w-Bsize
           previous = ori(i:i+Bsize-1,j:j+Bsize-1);
           next = ori(i:i+Bsize-1,j+Bsize:j+2*Bsize-1);
           dfd(i:i+Bsize-1,j+Bsize:j+2*Bsize-1) = next-previous;
           if j==w-2*Bsize+1 && i~=h-Bsize+1
               previous = ori(i:i+Bsize-1,j+Bsize:j+2*Bsize-1);
               next = ori(i+Bsize:i+2*Bsize-1,1:8);
               dfd(i+Bsize:i+2*Bsize-1,1:8) = next-previous;
           end
    end
end

figure; subplot(1,2,2); imshow(uint8(dfd)); title('Residual Image')
recon = zeros(h,w); recon(1:Bsize,1:Bsize) = dfd(1:Bsize,1:Bsize);

for i=1:Bsize:h
    for j=1:Bsize:w-Bsize
           previous = recon(i:i+Bsize-1,j:j+Bsize-1);
           next = dfd(i:i+Bsize-1,j+Bsize:j+2*Bsize-1);
           recon(i:i+Bsize-1,j+Bsize:j+2*Bsize-1) = next+previous;
           if j==w-2*Bsize+1 && i~=h-Bsize+1
               previous = recon(i:i+Bsize-1,j+Bsize:j+2*Bsize-1);
               next = dfd(i+Bsize:i+2*Bsize-1,1:8);
               recon(i+Bsize:i+2*Bsize-1,1:8) = next+previous;
           end
    end
end

subplot(1,2,1); imshow(uint8(recon)); title('Original Image')
       
