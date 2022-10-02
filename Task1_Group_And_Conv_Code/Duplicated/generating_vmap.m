function vmap = generating_vmap()
%GENERATING_VMAP 生成viterbi算法网格图的拓扑关系
%   表格行数即为网格单元所在行数
%   第1,2行为网格单元前键所在行
%   第3,4行为输入0时的输出码字,第5.6行为输入1时的输出码字
vmap=zeros(8,6);
for n=1:8
    state=n-1;
    front_key1=bitshift(state,-1);
    front_key2=front_key1+4;
    Ax=[1,0,1,1];
    Ay=[1,1,1,1];
    x1=mod(sum(Ax.*[0,decTobin(state,3)]),2);
    y1=mod(sum(Ay.*[0,decTobin(state,3)]),2);
    x2=mod(sum(Ax.*[1,decTobin(state,3)]),2);
    y2=mod(sum(Ay.*[1,decTobin(state,3)]),2);
    vmap(n,:)=[front_key1+1,front_key2+1,x1,y1,x2,y2];
end
vmap(vmap==0)=-1;
end

