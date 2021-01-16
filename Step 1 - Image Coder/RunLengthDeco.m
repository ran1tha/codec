function out = RunLengthDeco(X)
    len = length(X);
    out = [];
  
    for i=1:(len/2)
        for j=1:X(2*i)
            out = [out X(2*i-1)];
        end
    end

end