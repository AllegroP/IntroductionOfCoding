clc;
clear;
close all;

img = imread('lena_128_bw.bmp');
layers = 128;

x = [0:255];
% imgv = img(:);
% [f]=ksdensity(imgv,x); % 利用ksdensity计算像素值的分布
% plot(x,f);
[height, width] = size(img);
f = zeros(1,256);
for i = 1:height
    for j = 1:width
        f(img(i, j) + 1) = f(img(i, j) + 1) + 1;
    end
end
f=f/sum(f);

b = linspace(0, 256, layers + 1);   %129个界值
% y = linspace(0.5*(256/layers),256-0.5*(256/layers), layers);  %128个判决电平
% y = linspace(0, 256 - layers, layers).' + layers / 2;
y = sort(255*rand(1,layers));
%按照均匀量化初始化分层电平和重建电平

D(1)=10000;
delta=0.0001;
j = 0;
M = layers;
while j<1000
    j = j+1;

    
    ytemp = y;
    for t = 1:M %逐层计算并更新分层电平的质心作为重建电平
        y(t) = (sum(x(b(t) + 1:b(t + 1)) .* (f(b(t) + 1:b(t + 1))))) ./ sum(f(b(t) + 1:b(t + 1)));

        if (isnan(y(t)))
            y(t) = ytemp(t); %这个区间里没有概率，还是保持原样
        end
    end
    
    %迭代计算重建电平的中点更新分层电平
    for t = 2:layers
        b(t) = (y(t) + y(t - 1)) / 2;
    end
    b = ceil(sort(b)); %取整
    
    %计算MSE
    Dsum = 0;
    for i=1:M
        fx = (x-y(i)).^2;
        Dsum = Dsum + (sum(fx(b(i) + 1:b(i + 1)) .* (f(b(i) + 1:b(i + 1)))  ));
    end
    
    D(j) = Dsum;   %设定循环次数的阈值
%     if j>1 && (D(j-1)-D(j))/D(j-1)<delta
%         break;
%     end
safdsdf = 1;

end


