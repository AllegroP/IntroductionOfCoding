clear
clc
close
blockOption = 1;
i_quant = 1;
directory = 'lena_128_bw.bmp';

layers = 8;%lloyd_max量化阶数
delta = 1e-3;%lloyd_max迭代精度

vlcRadio = 1; % 0:one symbol 1:two connected symbols
escape_prob = 0.001; %value between 2e-4 and 2e-3

mode = 3;%viterbi参数

codec