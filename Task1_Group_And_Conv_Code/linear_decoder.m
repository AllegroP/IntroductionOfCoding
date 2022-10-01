function origincode = linear_decoder(bitstream)
%LINEAR_DECODER 将（8，3，4）编码出的比特流译回原码。
%   基向量：01010101，00110011，00001111
    load Check_Matrix.mat
    if rem(length(bitstream),8)~=0
        error("Length of Input bitstream must be integral multiple of 8.");
    end
    for ii=1:length(bitstream)/8
        bitpatch=bitstream(8*(ii-1)+1:8*ii);
        corrector=mod(bitpatch*H',2);%校正子
        flag=0;
        pointer=1;
        while flag~=1
            if corset(pointer,:)==corrector%在校正子集里查找对应的行
                flag=1;
            else
                pointer=pointer+1;
            end
        end
        er=errorset(pointer,:);%找到对应的错误图案
        originpatch=mod(bitpatch-er,2);
    end
    flag=0;
    pointer=1;
    while flag~=1
        if codeset(pointer,:)==originpatch
            flag=1;
        else
            pointer=pointer+1;
        end
    end
    origincode=infoset(pointer,:);
end

