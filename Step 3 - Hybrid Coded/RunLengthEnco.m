function out = RunLengthEnco(X)

    len = length(X);        %Get the length of the AC array
    count = 1;              
    j=1;
    
    for i=1:len-1
        scan = X(i);
        if scan == X(i+1)
            
            count = count+1;
            if i==len-1
            out(j) = scan;
            out(j+1) = count;
            end
           
        else
            out(j) = scan;
            out(j+1) = count;
            count = 1;
            j=j+2;
            
            if i==len-1
            out(j) = X(len);
            out(j+1) = 1;
            end
           
            
        end
        i=i+1;
    end       
end