function bitstream_with_check_bits = CRC_generator(bitstream,generator)
%CRC_GENERATOR 添加CRC校验位
%   generator:生成多项式向量
pointer = 1;
flag = 1;
len = length(bitstream);
bitstream_with_check_bits = [];
while flag
    if pointer+200 > len
        flag = 0;
        bitpatch = bitstream(pointer:end);
    else
        bitpatch = bitstream(pointer:pointer+199);
        pointer = pointer+200;
    end
    temp=[bitpatch,zeros(1,length(generator)-1)];
    bitpatch = [bitpatch,poly_rem(temp,generator)];
    bitstream_with_check_bits = [bitstream_with_check_bits,bitpatch];
end
