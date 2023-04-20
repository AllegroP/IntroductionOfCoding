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

function [num_2_1, num_2_2, code_2]=twoSymbolEncode(twosymbol_coodbook_file, slice_heightOption, srcImage, procImage, slice_start_code)
%vlc encode by two symbol
num_2_1 = [];
num_2_2 = [];
code_2 = [];

fid = fopen(twosymbol_coodbook_file, 'r');   %read .txt file line-by-line
if isempty(fid)
    disp("Two symbol encode:\tNo file open!");
end
while ~feof(fid)
    str = fgetl(fid);
    str_split = regexp(str, '\s+', 'split');
    if length(str_split) ~=1 && length(str_split) ~=3
        disp("Two symbol encode:\tInvalid table!");
    elseif length(str_split)==1
        code_2 = [code_2 str_split{1}];
        break;
    else
        num_2_1 = [num_2_1 str2num(str_split{1})];
        num_2_2 = [num_2_2 str2num(str_split{2})];
        code_2 = [code_2 string(str_split{3})];
    end
end
if length(num_2_1) ~= length(code_2)-1
    disp("Two symbol encode:\tTable uncompleted!");
    return;
end
fclose(fid);

bin_file = fopen('bin.txt', 'wb');
if ~isempty(bin_file)
    switch slice_heightOption
        case 0
            slice_height = 1;
        case 1
            slice_height = 4;
        case 2
            slice_height = 8;
        case 3
            slice_height = 16;
        case 4
            slice_height = 32;
        case 5
            slice_height = 64;
    end
    %case 0 : slice_height=height
    if slice_height == 1
        slice_height = size(srcImage, 1);    %height
    end
    fprintf("Two symbol encode: \tSlice_height:%d\n", slice_height);
    
    for y=1:size(procImage, 1)   %height
        if (mod(y,slice_height)==1)
            % This character '0' is used to fill in the space in fields when generating text
            fwrite(bin_file, slice_start_code, 'uint8');    % !!!!!!注意是否填充0
            fwrite(bin_file, dec2bin((y-1)/slice_height,8), 'uint8');
        end
        for x = 1:size(procImage, 2)/2 %width
            pix1 = procImage(y, 2*x-1);
            pix2 = procImage(y, 2*x);
            if ismember(pix1, num_2_1) && ismember(pix2,num_2_2(find(num_2_1==pix1)))
%                 fprintf("x:%d\ta:%d\n",x,find(num_2_1==pix1));
                fwrite(bin_file, code_2(find(num_2_1==pix1 & num_2_2==pix2)), 'uint8');
            else
                fwrite(bin_file, code_2(end), 'uint8');
                fwrite(bin_file, dec2bin(pix1,8), 'uint8');
                fwrite(bin_file, dec2bin(pix2,8), 'uint8');
            end
        end
    end
    fclose(bin_file);
    
    % calculate the cost of transfor codebook
    length_table = 0;
    for m=1:length(num_2_1)
        length_table = length_table+length(char(code_2(m)));
        length_table = length_table+length(dec2bin(num_2_1(m)));
        length_table = length_table+length(dec2bin(num_2_2(m)));
    end
    
    % count the number of slice head in bit stream
    cnt = 0; %number of slice header
    m = 1;   %index of bit
    bin_file = fopen('bin.txt', 'r');  %read only
    if ~isempty(bin_file)
        data = fgetl(bin_file);
        while m<=length(data)
            if length(data)-m < 23
                break;   % not enough bit for slice_start_code test
            end
            temp = data(m:m+23);   %!!!!!!注意data的数据类型
            if temp == slice_start_code
                cnt = cnt+1;
                m = m+32;
            else
                m = m+1;
            end
        end

        if cnt == ceil(size(procImage,1)/slice_height)
            fprintf("Two symbol encode:\tEncode success!\t Total bits:%d\n", length(data)+length_table);
        else
            fprintf("Two symbol encode: \tPlease use another VLC table!\n");
            return;
        end
        fclose(bin_file);
    else
        disp("Two symbol encode:\tbin file does not exist!!!");
        return;
    end
    %%%%%%%%%%%%noise
else
    disp("Two symbol encode:\tbin file does not exist!!!");
    return;
end
end

