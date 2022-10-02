clc;
clear;
close all;

infoSeq = randi([0,1],[1,10000]);
code = Convol_Code(infoSeq,1,1);

code = GenerateSuiJi(code);  % turn 0/1 to 0.9/-0.9 or other

tic

decodedInfo = Convol_Decode(code,1,2);

toc
disp(['spending time: ',num2str(toc)]);

error = sum(infoSeq~=decodedInfo(1:length(infoSeq)));
display(error);
