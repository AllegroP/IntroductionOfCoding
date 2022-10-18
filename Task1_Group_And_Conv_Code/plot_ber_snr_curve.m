function [] = plot_ber_snr_curve(bitstream,bit_num,T,b,rho,snr_dB_range,beta)
    snr_min = snr_dB_range(1);
    snr_max = snr_dB_range(2);
    
    snr = snr_min:1:snr_max;
    BER = zeros(1,length(snr));
    BER_2 = zeros(1,length(snr));
    BER_3 = zeros(1,length(snr));
    
    BER_2_1 = zeros(1,length(snr));
    
    BER_3_1 = zeros(1,length(snr));
    o = [];
    in = [];
    
    for i = 1: length(snr)
        o_t = 0;
        i_t = 0;
        for j = 1: 30
        [recv_sign,~,~,outer_snr,inner_snr,a] = bsc_channel(bitstream,bit_num,T,b,rho,1,snr(i),beta);
        [~,~,BER_temp] = judging(3,recv_sign,bit_num,a,T,bitstream,0);
        BER(i) = BER(i) + BER_temp;
        [~,~,BER_2_t] = judging(2,recv_sign,bit_num,a,T,bitstream,0);
        
        [recv_sign_2,~,~,~,~,~] = bsc_channel(bitstream,bit_num,T,0,0,1,snr(i),beta);
        [~,~,BER_temp_3] = judging(3,recv_sign_2,bit_num,a,T,bitstream,0);
        
        [recv_sign_3,~,~,~,~,~] = bsc_channel(bitstream,2,T,0,0,1,snr(i),beta);
        [~,~,BER_temp_4] = judging(3,recv_sign_3,2,a,T,bitstream,0);
        
        [recv_sign_4,~,~,~,~,~] = bsc_channel(bitstream,3,T,0,0,1,snr(i),beta);
        [~,~,BER_temp_5] = judging(3,recv_sign_4,3,a,T,bitstream,0);
        
        BER_2(i) = BER_2(i)+BER_2_t;
        BER_3(i) = BER_3(i)+BER_temp_3;
        BER_2_1(i) = BER_2_1(i)+BER_temp_4;
        BER_3_1(i) = BER_3_1(i)+BER_temp_5;
        o_t = o_t + outer_snr;
        i_t = i_t + inner_snr;
        end
        o_t = o_t/30;
        i_t = i_t /30;
        o = [o o_t];
        in = [in i_t];
        BER(i) = BER(i) / 30;
        BER_2(i) = BER_2(i) / 30;
        BER_3(i) = BER_3(i)/30;
        BER_2_1(i) = BER_2_1(i)/30;
        BER_3_1(i) = BER_3_1(i)/30;
    end
    
%     disp(o);
%     disp(in);
    plot(o,in);
    xlabel('复电平序列信道输出信噪比');
    ylabel('复采样信道输出信噪比');
    %semilogy
    figure; plot(snr,BER);  %  bit_num, b, rho, scene 3
    xlabel('复电平信道信噪比（dB）');
    ylabel('误比特率');
    grid
    hold on
    plot(snr,BER_2,'r');%  bit_num, b, rho, scene 2
    hold on
    plot(snr,BER_3,'g');% bit_num, 0, 0, scene 3
    hold on
    plot(snr,BER_2_1,'y');% 2, 0, 0, scene 3
    hold on
    plot(snr,BER_3_1,'m');% 3, 0, 0, scene 3
    xxxxx=0;
end