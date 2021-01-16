function f = quant(block_struct)
    global Q Qmat counter DC AC ;   %Call global variables
    Bsize = length(block_struct.data); %get the side length of block 
    c = counter;
    Qmat = [16 11 10 16 24 40 51 61; 
            12 12 14 19 26 58 60 55;
            14 13 16 24 40 57 69 56; 
            14 17 22 29 51 87 80 62;
            18 22 37 56 68 109 103 77;
            24 35 55 64 81 104 113 92;
            49 64 78 87 103 121 120 101;
            72 92 95 98 112 100 103 99];    %Standard JPEG matrix
        
        
    f = (block_struct.data)./(Qmat*Q);     %Quantize the block
    f = ceil(f);                           %Round up 
    
    DC(counter) = f(1,1);                  %Get DC value to array
   
    Z = zigzag(f);                         %Get ZigZag array of matrix f
    Z = Z(2:end);                          %Eliminate the first value (DC value)
    idx1 = ((Bsize^2)-1)*(c-1)+1;          %Starting Index of AC
    idx2 = ((Bsize^2)-1)*c;                %Ending Index of AC
    AC(idx1:idx2) = Z;
    
    counter = counter +1;                  %Increment Counter
end

