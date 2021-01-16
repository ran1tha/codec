function out = removespatial(in,Bsize)

pic = in;
ori = pic;

[h,w,~,~] = size(pic);
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

out = dfd;
end