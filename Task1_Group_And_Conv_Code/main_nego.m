clear all,close all,clc;
n = 50;
info =  floor(rand(1,n)*2);
% beta = (randn() + sqrt(-1)*randn())/sqrt(2);
k = 0:9;
beta = exp(1j*2*pi/10*k);
b = 0.9;
rho = 0.95;
idx = 1:50;

for i = 1:length(k)
    [recv_sign,~,~,~,~,a] = bsc_channel(info,1,10,b,rho,0,0.5,beta(i));
    [~,error_pattern,BER] = judging(3,recv_sign,1,a,10,info,0);
    sum(error_pattern)
    error_im(:,:,1)=error_pattern*255;
    error_im(:,:,2)=(1-error_pattern)*255;
    error_im(:,:,3)=0;
    figure;
    subplot(3,1,1);
    image(error_im);
    subplot(3,1,2);
    plot(idx,abs(angle(a)));
    subplot(3,1,3);
    plot(idx,abs(a));
    
end