

function [recv_sign, mean_signal_energy_per_symbol,mean_noise_energy_per_symbol, outer_snr, snr_for_sample_channel, a] ...
    = bsc_channel(bitstream,bit_num,T,b,rho,flag_snr_or_sigma,snr_or_sigma,beta_in)


%     L = 24;     % length of the bitstream
%     T = 10;      % num of use of the sampling channel for one sign
%     bit_num = 1; % num of bits compressed in the mapping
% 
%     % channel parm:
%     b = 0;
%     rho = 0;
%     sigma_n = 1; % noise variance = sqrt(noise_power)= sqrt(2 / (10^(snr_dB/10)))
    if(flag_snr_or_sigma)
        
        sigma_n = sqrt(2 / (10^(snr_or_sigma/10)));
    else
        
        sigma_n = snr_or_sigma;
    end
    %bitstream = floor(rand(1,L)*2);

    % bitstream = [0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
% 
%     bitstream = [0,0,0,1,1,1,1,0];

%     figure; plot(bitstream,'r+');title = ("Bitstream input");

    sign_stream = gray_map(bit_num,bitstream);
    recv_sign = zeros(1,length(sign_stream));


    mean_signal_energy_per_symbol = sign_stream*sign_stream'/length(sign_stream);

    n = sigma_n*(randn(1,length(sign_stream)*T)+sqrt(-1)*randn(1,length(sign_stream)*T))/sqrt(2);
    mean_noise_energy_per_symbol = n*n'/length(n);
    %begin using channel
    beta = beta_in;
    
    noise_amp = [];
    a = [];
    for i = 1:length(sign_stream) % for each sign
        sign_in = sign_stream(i)/sqrt(T);
        y_recv = 0;
        added_a = 0;
        for k = 1:T  % consecutively use the channel

            a_temp = sqrt(1-b^2) + b* beta;
            
            added_a = added_a+a_temp;
            y_recv = y_recv + a_temp * sign_in + n(i*k);
            beta = rho * beta + sqrt(1 - rho^2) * (randn(1)+sqrt(-1)*randn(1))/sqrt(2);

        end
        recv_sign(i) = y_recv/sqrt(T);
        a = [a added_a/T];
        noise_a = recv_sign(i) - added_a/sqrt(T) * sign_in;
        noise_amp = [noise_amp real(noise_a)];
        
    end
    snr_for_sample_channel = 2 / (T*sigma_n^2);
%     outer_snr = length(noise_amp)/ sum(real(noise_amp));
    outer_snr = 1/var(noise_amp);
    %figure; plot(recv_sign,'ro');title("Bitstream output");
%     figure,plot(sign_stream,'o'); 
%     
%     hold on
%     figure,plot(recv_sign,'*');title = ("Planisphere"),xlim([-2,2]), ylim([-2,2]),axis equal;
    % judge

%     bit_out = judging(3,recv_sign,bit_num,a,T,bitstream);
%     bit_out = bit_out(1:length(bitstream));
%     error_pattern = abs(bitstream - bit_out);
% %     figure;plot(bitstream,'g+'); hold on; plot(bit_out,'bx'); plot(error_pattern,'ro');
% %     title("After judgement");
%     BER = sum(abs(bitstream - bit_out))/length(bitstream);
%     
%     
%     
%     if soft_or_hard && bit_num == 1
%         bit_out = tanh(real(recv_sign));
%     end

end

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
        gray_three_map = [1,2,4,3,7,8,6,5];
                                  
        
        for i = 1:3:length(bitstream)
            
            slice = bitstream(i:i+2);
            bin_slice = char(slice + 48);
            sign_stream((i+2)/3) = points(gray_three_map(bin2dec(bin_slice)+1));
            
        end
    end
end


% function bit_out = judge_sign(recv_sign,bit_num)
%     bit_out = zeros(1,bit_num*length(recv_sign));
%     n = 2^bit_num;
%     pattern = exp(1j * 2*pi/n * (0:n-1));
% %     code_1 = [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
% %     code_2 = [0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
% %     code_3 = [0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
%     
%     code = [0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
%         0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;...
%         0,0,0,0,0,1,0,1,1,0,1,0,1,1,0,1,1,1,1,0,1,1,0,0];
%     for i = 1:length(recv_sign)
%         dist = abs(recv_sign(i)-pattern);
%         [~,idx] = min(dist);
%         bit_out(((i-1)*bit_num+1):((i-1)*bit_num+bit_num)) = code(bit_num,(idx-1)*bit_num+1:(idx-1)*bit_num+bit_num);
%     end
%    
% end
% function bit_out = judge_cond_2(recv_sign,bit_num,a,T)
%     
%     recv_2_proc = recv_sign./a;
%     bit_out = judge_sign(recv_2_proc,bit_num);
% end


% function [bit_out,a_idx] = judge_cond_1(recv_sign,bit_num,a)
%     %check the angle
%     
%     angle_of_a = angle(a);
%     angle_of_a = abs(angle_of_a);
%     abs_of_a = abs(a);
%     
%     thrsh_angle = [pi/3, pi/6, pi/12];
% 
%     idx = angle_of_a > thrsh_angle(bit_num);
% 
% 
% end
