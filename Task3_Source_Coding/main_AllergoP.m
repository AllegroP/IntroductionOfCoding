clear
clc
close all
blockOption = 1;
i_quant = 2;
directory = 'lena_128_bw.bmp';


delta = 1e-3;%lloyd_max迭代精度

escape_prob = 0.0002; %value between 2e-4 and 2e-3

mode = 3;%viterbi参数
layers = 32;%lloyd_max量化阶数
vlcRadio = 1; % 0:one symbol 1:two connected symbols
codec