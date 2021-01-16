function f = iquant(block_struct)
    global Q;
    global Qmat
    
    f = (block_struct.data).*(Qmat*Q);
end

