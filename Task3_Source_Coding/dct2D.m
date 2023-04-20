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

function dctCoeff8x8 = dct2D(img_block8x8)
DCTSIZE = 8;
img_block8x8 = img_block8x8';
data = int64(img_block8x8(:));   % 2D to 1D every row
data = bitshift(data, 1);
dataIdx = 1;  % index on data
enfactor = int64([65536,  47248,  50159,  55733,  65536,  83411, 121094, 237535, ...
     47248,  34064,  36162,  40181,  47248,  60136,  87304, 171253, ...
     50159,  36162,  38390,  42656,  50159,  63840,  92681, 181802, ...
     55733,  40181,  42656,  47397,  55733,  70935, 102982, 202007, ...
     65536,  47248,  50159,  55733,  65536,  83411, 121094, 237535, ...
     83411,  60136,  63840,  70935,  83411, 106162, 154124, 302325, ...
    121094,  87304,  92681, 102982, 121094, 154124, 223753, 438909, ...
    237535, 171253, 181802, 202007, 237535, 302325, 438909, 860951]);

for i=1:8
    tmp0 = int64(data(dataIdx + 0)) + int64(data(dataIdx + 7));
    tmp7 = int64(data(dataIdx + 0)) - int64(data(dataIdx + 7));
    tmp1 = int64(data(dataIdx + 1)) + int64(data(dataIdx + 6));
    tmp6 = int64(data(dataIdx + 1)) - int64(data(dataIdx + 6));
    tmp2 = int64(data(dataIdx + 2)) + int64(data(dataIdx + 5));
    tmp5 = int64(data(dataIdx + 2)) - int64(data(dataIdx + 5));
    tmp3 = int64(data(dataIdx + 3)) + int64(data(dataIdx + 4));
    tmp4 = int64(data(dataIdx + 3)) - int64(data(dataIdx + 4));
    
    % Even part
    tmp10 = tmp0 + tmp3;
    tmp13 = tmp0 - tmp3;
    tmp11 = tmp1 + tmp2;
    tmp12 = tmp1 - tmp2;

    data(dataIdx + 0) = tmp10 + tmp11;
    data(dataIdx + 4) = tmp10 - tmp11;
    
    z1 = bitshift((tmp12 + tmp13)*46341, -16);
    data(dataIdx + 2) = tmp13 + z1;
    data(dataIdx + 6) = tmp13 - z1;
    
    %Odd part
    tmp10 = tmp4 + tmp5;
    tmp11 = tmp5 + tmp6;
    tmp12 = tmp6 + tmp7;
    
    %The rotator is modified from fig 4-8 to avoid extra negations.
    z5 = bitshift((tmp10 - tmp12)*25080, -16);
    z2 = bitshift(tmp10 * 35468, -16) + z5;
    z4 = bitshift(tmp12 * 85627, -16) + z5;
    z3 = bitshift(tmp11 * 46341, -16);
    
    z11 = tmp7 + z3;
    z13 = tmp7 - z3;
    
    data(dataIdx + 5) = z13 + z2;
    data(dataIdx + 3) = z13 - z2;
    data(dataIdx + 1) = z11 + z4;
    data(dataIdx + 7) = z11 - z4;
    
    dataIdx = dataIdx+8;
end
dataIdx = 1;  % index on data
for ctr = 1:8
    tmp0 = int64(data(DCTSIZE * 0 + dataIdx)) + int64(data(DCTSIZE * 7 + dataIdx));
    tmp7 = int64(data(DCTSIZE * 0 + dataIdx)) - int64(data(DCTSIZE * 7 + dataIdx));
    tmp1 = int64(data(DCTSIZE * 1 + dataIdx)) + int64(data(DCTSIZE * 6 + dataIdx));
    tmp6 = int64(data(DCTSIZE * 1 + dataIdx)) - int64(data(DCTSIZE * 6 + dataIdx));
    tmp2 = int64(data(DCTSIZE * 2 + dataIdx)) + int64(data(DCTSIZE * 5 + dataIdx));
    tmp5 = int64(data(DCTSIZE * 2 + dataIdx)) - int64(data(DCTSIZE * 5 + dataIdx));
    tmp3 = int64(data(DCTSIZE * 3 + dataIdx)) + int64(data(DCTSIZE * 4 + dataIdx));
    tmp4 = int64(data(DCTSIZE * 3 + dataIdx)) - int64(data(DCTSIZE * 4 + dataIdx));
    
    % Even part
    tmp10 = tmp0 + tmp3;
    tmp13 = tmp0 - tmp3;
    tmp11 = tmp1 + tmp2;
    tmp12 = tmp1 - tmp2;
    
    data(DCTSIZE * 0 + dataIdx) = tmp10 + tmp11;
    data(DCTSIZE * 4 + dataIdx) = tmp10 - tmp11;
    
    z1 = bitshift((tmp12 + tmp13)*46341, -16);
    data(DCTSIZE*2 + dataIdx) = tmp13 + z1;
    data(DCTSIZE*6 + dataIdx) = tmp13 - z1;
    
    %Odd part
    tmp10 = tmp4 + tmp5;
    tmp11 = tmp5 + tmp6;
    tmp12 = tmp6 + tmp7;
    
    %The rotator is modified from fig 4-8 to avoid extra negations.
    z5 = bitshift((tmp10 - tmp12)*25080, -16);
    z2 = bitshift(tmp10 * 35468, -16) + z5;
    z4 = bitshift(tmp12 * 85627, -16) + z5;
    z3 = bitshift(tmp11 * 46341, -16);
    
    z11 = tmp7 + z3;
    z13 = tmp7 - z3;
    
    data(DCTSIZE*5 + dataIdx) = z13 + z2;
    data(DCTSIZE*3 + dataIdx) = z13 - z2;
    data(DCTSIZE*1 + dataIdx) = z11 + z4;
    data(DCTSIZE*7 + dataIdx) = z11 - z4;
    
    dataIdx = dataIdx+1;
end
data = (int64(data)).*(enfactor');
data = bitshift(data, -20);
dctCoeff8x8 = double(data);
end

