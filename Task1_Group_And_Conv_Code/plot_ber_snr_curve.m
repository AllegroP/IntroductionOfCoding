function [] = plot_ber_snr_curve(bitstream,bit_num,T,b,rho,snr_dB_range,beta)
    snr_min = snr_dB_range(1);
    snr_max = snr_dB_range(2);
    
    snr = snr_min:1:snr_max;
    BER = zeros(1,length(snr));
    
    o = [];
    in = [];
    
    for i = 1: length(snr)
        o_t = 0;
        i_t = 0;
        for j = 1: 30
        [~,~,~,BER_temp,outer_snr,inner_snr] = bsc_channel(bitstream,bit_num,T,b,rho,1,snr(i),beta,0); 
        BER(i) = BER(i) + BER_temp;
        o_t = o_t + outer_snr;
        i_t = i_t + inner_snr;
        end
        o_t = o_t/30;
        i_t = i_t /30;
        o = [o o_t];
        in = [in i_t];
        BER(i) = BER(i) / 30;
    end
    
%     disp(o);
%     disp(in);
    plot(o,in);
    xlabel('复电平序列信道输出信噪比');
    ylabel('复采样信道输出信噪比');
    figure; semilogy(snr,BER);
    xlabel('复电平信道信噪比（dB）');
    ylabel('误比特率');
    grid
end