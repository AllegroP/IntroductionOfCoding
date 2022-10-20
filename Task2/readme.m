%{
Interface information:

Convol_Code():
    function [out] = Convol_Code(infoSeq,mode,iftail)
    % infoSeq: information sequence
    % mode: method to coding: --1:(15,17) --2:(13,15,17) 
    % iftail: --0: notail  --1:tail --2:bite 

Convol_Decode():
    function info = Convol_Decode(code,encodingMode,decodingMode)
    % code: 0 1 sequence or decimal sequence
    % encodingMode: --1:(15,17)  --2:(13,15,17)
    % decodingMode: --1:Hard judgement --2:Soft judgement


To do:
Tail-Biting Coding

%}