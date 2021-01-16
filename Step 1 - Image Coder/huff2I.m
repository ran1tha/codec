function out = huff2I(coded,dict,w,h); 

%% Decode from huffman

deco = huffmandeco(coded,dict);     %Decode from huffman
out = reshape(deco,w,h);

end