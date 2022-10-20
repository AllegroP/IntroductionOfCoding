function out = decTobin(x) 
% Convert Decimal to Binary vector. Big-Endian.

    y = fliplr(double(dec2bin(abs(x)))-'0');
    temp = 4-length(y);
    if temp>0
        temp = zeros(1,temp);
        y = [y,temp];
    end
    out = y;
    
end
