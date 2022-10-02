function origincode = conv_decoder(datastream)
%CONV_DECODER viterbi解(2,1,4)或(3,1,4)卷积码
%   Args:
%       datastream:数据流,绝对值小于1的电平，顺序为x1y1x2y2....
%       mode:2对应(2,1,4)码, 3对应(3,1,4)码(后一种暂时没写)
if mod(legnth(datastream),2)==1
    error("bitstream长度必须是2的倍数");
end
origincode=zeros(1,length(datastream));
L=10;
pointer=2;%标志viterbi判决最终停在存储单元的列数
codepointer=1;
score=zeros(8,L+1);%存储各个阶段的判决得分
front_node=zeros(8,L+1);%存储路径前键
score(:,1)=inf;score(1)=0;front_node(:,1)=inf;%初始化
vmap=generate_vmap();
for ii=1:length(datastream)/2
    datapatch=datastream(2*ii-1,2*ii);
    for jj=1:8
        temp=zeros(1,2);
        if mod(jj,2)==0
            temp(1)=score(vmap(jj,1),pointer-1)+sum(datapatch.*vmap(jj,3:4));
            temp(2)=score(vmap(jj,2),pointer-1)+sum(datapatch.*vmap(jj,3:4));
        else
            temp(1)=score(vmap(jj,1),pointer-1)+sum(datapatch.*vmap(jj,5:6));
            temp(2)=score(vmap(jj,2),pointer-1)+sum(datapatch.*vmap(jj,5:6));
        end
        [score(jj,pointer),ind]=min(temp);
        front_node(jj,pointer)=vmap(jj,ind);
    end
    if pointer~=L+1
        pointer=pointer+1;
    else
        %回溯
        [~,ind]=min(score(:,L+1));%回溯起点        
        while pointer~=1
            origincode(codepointer)=mod(ind-1,2);
            codepointer=codepointer+1;
            ind=front_node(ind,pointer);
            pointer=pointer-1;
        end
        score(:,1)=score(:,L+1);
        front_node(:,1)=front_node(:,L+1);
        pointer=2;
    end
end
%带收尾回溯
ind=1;
while pointer~=1
    origincode(codepointer)=mod(ind-1,2);
    codepointer=codepointer+1;
    ind=front_node(ind,pointer);
    pointer=pointer-1;
end
end