function [outX2,outY2,residual] = removetemporal(pic1,pic2,M,Bsize);

%Padding the Reference Picture to accomodate the expansion due to search
%area
pic1padded = padarray(pic1,[0 8],'pre');
pic1padded = padarray(pic1padded,[0 8],'post');
pic1padded = padarray(pic1padded,[8 0],'pre');
pic1padded = padarray(pic1padded,[8 0],'post');

[h1,w1] = size(pic1padded); %Height and Width of Padded reference pic
[h2,w2] = size(pic2);       %Height and Width of target pic

X2=[];          %Initialize End point of vector [X direction]
Y2=[];          %Initialize End point of vector [Y direction]
X1=[];          %Initialize Start point of vector [X direction]
Y1=[];          %Initialize Start point of vector [Y direction]
predictedpic=[];   %Initialize predicted picture

for a = 1:Bsize:h1-2*Bsize      %Move the search area by Bsize along y dir
    for b = 1:Bsize:w1-2*Bsize  %Move the search area by Bsize along x dir
                X2mat=[]; Y2mat=[]; sad=[]; compblock = cell(1,256); id=1;  %Initialize SAD, Comparing block and Position matrices
                searcharea = pic1padded(a:a+M-1,b:b+M-1);       %Define the search area within the reference block
                block = pic1(a:a+Bsize-1,b:b+Bsize-1);          %Define block to be matched in the target picture
                for c = 1:1:length(searcharea)-Bsize+1          %Move the search area vertically by 1 pixel
                    for d = 1:1:length(searcharea)-Bsize+1      %Move the search area horizontally by 1 pixel
                        y2 = a+c-1-Bsize; x2 = b+d-1-Bsize;     %Pixels of the block being compared
                        compareblock = searcharea(c:c+Bsize-1,d:d+Bsize-1); %Currently comparing block within the search area
                        diff = block-compareblock;              %Take the difference between block in target pic and reference pic
                        absdiff=abs(diff);                      %Take the absolute differnce
                        sumabsdiff = sum(sum(absdiff));         %Sum the absolute difference
                        X2mat = [X2mat, x2]; Y2mat = [Y2mat, y2];   %Store pixel positions
                        sad = [sad, sumabsdiff]; compblock{id}=compareblock;    %Store the SAD value of the current comparing block
                        id=id+1;
                    end
                end
                [~,minpos] = min(sad);          %Take the minimum of the SAD for the current target block
                X2 = [X2,X2mat(minpos)]; Y2 = [Y2,Y2mat(minpos)];   %Find the pixel positions of the matched block
                X1 = [X1,b]; Y1 = [Y1,a];                           %Pixel positions of the target picture
                predictedblock = compblock{minpos};                 %Store the best matched block
                predictedpic(a:a+Bsize-1,b:b+Bsize-1)=predictedblock;   %Concatenate the best match block into the predicted picture
    end
end

U = X2-X1; V = Y2-Y1;                           %Take the vector lengths for the vector plot

residual = double(pic2)-double(predictedpic);   %Take the Residual of the Predicted picture and Target Picture
outX2 = X2; outY2 = Y2; %Outputs
end