function [info, wrong_pack] = CRC_checker(bitstream,generator)
%CRC_CHECKER CRC检验
%   返回数组第一位是误包个数，之后是误包的索引。
pointer = 1;
flag = 1;
len = length(bitstream);
m = length(generator)-1;
wrong_pack = 0;
info = [];
while flag
    if pointer+200+m > len
        flag = 0;
        bitpatch = bitstream(pointer:end);
    else
        bitpatch = bitstream(pointer:pointer+199+m);
    end
    if sum(poly_rem(bitpatch,generator))~=0
        wrong_pack(1)=wrong_pack(1)+1;
        wrong_pack=[wrong_pack,floor(pointer/(200+m))+1];
    end
    info = [info, bitpatch(1:end-m)];
    pointer = pointer+200+m;
end

