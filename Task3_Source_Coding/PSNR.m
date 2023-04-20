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

function tt = PSNR(srcImage,recImage)
%calculate the square diff between picture A and B

greenDiffImage = (double(srcImage)-double(recImage)).^2;
maxValue = 255;
img_size = size(srcImage,1)*size(srcImage,2);

mse = sum(sum(greenDiffImage./double(img_size)));
tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
end

