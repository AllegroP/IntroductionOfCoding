function [quo, rem] = poly_div(dividend,divisor)
%polynomial_division 返回多项式除法之商。参数为二进制矢量。
    quo = [];
    pointer = 1;
    n = length(dividend);
    [~, ind] = max(divisor);
    divisor = divisor(ind: end);
    m = length(divisor);
    while pointer <= n-m+1
        if dividend(pointer) ~= 0
            dividend(pointer:pointer+m-1) = xor(dividend(pointer:pointer+m-1),divisor);
            quo = [quo, 1];
        else
            quo = [quo, 0];
        end
        pointer = pointer+1;
    end
    rem = dividend(end-m+2:end);    
end

