clear all 
close all
clc
n = 1500;
b = 0;
rho = 0;
points = 21;
avertime = 3;
bitnum = 2;
sigma = 0.5*sqrt(2*points./(1:points));
generator = [1,0,0,0,1,1,0,1,1];
info = rand(1, n)<.5;
errateh = zeros(points, 1);
errates = zeros(points, 1);
mode = 1;
bitstream_in = Convol_Code(info, mode, 1);
for ii = 1:points
    beta1 = normrnd(0, sigma(ii)/sqrt(2)) + 1i*normrnd(0, sigma(ii)/sqrt(2));
    for jj = 1:avertime
        
        [bitstream_out,a] = bsc_channel(bitstream_in, bitnum, 10, b, rho, 0, sigma(ii), beta1);
        judge_out = judging(3, bitstream_out, bitnum, a, 10, bitstream_in, 0);
        info_decode = Convol_Decode(judge_out, mode, 1);
        errateh(ii) = errateh(ii) + sum(abs(info_decode(1:n)-info))/n;

        judge_out = judging(3, bitstream_out, bitnum, a, 10, bitstream_in, 1);
        info_decode = Convol_DecodePro(judge_out, mode);
        errates(ii) = errates(ii) + sum(abs(info_decode(1:n)-info))/n;
    end
end
figure;
semilogy(2./sigma.^2, errateh/avertime); 
hold on 
semilogy(2./sigma.^2, errates/avertime); 
xlabel("信噪比");
ylabel("误码率");
legend("硬判","软判");
title("2bit电平映射");