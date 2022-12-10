function bit_out = judging(...
         recv_sign,bit_num,bitstream,soft_or_hard)
     
     if soft_or_hard %1:soft decision
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
            end
            bit_out = bitss;
        end
         
     else
        bit_out = judge_sign(recv_sign,bit_num);
        bit_out = bit_out(1:length(bitstream));
        error_pattern = abs(bitstream - bit_out);
        BER = sum(abs(bitstream - bit_out))/length(bitstream); 
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
         