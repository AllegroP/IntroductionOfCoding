function [] = plot_all(bitstream,T,snr_dB_range,beta)
    snr_min = snr_dB_range(1);
    snr_max = snr_dB_range(2);
    
    snr = snr_min:1:snr_max;
    BER = zeros(1,length(snr));
    BER_2 = zeros(1,length(snr));
    BER_3 = zeros(1,length(snr));
    
    BER_2_1 = zeros(1,length(snr));
    
    BER_3_1 = zeros(1,length(snr));
    BER_3_2 = zeros(1,length(snr));
    b = 0.7;
    rho = 0.996;
    for i = 1: length(snr)
        for j = 1: 30
        [recv_sign,~,~,~,~,a] = bsc_channel(bitstream,1,T,b,rho,1,snr(i),beta);
        [~,~,BER_temp] = judging(3,recv_sign,1,a,T,bitstream,0);
        BER(i) = BER(i) + BER_temp;
        [~,~,BER_2_t] = judging(2,recv_sign,1,a,T,bitstream,0);
        
        [recv_sign_2,~,~,~,~,a_2] = bsc_channel(bitstream,2,T,b,rho,1,snr(i),beta);
        [~,~,BER_temp_3] = judging(3,recv_sign_2,2,a_2,T,bitstream,0);
        
%         [recv_sign_3,~,~,~,~,~] = bsc_channel(bitstream,2,T,b,rho,1,snr(i),beta);
        [~,~,BER_temp_4] = judging(2,recv_sign_2,2,a_2,T,bitstream,0);
        
        [recv_sign_4,~,~,~,~,a_3] = bsc_channel(bitstream,3,T,b,rho,1,snr(i),beta);
        [~,~,BER_temp_5] = judging(3,recv_sign_4,3,a_3,T,bitstream,0);
        [~,~,BER_temp_6] = judging(2,recv_sign_4,3,a_3,T,bitstream,0);
        
        BER_2(i) = BER_2(i)+BER_2_t;
        BER_3(i) = BER_3(i)+BER_temp_3;
        BER_2_1(i) = BER_2_1(i)+BER_temp_4;
        BER_3_1(i) = BER_3_1(i)+BER_temp_5;
        BER_3_2(i) = BER_3_2(i)+BER_temp_6;
        end
        
        BER(i) = BER(i) / 30;
        BER_2(i) = BER_2(i) / 30;
        BER_3(i) = BER_3(i)/30;
        BER_2_1(i) = BER_2_1(i)/30;
        BER_3_1(i) = BER_3_1(i)/30;
        BER_3_2(i) = BER_3_2(i)/30;
    end
    
    figure; plot(snr,BER);  %  bit_num, b, rho, scene 3
%    legend('bit_num = 1,b = 1,rho = 1, scene 3');
    xlabel('复电平信道信噪比（dB）');
    ylabel('误比特率');
    grid
    hold on
    plot(snr,BER_2,'r');%  bit_num, b, rho, scene 2
%    legend('bit_num = 1,b = 1,rho = 1, scene 2');
    hold on
    plot(snr,BER_3,'g');% bit_num, 0, 0, scene 3
%    legend('bit_num = 2,b = 1,rho = 1, scene 3');
    hold on
    plot(snr,BER_2_1,'y');% 2, 0, 0, scene 3
%    legend('bit_num = 2,b = 1,rho = 1, scene 2');
    hold on
    plot(snr,BER_3_1,'m');% 3, 0, 0, scene 3
%    legend('bit_num = 3,b = 1,rho = 1, scene 3');
    hold on
    plot(snr,BER_3_2,'k');
%    legend('bit_num = 3,b = 1,rho = 1, scene 2');
    legend('bit_num = 1,b = 0.7,rho = 0.996, scene 3','bit_num = 1,b = 0.7,rho = 0.996, scene 2',...
        'bit_num = 2,b = 0.7,rho = 0.996, scene 3','bit_num = 2,b = 0.7,rho = 0.996, scene 2',...
        'bit_num = 3,b = 0.7,rho = 0.996, scene 3','bit_num = 3,b = 0.7,rho = 0.996, scene 2');
    xxxxx=0;
end