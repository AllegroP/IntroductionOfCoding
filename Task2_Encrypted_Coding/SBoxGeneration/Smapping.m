function out = Smapping(msg)
%SMAPPING S矩阵映射
%   输入为向量化的字符。
    load StrucMat.mat
    
    charmat = double(dec2bin(msg)-'0');
    rev = findRev(generator, charmat); %保证rev的正确性；保证其为8位。最好改善多项式运算函数的写法，使位数对齐
    out = xor(mod(rev * S', 2), bias);
    out = flip(out);
    out = sum(out .* [128 64 32 16 8 4 2 1]);
end

