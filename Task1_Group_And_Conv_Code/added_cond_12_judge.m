
close all,clear all,clc
%setup stage:
L = 24;     % length of the bitstream
T = 10;      % num of use of the sampling channel for one sign
bit_num = 2; % num of bits compressed in the mapping

% channel parm:
b = 0;
rho = 0;
sigma_n = 0.5; % noise variance = sqrt(noise_power)= sqrt(2 / (10^(snr_dB/10)))


bitstream = floor(rand(1,L)*2);

% bitstream = [0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
% bitstream = [0,0,0,1,1,1,1,0];

figure; plot(bitstream,'r+');

sign_stream = gray_map(bit_num,bitstream);
recv_sign = zeros(1,length(sign_stream));
figure,plot(sign_stream,'o');

mean_signal_energy_per_symbol = sign_stream*sign_stream'/length(sign_stream)

n = sigma_n*(randn(1,length(sign_stream)*T)+sqrt(-1)*randn(1,length(sign_stream)*T))/sqrt(2);
mean_noise_energy_per_symbol = n*n'/length(n)
%begin using channel
beta = (randn(1)+sqrt(-1)*randn(1))/sqrt(2);
a = [];

for i = 1:length(sign_stream) % for each sign
    sign_in = sign_stream(i)/sqrt(T);
    y_recv = 0;
    a_add = 0;
    for k = 1:T  % consecutively use the channel
        a_add = a_add + a_temp;
        a_temp = sqrt(1-b^2) + b* beta;
        y_recv = y_recv + a_temp * sign_in + n(i*k);
        beta = rho * beta + sqrt(1 - rho^2) * (randn(1)+sqrt(-1)*randn(1))/sqrt(2);
        
    end
    a = [a,a_add];
    recv_sign(i) = y_recv/sqrt(T);
end

figure; plot(recv_sign,'ro');

% judge

bit_out = judge_sign(recv_sign,bit_num);
error_pattern = abs(bitstream - bit_out);
figure;plot(bitstream,'g+'); hold on; plot(bit_out,'bx'); plot(error_pattern,'ro');
BER = sum(abs(bitstream - bit_out))/length(bitstream);

function sign_stream = gray_map(bit_num,bitstream)
    n = 2^bit_num;
    
    % fix the length of the bitstream:
    if(mod(length(bitstream),bit_num)~=0)
        bitstream = [bitstream,zeros(1, bit_num - mod(length(bitstream),bit_num))];
    end
    
    %generate points on an unit circle
    point_idx = 0:n-1;
    points = exp(1j * 2*pi/n * point_idx);
    
    %convert bitstream to signstream, using gray mapping
    sign_stream = zeros(1, length(bitstream)/bit_num);
    if(bit_num == 1)
        for i = 1:length(bitstream)
            sign_stream(i) = points(bitstream(i)+1);
        end
    elseif (bit_num == 2)
        gray_two_map = [1,2,4,3];
        
        for i = 1:2:length(bitstream)
            
            slice = bitstream(i:i+1);
            bin_slice = char(slice + 48);
            sign_stream((i+1)/2) = points(gray_two_map(bin2dec(bin_slice)+1));
            
        end
        
    elseif (bit_num == 3)
        gray_three_map = [1,2,4,3,8,7,5,6];
        
        for i = 1:3:length(bitstream)
            
            slice = bitstream(i:i+2);
            bin_slice = char(slice + 48);
            sign_stream((i+2)/3) = points(gray_three_map(bin2dec(bin_slice)+1));
            
        end
    end
end


function bit_out = judge_sign(recv_sign,bit_num)
    bit_out = zeros(1,bit_num*length(recv_sign));
    n = 2^bit_num;
    pattern = exp(1j * 2*pi/n * (0:n-1));
%     code_1 = [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
%     code_2 = [0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
%     code_3 = [0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
    
    code = [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
        0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
        0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
    for i = 1:length(recv_sign)
        dist = abs(recv_sign(i)-pattern);
        [~,idx] = min(dist);
        bit_out(((i-1)*bit_num+1):((i-1)*bit_num+bit_num)) = code(bit_num,(idx-1)*bit_num+1:(idx-1)*bit_num+bit_num);
    end
    

end


function bit_out = judeg_cond_12(recv_sign,bit_num,a)
    recv_2_proc = recv_sign./a;
    bit_out = judge_sign(recv_2_proc,bit_num);
end
