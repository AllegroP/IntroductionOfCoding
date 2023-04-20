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


%%%%%%%%%% parameter setting %%%%%%%%%%%%%
%%%%% quantitation %%%%%%%%%%
%%%%% chose quantitation and the corresponding parameter %%%%%%
%block policy option

switch blockOption
    case 0
        slice_height = 1;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
    case 1
        slice_height = 4;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
    case 2
        slice_height = 8;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
    case 3
        slice_height = 16;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
    case 4
        slice_height = 32;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
    case 5
        slice_height = 64;
        fprintf("blockOption:%d\tslice_height:%d\n",blockOption,slice_height);
end

%Quantization option
    
switch i_quant
    case 0
        quant_step = 50;   % 1-255
        fprintf("uniform quantization\tquant_step=%d\n",quant_step);
    case 1
        quant_factor = 1; % 1-100
        fprintf("H.261 quantization\tquant_factor=%d\n",quant_factor);
    case 2
        quant_array = [10, 20, 30, 40];   % your quantization array
        fprintf("custom quantization\n");
end

%VLC option

onesymbol_coodbook_file = "table1.txt";
twosymbol_coodbook_file = "table2.txt";

twosymbol_decode_file = "double_data.txt";
if vlcRadio==0
    fprintf("one symbol coding\n");
elseif vlcRadio==1
    fprintf("two symbol coding\n");
end

%%%%%%%%%%%% Open File%%%%%%%%%%%%%%%%%%%%%
b_FileStat = false;   %indicate whether the file is load correctly or not
% [fileName, pathName] = uigetfile('*');  %load the image via GUI
srcImage = imread(directory);
infoSrcImage = imfinfo(directory);
if ~isempty(srcImage)
    srcImgBits = infoSrcImage.Width*infoSrcImage.Height*infoSrcImage.BitDepth; %bits of the input image
    fprintf("input image bit:%d\n",srcImgBits);
else
    fprintf("Input image load error!!\n");
    return;
end

%initialize gray table

%transformat if needed
%input image is restricted only for bmp format, thr judge below is u
%if infoSrcImage.ColorType == "truecolor"
%       srcImage = rgb2gray(srcImage);
%end

if strcmp(infoSrcImage.ColorType, "truecolor")
    srcImage = rgb2gray(srcImage);
end

%%%image process
procImage = zeros(infoSrcImage.Height, infoSrcImage.Width);

