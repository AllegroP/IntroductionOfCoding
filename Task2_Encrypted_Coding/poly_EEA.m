function [x, y] = poly_EEA(a, b)
%POLY_EEA 多项式扩展欧几里得算法
    if ~any(b) || isempty(b)
        x = 1; y = 0;
    else
        [quo, rem] = poly_div(a, b);
        [xx, yy] = poly_EEA(b, rem);
        temp = poly_mul(quo, yy);
        len = max([length(xx), length(yy), length(temp)]);
        xx = [zeros(1,len - length(xx)), xx];
        yy = [zeros(1,len - length(yy)), yy];
        temp = [zeros(1, len - length(temp)), temp];% zero-padding
        x = yy;
        y = xx - temp;
        x = mod(x, 2);
        y = mod(y, 2);
    end
end

