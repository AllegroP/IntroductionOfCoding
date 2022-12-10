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

function psnrArray = psnrCalculate(blockOption, srcImage, procImage)
%%%%%
switch blockOption
    case 0
        block = 1;
    case 1
        block = 4;
    case 2
        block = 8;
    case 3
        block = 16;
    case 4
        block = 32;
    case 5
        block = 64;
end
img_width = size(srcImage, 2);
img_height = size(srcImage, 1);
num_block_width = floor(img_width/block); %num block in width
num_block_height = floor(img_height/block); %num block in height
edge_width = img_width - num_block_width*block;  %edge part
edge_height = img_height - num_block_height*block; % edge part

%calculate the square diff between ori and proc pic
tmp = (double(srcImage) - double(procImage)).^2;

maxValue = 255;
% full picture
if block ==1
    psnrArray = [];
    img_size = img_width * img_height;
    mse = sum(sum(tmp./img_size));
    tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
    psnrArray = [psnrArray tt];
else
    % different block policy, psnr stored in zigzag scan order
    psnrArray = [];
    for i= 0:num_block_height-1 
        for j = 0:num_block_width-1
            img_size = block*block;
            mse = sum(sum(tmp(i*block+1:i*block+block, j*block+1:j*block+block)./img_size));
            tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
            psnrArray = [psnrArray tt];
        end
        if edge_width ~=0  %right edge
            img_size = block*edge_width;
            mse = sum(sum(tmp(i*block+1:i*block+block, num_block_width*block+1:num_block_width*block+edge_width)./img_size));
            tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
            psnrArray = [psnrArray tt];
        end
    end
    if edge_height ~= 0  %bottom edge
        for j = 0:num_block_width-1
            img_size = edge_height * block;
            mse = sum(sum(tmp(num_block_height*block+1:num_block_height*block+edge_height, ...
                j*block+1:j*block+block)./img_size));
            tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
            psnrArray = [psnrArray tt];
        end
        if edge_width ~=0
            img_size = edge_height*edge_width;
            mse = sum(sum(tmp(num_block_height*block+1:num_block_height*block+edge_height, ...
                num_block_width*block+1:num_block_width*block+edge_width)./img_size));
            tt = 10 * (log(maxValue*maxValue/mse)/log(10));   % log is ln in MATLAB
            psnrArray = [psnrArray tt];
        end
    end
end


end

