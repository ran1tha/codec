function out  = addspatial(in,Bsize)

[h,w] = size(in);
dfd = double(in);
recon = zeros(h,w); recon(1:Bsize,1:Bsize) = dfd(1:Bsize,1:Bsize);
figure; imshow(uint8(dfd))
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
figure; imshow(uint8(recon)) 
out = recon;