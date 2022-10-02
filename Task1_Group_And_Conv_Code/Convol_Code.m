function [out] = Convol_Code(infoSeq,mode,iftail)

% infoSeq: information sequence
% mode: method to coding: --2:(15,17) --3:(13,15,17) 
% iftail: --0: notail  --1:tail --2:bite tail

    if (mode~=2)&&(mode~=3)
        error("such mode is undefined.");
    end
    if (iftail == 1)
        infoSeq = [infoSeq,0,0,0];% 3 registers
    end
    
    len = length(infoSeq);
    out=zeros(1,len*mode);
    pointer=1;

    regs = zeros(1,3); % Temporary state
    for ii = 1:len
        m = dot([1,0,1,1],[infoSeq(ii),regs]);% 15
        n = dot([1,1,1,1],[infoSeq(ii),regs]);% 17
        if mode==3
            p = dot([1,1,0,1],[infoSeq(ii),regs]);% 13
            y = mod([p,m,n],2);
        else
            y = mod([m,n],2);
        end
        regs = [infoSeq(ii),regs(1:2)];            
        out(pointer:pointer+mode-1) = y;
        pointer = pointer+mode;
    end

end