function [bit_out,error_pattern,BER] = judging(mode, recv_sign,bit_num, a, T, sigma, bitstream,soft_or_hard)
% input args:
%     mode: 1->send and receive both know a_i  (not done yet)
%           2->only receive knows a_i
%           3->nobody knows a_i
% recv_sign: the first output of bsc_channel
% bit_num: 1/2/3
% a: if mode == 1/2, should give one of the output of bsc_channel: a
% bitstream: the input bitstream of the channel.
% soft_or_hard: if 1 then soft , if 0 then hard
% output args:
% bit_out: the bit stream or the soft result
% error_pattern: the whole error pattern 
% BER: bit error rate

    if (mode == 3)
        bit_out = judge_sign(recv_sign,bit_num);
    elseif (mode == 2)
        recv_2_proc = recv_sign./a;
        bit_out = judge_sign(recv_2_proc,bit_num);
    elseif (mode == 1)
        recv_2_proc = recv_sign./a;
        bit_out = judge_sign(recv_2_proc,bit_num);
    end
    
    
    if soft_or_hard
        if bit_num == 1
            bit_out = tanh(real(recv_sign));
        elseif bit_num == 2
            bitss = [];
            for i = 1:length(recv_sign)
                dist_for_2 = zeros(1,4);
                for k = 0:3
                    dist_for_2(k+1) = abs(exp(2*pi*1j/4*k)-recv_sign(i));
                end
                bitss = [bitss dist_for_2];
                bitss = logRayleigh(bitss, sigma);
            end
            bit_out = bitss;
        elseif bit_num == 3
            bitss = [];
            for i = 1:length(recv_sign)
                dist_for_3 = zeros(1,8);
                for k = 0:7
                    dist_for_3(k+1) = abs(exp(2*pi*1j/8*k)-recv_sign(i));
                end
                bitss = [bitss dist_for_3];
                bitss = logRayleigh(bitss, sigma);
            end
            bit_out = bitss;
        end
    else
        bit_out = bit_out(1:length(bitstream));
        error_pattern = abs(bitstream - bit_out);
        BER = sum(abs(bitstream - bit_out))/length(bitstream);   
    end
    
    
end

function out = logRayleigh(dst, sigma)
    out = 2*log(dst)-dst.^2/(sigma^2);
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