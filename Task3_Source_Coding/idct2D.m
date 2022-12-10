% % % % % % % % % % % % % % % % % % % % % % 
% Author:Ziwei Wei, Benben Niu
% E-mail: weizw18@mails.tsinghua.edu.cn
%
%New phases added by Junyou Chen by Nov2015;
%   Quantization, Inverse Quantization, DCT, IDCT, Huffman Coding, VLC
%Revised by Benben Niu by Nov. 2016;
%   Slice-related VLC
%Revised by Benben Niu by Sep. 2018;
%   Noise Level, Iterations
%Revised by Ziwei Wei by Aug. 2020
%   software transportation to MATLAB platform
%
%   Copyright (c) 2020, VISUAL COMMUNICATION LAB. EE DEPARTMENT, TSINGHUA UNIVERSITY. All rights reserved.   
%   Note: Redistribution and use in source and binary forms, with or without modification, are permitted only 
%   for "The Introduction to Coding" course of EE Department, Tsinghua University. The following conditions are required to
%   be met:
%        *The name of VISUAL COMMUNICATION LAB. EE DEPARTMENT, TSINGHUA UNIVERSITY may not be used to endorse or 
%          promote products derived from this software without specific prior written permission.
% % % % % % % % % % % % % % % % % % % % % % 

function idctCoeff64 = idct2D(img_block64)
% 2 dimension reverse DCT process
DCTSIZE = 8;
defactor = int64([
    65536, 90901, 85626, 77062, 65536, 51491, 35467, 18081, ...
    90901, 126083, 118767, 106888, 90901, 71420, 49195, 25079, ...
    85626, 118767, 111876, 100686, 85626, 67276, 46340, 23624, ...
    77062, 106888, 100686, 90615, 77062, 60547, 41705, 21261, ...
    65536, 90901, 85626, 77062, 65536, 51491, 35467, 18081, ...
    51491, 71420, 67276, 60547, 51491, 40456, 27866, 14206, ...
    35467, 49195, 46340, 41705, 35467, 27866, 19195, 9785, ...
    18081, 25079, 23624, 21261, 18081, 14206, 9785, 4988])';
data = int64(img_block64) .* defactor;
data = bitshift(data, -13);
dataIdx = 1;  % index on data
for ctr = 1:DCTSIZE
    if data(dataIdx + 1)+data(dataIdx + 2)+data(dataIdx +3)+data(dataIdx +4) ...
            +data(dataIdx +5)+data(dataIdx +6)+data(dataIdx +7)==0
        data(dataIdx + 1) = data(dataIdx + 0);
        data(dataIdx + 2) = data(dataIdx + 0);
        data(dataIdx + 3) = data(dataIdx + 0);
        data(dataIdx + 4) = data(dataIdx + 0);
        data(dataIdx + 5) = data(dataIdx + 0);
        data(dataIdx + 6) = data(dataIdx + 0);
        data(dataIdx + 7) = data(dataIdx + 0);   
        
        dataIdx = dataIdx + DCTSIZE;
        continue;
    end
    
    % Even part
    tmp0 = int64(data(dataIdx + 0));
    tmp1 = int64(data(dataIdx + 2));
    tmp2 = int64(data(dataIdx + 4));
    tmp3 = int64(data(dataIdx + 6));
    
    tmp10 = tmp0 + tmp2;
    tmp11 = tmp0 - tmp2;

    tmp13   = tmp1 + tmp3;
    tmp12   = tmp1 - tmp3;
    tmp12 = tmp12 * 92682;
    tmp12 = bitshift(tmp12, -16);
    tmp12 = tmp12 - tmp13;
    
    tmp0 = tmp10 + tmp13;
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    
    % Odd part
    tmp4 = int64(data(dataIdx + 1));
    tmp5 = int64(data(dataIdx + 3));
    tmp6 = int64(data(dataIdx + 5));
    tmp7 = int64(data(dataIdx + 7));
    
    z13 = tmp6 + tmp5;
    z10 = tmp6 - tmp5;
    z11 = tmp4 + tmp7;
    z12 = tmp4 - tmp7;
    
    tmp7  = z11 + z13;
    tmp11 = z11 - z13;
    tmp11 = tmp11 * 92682;
    tmp11 = bitshift(tmp11, -16);
    
    z5 = bitshift((z10 + z12) * 121095, -16);
    tmp10 = bitshift(z12 *  70936, -16) - z5;
    tmp12 = -bitshift(z10 * 171254, -16) + z5;
    
    tmp6 = tmp12 - tmp7;
    tmp5 = tmp11 - tmp6;
    tmp4 = tmp10 + tmp5;
    
    data(dataIdx + 0) = tmp0 + tmp7;
    data(dataIdx + 7) = tmp0 - tmp7;
    data(dataIdx + 1) = tmp1 + tmp6;
    data(dataIdx + 6) = tmp1 - tmp6;
    data(dataIdx + 2) = tmp2 + tmp5;
    data(dataIdx + 5) = tmp2 - tmp5;
    data(dataIdx + 4) = tmp3 + tmp4;
    data(dataIdx + 3) = tmp3 - tmp4;
    
    dataIdx = dataIdx + DCTSIZE;
