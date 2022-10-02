function bitstream = linear_coder(origincode)
%LINEAR_CODER (8,3,4)线性编码
%   基向量:01010101，00110011，00001111
if mod(length(origincode),3)~=0
    error("Length of input code must be integral multiple of 3.")
end
G=[0,1,0,1,0,1,0,1;
    0,0,1,1,0,0,1,1;
    0,0,0,0,1,1,1,1];
bitstream=length(origincode)/3*8;
for ii=1:length(origincode)/3
    codepatch=origincode(3*(ii-1)+1:3*ii);
    bitstream(8*(ii-1)+1:8*ii)=mod(codepatch*G,2);
end
end

