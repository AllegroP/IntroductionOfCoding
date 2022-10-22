load Check_Matrix.mat H
n=1:8;
errorset=zeros(219,8);
pointer=2;
for ii=1:5
    C1=nchoosek(n,ii);
    [lengthC,~]=size(C1);
    for jj=1:lengthC
        temp=zeros(1,8);
        temp(C1(jj,:))=1;
        errorset(pointer,:)=temp;
        pointer=pointer+1;
    end
end
corset=mod(errorset*H',2);
