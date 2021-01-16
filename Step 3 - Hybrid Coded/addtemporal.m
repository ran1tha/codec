function reconstructed = addtemporal(pic1,residual,Bsize,X1,Y1,X2,Y2,h,w)

totblk = length(X1);         %Repeat for all blocks
predicted = zeros(h,w);    %Initialize predicted picture

for i=1:totblk
    startx = X1(i); starty = Y1(i); %Vector Start Positions
    endx = X2(i); endy = Y2(i);     %Vector End Positions
    predicted(starty:starty+Bsize-1,startx:startx+Bsize-1) = pic1(endy:endy+Bsize-1,endx:endx+Bsize-1); %Assign blocks from reference pic to predicted pic
end

reconstructed = predicted+residual; %Create the reconstructed image by adding the residual
end