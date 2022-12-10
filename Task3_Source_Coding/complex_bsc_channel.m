function [recv_sign,E_b,input_signal,output_signal] = complex_bsc_channel(...
    bitstream, bit_num, T, K, ...
    f_s,n_0)

% Param:
%   bitstream: input bitstrem
%   bit_num: the mapping bit number
%   T: Time consecutively use the channel
%   K: a parameter... still unknown
%   f_s : Sample frequency
%   n_0 : single power density

% Return：
%   recv_sign: the sign received
%   E_b: cost energy
%   input_signal: the s_t(signal send)
%   output_signal: the r_t(signal received)

% handle the snr or sigma

    sigma_0 = sqrt(f_s*n_0/2);

% encode the input bitstream to signs

    sign_stream = gray_map(bit_num,bitstream);
    recv_sign = zeros(1,length(sign_stream));
    
    n = randn(1,length(sign_stream)*T)*sigma_0;
    
% advanced data:
    total_sign_energy = 0;
    input_signal=[];
    output_signal=[];

    for i = 1:length(sign_stream) % for each sign
        sign_in = sign_stream(i);
        y_recv = 0;
        
        for k = 1:T % consecutively use the channel T times
            factor = exp(1j*2*pi*k*K/T);  % need to check t=k?
            s_t = real(sign_in*factor);
            
            input_signal = [input_signal s_t];
            total_sign_energy = total_sign_energy + s_t^2;
            
            r_t = s_t + n((i-1)*T+k);
            
            output_signal = [output_signal r_t];
                
            y_t = 2/factor*r_t;
            y_recv = y_recv + y_t;
        end
        recv_sign(i) = y_recv/T;
        
    end
    
    E_b = total_sign_energy/(length(bitstream)*f_s);
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
        gray_three_map = [1,2,4,3,8,7,5,6];
                                  
        
        for i = 1:3:length(bitstream)
            
            slice = bitstream(i:i+2);
            bin_slice = char(slice + 48);
            sign_stream((i+2)/3) = points(gray_three_map(bin2dec(bin_slice)+1));
            
        end
    end
end