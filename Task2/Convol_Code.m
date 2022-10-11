function [out] = Convol_Code(infoSeq,mode,iftail)

% infoSeq: information sequence
% mode: method to coding: --1:(15,17) --2:(13,15,17) 
% iftail: --0: notail  --1:tail --2:bite tail

    if (iftail == 1)
        infoSeq = [infoSeq,0,0,0];
    end
    
    len = length(infoSeq);
    tmpout = [];
    
    if (mode == 1)
        d = zeros(1,3); % Temporary state
        for i = 1:len
            m = dot([1,1,0,1],[infoSeq(i),d]);
            n = dot([1,1,1,1],[infoSeq(i),d]);
            y1 = (mod(m,2)==1) | (m==1);
            y2 = (mod(n,2)==1) | (n==1);
            d = [infoSeq(i),d(1:2)];            
            tmpout = [tmpout,y1,y2];
        end
    else
        d = zeros(1,3); % Temporary state
        for i = 1:len
            m = dot([1,0,1,1],[infoSeq(i),d]);
            n = dot([1,1,0,1],[infoSeq(i),d]);
            p = dot([1,1,1,1],[infoSeq(i),d]);
            y1 = (mod(m,2)==1) | (m==1);
            y2 = (mod(n,2)==1) | (n==1);
            y3 = (mod(p,2)==1) | (p==1);
            d = [infoSeq(i),d(1:2)];            
            tmpout = [tmpout,y1,y2,y3];
        end
    end
    out = tmpout;
end