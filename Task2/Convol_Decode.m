function info = Convol_Decode(code,encodingMode,decodingMode)
%{
code: 0 1 sequence or decimal sequence
encodingMode: --1:(15,17)  --2:(13,15,17)
decodingMode: --1:Hard judgement --2:Soft judgement
%}
    if (encodingMode == 1) % 1:(15,17) 
        from = zeros(16,length(code)/2);
        frontScore = zeros(1,16);

        for i = 1:16  % Distance initialization as the starting point states are limited
            if i>1
                frontScore(i) = 1000000;
            end
        end
        
        nowScore = zeros(1,16);

        for i = 1:length(code)/2  % Viterbi Updation process
            for j = 1:16 
                [s1,s2,c1,c2] = getfront(j,1); % Get the pre states and path information
                r = code(2*i-1 : 2*i);
                if frontScore(s1)+Distance(r,c1,decodingMode) > frontScore(s2)+Distance(r,c2,decodingMode)
                    nowScore(j) = frontScore(s2)+sum(c2~=r);
                    from(j,i) = s2;
                else
                    nowScore(j) = frontScore(s1)+sum(c1~=r);
                    from(j,i) = s1;
                end     
            end
            frontScore = nowScore;
        end

        res = [];
        [~,endState] = min(nowScore);
        for i = length(code)/2:-1:1 % Backtracking algorithm
            res = [getinfo(endState),res];
            % display(endState);
            endState = from(endState,i);
        end
        info = res;
        
    else  % 2:(13,15,17) Coding mode
        
        from = zeros(16,length(code)/3);
        frontScore = zeros(1,16);

        for i = 1:16  % Distance initialization as the starting point states are limited
            if i>1
                frontScore(i) = 1000000;
            end
        end

        nowScore = zeros(1,16);

        for i = 1:length(code)/3  % Viterbi Updation process
            for j = 1:16 
                [s1,s2,c1,c2] = getfront(j,2); % Get the pre states and path information
                r = code(3*i-2 : 3*i);
                if frontScore(s1)+Distance(r,c1,decodingMode) > frontScore(s2)+Distance(r,c2,decodingMode)
                    nowScore(j) = frontScore(s2)+sum(c2~=r);
                    from(j,i) = s2;
                else
                    nowScore(j) = frontScore(s1)+sum(c1~=r);
                    from(j,i) = s1;
                end     
            end
            frontScore = nowScore;
        end

        res = [];
        [~,endState] = min(nowScore);
        for i = length(code)/3:-1:1 % Backtracking algorithm
            res = [getinfo(endState),res];
            % display(endState);
            endState = from(endState,i);
        end
        info = res;
    end
end


function [s1,s2,c1,c2] = getfront(state,mode)
    y = decTobin(state-1);
    s1 = dot([y(2:3),0],[1,2,4])+1;
    s2 = dot([y(2:3),1],[1,2,4])+1;
    if (mode == 1)
        m = dot([1,1,0,1],[y(1:3),0]);
        n = dot([1,1,1,1],[y(1:3),0]);
        x1 = (mod(m,2)==1) | (m==1);
        x2 = (mod(n,2)==1) | (n==1);
        c1 = [x1,x2];
        m2 = dot([1,1,0,1],[y(1:3),1]);
        n2 = dot([1,1,1,1],[y(1:3),1]);
        x3 = (mod(m2,2)==1) | (m2==1);
        x4 = (mod(n2,2)==1) | (n2==1);
        c2 = [x3,x4];
    else
        m = dot([1,0,1,1],[y(1:3),0]);
        n = dot([1,1,0,1],[y(1:3),0]);
        p = dot([1,1,1,1],[y(1:3),0]);
        x1 = (mod(m,2)==1) | (m==1);
        x2 = (mod(n,2)==1) | (n==1);
        x3 = (mod(p,2)==1) | (p==1); 
        c1 = [x1,x2,x3];
        m2 = dot([1,0,1,1],[y(1:3),1]);
        n2 = dot([1,1,0,1],[y(1:3),1]);
        p2 = dot([1,1,1,1],[y(1:3),1]);
        x4 = (mod(m2,2)==1) | (m2==1);
        x5 = (mod(n2,2)==1) | (n2==1);
        x6 = (mod(p2,2)==1) | (p2==1); 
        c2 = [x4,x5,x6];
    end
   
end

function out = getinfo(state) 
    res = decTobin(state-1);
    out = res(1);
end

function out = decTobin(x) % Convert Decimal to Binary
    if x == 0
        y=[0,0,0];
    else
        y = fliplr(double(dec2bin(abs(x)))-'0');
        while (length(y)<3)
            y = [y,0];  % Align to 4 digits
        end
    end
    out = y;
end

function out = Distance(a,b,mode)
    if (mode==1)
        out = sum(a~=b);
    else
        index = a==0;
        a(index) = -1;
        out = -sum(a.*b);
    end
end