end
% Pass 2: process columns.
dataIdx = 1;  % index on data
for ctr = 1:DCTSIZE
    % Even part
    tmp0 = int64(data(DCTSIZE * 0 + dataIdx));
    tmp1 = int64(data(DCTSIZE * 2 + dataIdx));
    tmp2 = int64(data(DCTSIZE * 4 + dataIdx));
    tmp3 = int64(data(DCTSIZE * 6 + dataIdx));
    
    tmp10 = tmp0 + tmp2;
    tmp11 = tmp0 - tmp2;

    tmp13   = tmp1 + tmp3;
    tmp12   = tmp1 - tmp3;
    tmp12 = tmp12 * 92682;
    tmp12 = bitshift(tmp12, -16);
    tmp12 = tmp12 - tmp13;
    
    tmp0 = tmp10 + tmp13;
    tmp3 = tmp10 - tmp13;
    tmp1 = tmp11 + tmp12;
    tmp2 = tmp11 - tmp12;
    
    % Odd part
    tmp4 = int64(data(DCTSIZE * 1 + dataIdx));
    tmp5 = int64(data(DCTSIZE * 3 + dataIdx));
    tmp6 = int64(data(DCTSIZE * 5 + dataIdx));
    tmp7 = int64(data(DCTSIZE * 7 + dataIdx));
    
    z13 = tmp6 + tmp5;
    z10 = tmp6 - tmp5;
    z11 = tmp4 + tmp7;
    z12 = tmp4 - tmp7;
    
    tmp7 = z11 + z13;
    tmp11= z11 - z13;
    tmp11 = tmp11 * 92682;
    tmp11 = bitshift(tmp11, -16);
    
    z5 = bitshift((z10 + z12) * 121095, -16);
    tmp10 = bitshift(z12 *  70936, -16) - z5;
    tmp12 = -bitshift(z10 * 171254, -16) + z5;
    
    tmp6 = tmp12 - tmp7;
    tmp5 = tmp11 - tmp6;
    tmp4 = tmp10 + tmp5;
    
    data(DCTSIZE * 0 + dataIdx) = tmp0 + tmp7;
    data(DCTSIZE * 7 + dataIdx) = tmp0 - tmp7;
    data(DCTSIZE * 1 + dataIdx) = tmp1 + tmp6;
    data(DCTSIZE * 6 + dataIdx) = tmp1 - tmp6;
    data(DCTSIZE * 2 + dataIdx) = tmp2 + tmp5;
    data(DCTSIZE * 5 + dataIdx) = tmp2 - tmp5;
    data(DCTSIZE * 4 + dataIdx) = tmp3 + tmp4;
    data(DCTSIZE * 3 + dataIdx) = tmp3 - tmp4;
    
    dataIdx = dataIdx + 1;
end
    idctCoeff64 = fix(bitshift(data, -6));
end

