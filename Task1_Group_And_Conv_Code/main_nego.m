
clear all 
close all
clc
n = 40;
b = 0.7;
rho = 0.996;
bitnum = 3;
info = rand(1, n)<.5;
mode = 2;
sigma = 0.05;
figure;
title("错误图案");
for ii = 1:12
    beta1 = normrnd(0, sigma/sqrt(2)) + 1i*normrnd(0, sigma/sqrt(2));
    bitstream_in = Convol_Code(info, mode, 1);
    [bitstream_out,a] = bsc_channel(bitstream_in, bitnum, 10, b, rho, 0, sigma, beta1);
    judge_out = judging(3, bitstream_out, bitnum, a, 10, sigma, bitstream_in, 1);
    info_decode = Convol_DecodePro(judge_out, mode);
    error_pattern = abs(info_decode(1:n)-info);

    error_im(:,:,1)=error_pattern*255;
    error_im(:,:,2)=(1-error_pattern)*255;
    error_im(:,:,3)=0;
    
    subplot(3,4,ii);
    image(error_im);
end
