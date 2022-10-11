function out = GenerateSuiJi(x)
    index = x==0;
    x(index) = -0.8;
    index2 = x==1;
    x(index2) = 0.8;
    out = x;
end