%normalized quantization
switch i_quant
    case 0 %uniform quantization
        if (quant_step > 255 || quant_step < 1)
            disp("Invalid step[1-255]!");
            return;
        end
        %bit count
        boundary = round(255/quant_step)+1;
        stepPixel = round(srcImage./quant_step);
        procImage = stepPixel.*quant_step + round(quant_step/2);
        procImage(find(procImage>255))=255;
        procImage(find(procImage<0))=0;

        %show quantizationed image
        h_proc = figure('name', 'Quant Image', 'NumberTitle', 'off');
        imshow(procImage);
        % bit caculate
        huffOri = zeros(1,boundary);   %count for huffman coding probability
        for  idx=0:boundary-1
            huffOri(1,idx+1) = sum(stepPixel(:)==idx);   % +1 matlab matrix index start from 1
        end
        bitCount = HuffmanCoding(huffOri, round(255/quant_step)+1);
        fprintf("Processed image bit:%d\n",bitCount);
    case 1 %standard quantization(JPEG quantization with DCT)
        if quant_factor > 100 || quant_factor < 1
            disp("No factor input[1-100]!");
            return;
        end
        img_width = size(procImage, 2);
        img_height = size(procImage, 1);
        if img_height < 8
            img_height = 8;
        end
        if img_width < 8
            img_width = 8;
        end
        JPEGQuantTableOri = [ %JPEG quantization table for luma
            16,11,10,16,24,40,51,61,12,12,14,19,26,58,60,55, ...
            14,13,16,24,40,57,69,56,14,17,22,29,51,87,80,62, ...
            18,22,37,56,68,109,103,77,24,35,55,64,81,104,113,92,...
            49,64,78,87,103,121,120,101,72,92,95,98,112,100,103,99
            ]';
        %JPEG quantization table with factor(1-100)(the bigger, the worse quality)
        JPEGQuantTable =double( round(JPEGQuantTableOri.*quant_factor./10));
        img_block8x8 = zeros(8,8);
        img_block64 = zeros(1,64);
        iimg_block64 = zeros(1,64);
        iimg_block8x8 = zeros(8,8);
        %bit count
        huffOri = zeros(1,10000); %record huffman tree weight
        huffOriNum = zeros(1,10000); %record huffman tree number
        huffIdx = 1; %record nodes number
        greenCheck = false;
        for i = 1:fix(img_height/8)
            for j = 1:fix(img_width/8)
                img_block8x8 = srcImage(8*(i-1)+1:8*(i-1)+8, 8*(j-1)+1:8*(j-1)+8);
                img_block64 = dct2D(img_block8x8);    %DCT transform
                %quantization part
                img_block64 = round(img_block64./JPEGQuantTable);
                for k=1:64   %bit count
                    if img_block64(k) == 0
                        huffOri(1) = huffOri(1)+1;
                    else
                        greenCheck = false;
                        for m=1:huffIdx
                            if huffOriNum(m) == img_block64(k)
                                huffOri(m) = huffOri(m)+1;
                                greenCheck = true;
                                break;
                            end
                        end
                        if ~greenCheck
                            huffOriNum(huffIdx) = img_block64(k);
                            huffOri(huffIdx) = huffOri(huffIdx)+1;
                            huffIdx = huffIdx+1;
                        end
                    end
                end
                img_block64 = img_block64 .* JPEGQuantTable;
                iimg_block64 = idct2D(img_block64);
                iimg_block64(find(iimg_block64<0))=0;
                iimg_block64(find(iimg_block64>255))=255;
                iimg_block8x8 = reshape(iimg_block64, [8,8])';
                procImage(8*(i-1)+1:8*(i-1)+8, 8*(j-1)+1:8*(j-1)+8) = iimg_block8x8;
            end
        end
        procImage = uint8(procImage);
        h_proc = figure('name', 'Quant Image', 'NumberTitle', 'off');
        imshow(procImage);
        % bit count
        bitCount = HuffmanCoding(huffOri, huffIdx);
        fprintf("Processed image bit:%d\n",bitCount);
    case 2
        %%customed quantization
        Lloyd_Max
        quant_array = b;
        img_width = size(procImage, 2);
        img_height = size(procImage, 1);
        %centroid quantization
        CentroidArray = zeros(1, length(quant_array)+1);
        CentroidCnt = zeros(1, length(quant_array)+1);
        for y=1:img_height
            for x=1:img_width
                img_pixel = srcImage(y,x);
                img_pixel = double(img_pixel);
                if img_pixel<quant_array(1)
                    CentroidArray(1) = CentroidArray(1)+img_pixel;
                    CentroidCnt(1) = CentroidCnt(1)+1;
                end
                for i=1:length(quant_array)-1
                    if img_pixel>=quant_array(i) && img_pixel<quant_array(i+1)
                        CentroidArray(i+1) = CentroidArray(i+1) + img_pixel;
                        CentroidCnt(i+1) = CentroidCnt(i+1)+1;
                    end
                end
                if img_pixel>=quant_array(end)
                    CentroidArray(length(quant_array)+1) = CentroidArray(length(quant_array)+1)+img_pixel;
                    CentroidCnt(length(quant_array)+1) = CentroidCnt(length(quant_array)+1)+1;
                end
            end
        end
        for i =1:length(quant_array)+1
            if CentroidCnt(i) ~= 0
                CentroidArray(i) = round(CentroidArray(i)/CentroidCnt(i));
            end
        end
        huffOri = zeros(1,length(quant_array)+1);
        for y = 1:img_height
            for x = 1:img_width
                img_pixel = srcImage(y,x);
                img_pixel = double(img_pixel);
                if img_pixel < quant_array(1)
                    % centroid quantization
                    img_pixel = CentroidArray(1);   % niu  img_pixel =quant_array(1)/2
                    huffOri(1) = huffOri(1)+1;
                end
                for i = 1: length(quant_array)-1
                    if img_pixel >= quant_array(i) && img_pixel < quant_array(i+1)
                        %centroid quantization
                        img_pixel = CentroidArray(i+1);  % niu img_pixel = (quant_array(i)+quant_array(i+1))/2
                        huffOri(i+1) = huffOri(i+1)+1;
                    end
                end
                if img_pixel>=quant_array(end)
                    %centroid quantization
                    img_pixel = CentroidArray(length(quant_array)+1); %niu  img_pixel = (255+quant_array(end))/2
                    huffOri(length(quant_array)+1) = huffOri(length(quant_array)+1)+1;
                end
                procImage(y,x) = img_pixel;
            end
        end
        h_proc = figure('name', 'Quant Image', 'NumberTitle', 'off');
        imshow(procImage);
        % bit count
        bitCount = HuffmanCoding(huffOri, length(quant_array)+1);
        fprintf("Processed image bit:%d\n",bitCount);
