new_errorset=zeros(32,8);
new_corset=zeros(32,5);
for ii=1:32
    s=double(dec2bin(ii-1,5))-48;%校正子
    new_corset(ii,:)=s;
    Min=10;
    index=0;
    for jj=1:length(corset)
        if corset(jj,:)==s
            temp=sum(errorset(jj,:));%计算错误图案码重
            if temp<=Min
                Min=temp;
                index=jj;
            end
        end
    end
    new_errorset(ii,:)=errorset(index,:);
end
