clear all close all clc
n = 2345;
mode = 1;
b = 0;
rho = 0;
sigma = 0.5;
generator = [1,1,0,1];
info = floor(rand(1,n)*2);
info_after_CRC = CRC_generator(info, generator);
bitstream_in = Convol_Code(info_after_CRC, mode, 1);
bitstream_out = bsc_channel(bitstream_in, 3, 10, b, rho, 0, sigma);
bitstream_after_decode = Convol_Decode(bitstream_out, mode, 1);
[info_decoded, error] = CRC_checker(bitstream_after_decode, generator);
sum(abs(info_decoded-info))