end

%%%%PSNR calculate  block based
psnrArray = psnrCalculate(blockOption, srcImage, procImage);
%finish caculation
disp("Quantization success!");

gen_codebook

%VLC coding
slice_start_code = '111111110000000011111111';
% slice_start_code = '101010101010101010101010';
% slice_start_code = '010101010101010101010101';
% slice_start_code = '100000000000000000000001';
flag = 0;
for m = 1:length(slice_start_code)
    if ~(slice_start_code(m)>='0' && slice_start_code(m)<='1')
        flag = 1;
    end
end
if flag == 1
    disp('Wrong Slice Start Code!');
    return;
end
if length(slice_start_code) ~= 24
    disp('Wrong Slice Start Code Length!');
    return;
end


%%Noise  Partition%%%
num_1=[];
code_1 = [];
num_2_1 =[];
num_2_2 = [];
code_2 = [];
if vlcRadio==0 || vlcRadio==1
    if vlcRadio==0
        [num_1, code_1]=oneSymbolEncode(onesymbol_coodbook_file, blockOption, srcImage, procImage, slice_start_code);
    else
        if mod(size(srcImage,2),2)==1
            disp("Please change another image with even pixs width!\n");
        else
            [num_2_1, num_2_2, code_2]=twoSymbolEncode(twosymbol_coodbook_file, blockOption, srcImage, procImage, slice_start_code);
        end
    end
else
    disp("Wrong vlc coding mode!!!");
    return;
end

sigma = 0;
fid = fopen("bin.txt", "r");
data = double(fgetl(fid)) - 48;
bitstream_in = Convol_Code(data, mode-1, 1);
fs = 1e5; 
bitstream_out = complex_bsc_channel(bitstream_in, mode, 21, 3, fs, sigma^2/fs);
judge_out = judging(bitstream_out, mode, 0, 1);
%judge_out = -log(judge_out) + judge_out.^2/(sigma^2/21);
infodecode = Convol_DecodePro(judge_out, mode-1);
errate = sum(abs(infodecode(1:end-3)-data));
fclose(fid);
fid = fopen("bin.txt", 'wb');
for ii = 1:length(infodecode)-mode
    fwrite(fid, char(infodecode(ii)+48), 'uint8');
end
fclose(fid);

%  input decoded image
if isempty(h_proc)
    disp('Quantize the image first!');
    return;
end
if (isempty(num_1) && isempty(code_1)) &&(isempty(num_2_1) && isempty(num_2_2) && isempty(code_2))
    disp('VLC the image first!');
    return;
end

if vlcRadio==0 || vlcRadio==1
    if vlcRadio==0   % one symbol encoding
        recImage = oneSymbolDecode('bin.txt', num_1, code_1, blockOption, ...
    srcImage,procImage, slice_start_code);

    else
        if mod(size(srcImage,2),2)==1
            disp("Change another image with even pixs width!");
        else
            recImage= twoSymbolDecode('bin.txt', num_2_1, num_2_2, code_2, blockOption, ...
    srcImage,procImage, slice_start_code);
            imshow(recImage);
        end
    end
else
    disp("No VLC option chosed!");
    return;
end

%%%%%%%%%%%% Save Proc File %%%%%%%%%%%%%%%
if ~isempty(procImage)
    %save the processed image into file
    imwrite(procImage, 'procImage.bmp');
    disp("save the processed image correctly.")
else
    disp("Quantize the image first!");
end

%%%%%%%%%%%% Save Rec File %%%%%%%%%%%%%%%%
if ~isempty(recImage) %recImage为解码后的图像
    %save the reconstructed image into file
    imwrite(uint8(recImage), 'recImage.bmp');
    disp("save the reconstructed image correctly.")
else
    disp("VLC the image first!");
end



