%clear all 
%close all
%clc
n = 3000;
b = 0;
rho = 0;
points = 21;
avertime = 5;
bitnum = 2;
sigma = 0.25*sqrt(2*points./(1:points));
generator = [1,0,0,0,1,1,0,1,1];
info = rand(1, n)<.5;
worderr = zeros(points, 1);
patcherr = zeros(points, 1);
mode = 1;
% initialize parameter
for ii=1:points
    beta1 = normrnd(0, sigma(ii)/sqrt(2)) + 1i*normrnd(0, sigma(ii)/sqrt(2));
    for jj = 1:avertime
        %bitstream_in = linear_coder(info);
        bitstream_in = info;
        [bitstream_out,a] = bsc_channel(bitstream_in, bitnum, 10, b, rho, 0, sigma(ii)*sqrt(3/8), beta1);
        judge_out = judging(3, bitstream_out, bitnum, a, 10,sigma(ii)*sqrt(3/8), bitstream_in, 0);
        info_decoded = judge_out;
        %info_decoded = linear_decoder(judge_out, length(info));
        worderr(ii) = worderr(ii) + error_rate(info, info_decoded);
    end
end
figure;%信道硬判不支持3bit
subplot(2, 1, 1);
semilogy(2./sigma.^2, worderr/avertime); 
ylabel("误字率");
xlabel("信噪比");
title("线性码误字率");
% subplot(1, 2, 2);
% plot(sigma, log(1./(worderr/avertime)-1));
% word error rate
sigma = linspace(0,1,points);
for ii = 1:points
    beta1 = normrnd(0, sigma(ii)^2/2) + 1i*normrnd(0, sigma(ii)^2/2);
    info_after_CRC = CRC_generator(info, generator);
    bitstream_in = Convol_Code(info_after_CRC, mode, 1);
    [bitstream_out, a] = bsc_channel(bitstream_in, 2, 10, b, rho, 0, sigma(ii), beta1);
    judge_out = judging(3, bitstream_out, 2, a, 10, sigma(ii), bitstream_in, 1);
    bitstream_after_decode = Convol_DecodePro(judge_out, mode);
    [info_decoded, error] = CRC_checker(bitstream_after_decode(1:length(info_after_CRC)), generator);
    patcherr(ii) = error(1)/ceil(n/200);
end
% patch error rate
subplot(2, 1, 2);
stem(sigma, patcherr);
ylabel("误块率");
xlabel("信噪比");
title("CRC校验");

function out = error_rate(bitin,bitout)
    bitin = [bitin, zeros(1,32-mod(length(bitin),32))];
    bitout = [bitout, zeros(1,32-mod(length(bitout),32))];
    pointer = 1;
    sum = 0;
    while pointer<length(bitin)
        if any(xor(bitin(pointer:pointer+31),bitout(pointer:pointer+31)))
            sum = sum+1;
        end
        pointer = pointer+32;
    end
    out = sum/(length(bitin)/32);
end