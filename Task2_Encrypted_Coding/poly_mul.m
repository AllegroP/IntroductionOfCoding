function product = poly_mul(a, b)
%POLY_MUL 此处显示有关此函数的摘要
%   此处显示详细说明
    product = mod(conv(a, b), 2);
end

