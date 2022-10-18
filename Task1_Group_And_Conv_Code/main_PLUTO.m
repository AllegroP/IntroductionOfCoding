clear all 
close all
clc
n = 1500;
b = 0;
rho = 0;
points = 21;
avertime = 3;
sigma = linspace(0, 1, points);
generator = [1,0,0,0,1,1,0,1,1];
info = rand(1, n)<.5;
errateh = zeros(points, 1);
errates = zeros(points, 1);
mode = 1;
bitstream_in = Convol_Code(info, mode, 1);
for ii = 1:points
    beta1 = normrnd(0, sigma(ii)^2/2, 1) + 1i*normrnd(0, sigma(ii)^2/2, 1);
    for jj = 1:avertime
        
        bitstream_out = bsc_channel(bitstream_in, 2, 10, b, rho, 0, sigma(ii), beta1, 0);
        info_decode = Convol_Decode(bitstream_out, mode, 1);
        errateh(ii) = errateh(ii) + sum(abs(info_decode(1:n)-info))/n;

        bitstream_out = bsc_channel(bitstream_in, 2, 10, b, rho, 0, sigma(ii), beta1, 1);
        info_decode = Convol_Decode(bitstream_out, mode, 2);
        errates(ii) = errates(ii) + sum(abs(info_decode(1:n)-info))/n;
    end
end
figure;
plot(sigma,errateh/avertime);
hold on 
plot(sigma,errates/avertime)
xlabel("σ");
ylabel("误码率");
legend("硬判","软判");