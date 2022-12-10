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

function [num_1, code_1]=oneSymbolEncode(onesymbol_coodbook_file, slice_heightOption, srcImage, procImage, slice_start_code)
%vlc encode by one symbol
        num_1 = [];
        code_1 = [];
        fid = fopen(onesymbol_coodbook_file, 'r');   %read .txt file line-by-line
        while ~feof(fid)
            str = fgetl(fid); 
            str_split = regexp(str, '\s+', 'split');  
            if  length(str_split)==1
                code_1 = [code_1 str_split{1}];
                break;
            else
                num_1 = [num_1 str2num(str_split{1})];
                code_1 = [code_1 string(str_split{2})];
            end
        end
        if length(num_1) ~= length(code_1)-1
            fprintf("One symbol encode:\t Table uncompleted!");
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
            fprintf("One symbol encode:\t slice_height:%d\n", slice_height);
            for y=1:size(procImage, 1)   %height
                if (mod(y,slice_height)==1)
                    % This character '0' is used to fill in the space in fields when generating text
                    fwrite(bin_file, slice_start_code, 'uint8');    % !!!!!!注意是否填充0
                    fwrite(bin_file, dec2bin((y-1)/slice_height,8), 'uint8');
                end
                for x = 1:size(procImage, 2) %width
                    pix = procImage(y,x);
                    if ismember(pix, num_1)     % pix in num_1, encode corresponding code in code_1, otherwise, encode escapecode and pix
                        fwrite(bin_file, code_1(find(num_1==pix)), 'uint8');
                    else
                        fwrite(bin_file, code_1(end), 'uint8');
                        fwrite(bin_file, dec2bin(pix,8), 'uint8');
                    end
                end
            end
            fclose(bin_file);

            % calculate the cost of transfor codebook
            length_table = 0;
            for m=1:length(num_1)
                length_table = length_table+length(char(code_1(m)));
                length_table = length_table+length(dec2bin(num_1(m)));
            end
            length_table = length_table+length(char(code_1(end)));

            % count the number of slice header in bit stream
            cnt = 0;   %number of slice header
            m = 1;  %index of bit
            bin_file = fopen('bin.txt', 'r'); %read only
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
                    fprintf("One symbol encode:\tEncode success!\t Total bits:%d\n", length(data)+length_table);
                else
                    fprintf("One symbol encode:\t Please use another VLC table!\n");
                    return;
                end
                fclose(bin_file);
            else
                fprintf("One symbol encode:\t  bin file does not exist!!!\n");
                return;
            end
        
            %%%%%%%%%%%%noise
        else
            fprintf("One symbol encode:\t bin file does not exist!!!\n");
            return;
        end 
end

