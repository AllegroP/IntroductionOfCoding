function rev = findRev(n, m)
%FINDREV 返回不可约多项式n模域下8位多项式m的8位逆
%   此处显示详细说明
    [~, rev] = poly_EEA(n, m);
    if length(rev)>=8
        rev = rev(end - 7: end);
    else
        rev = [zeros(1, 8 - length(rev)), rev];
    end
    rev = flip(rev);
end

