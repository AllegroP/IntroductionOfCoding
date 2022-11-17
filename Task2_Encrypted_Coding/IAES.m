function msg = IAES(emsg, key)
%AES AES加密
%   msg, key为16字节字符串
    load StrucMat.mat ISBox 
    %加载数据
    msg = [];
    emsgmat = zeros(4, 4);
    keymat = zeros(4, 44);
    msgmat = zeros(4, 4);
    for ii = 1: 4
        for jj = 1: 4
            emsgmat(ii, jj) = emsg(ii + jj * 4 - 4);
            keymat(ii, jj) = key(ii + jj * 4 - 4);
        end
    end

    for round = 1:10
        keymat(:, (4 * round + 1):4 * (round + 1)) =...
            updateKey(keymat(:, (4 * round - 3):4 * round), round); %密钥更新
    end
    %解密数据
    for round = 10:-1:1
        keynow = keymat(:, (4*round+1):4*(round+1));
        %密钥加法
        for ii = 1: 4
            for jj = 1: 4
                emsgmat(ii, jj) = bitxor(emsgmat(ii, jj), keynow(ii, jj));
            end
        end   
        %列混淆
        emsgmat = IColumnMix(emsgmat);
        %行位移
        for ii = 1: 4
            temp = emsgmat(ii, :);
            for jj = 1: 4
                emsgmat(ii, jj) = temp(mod(jj - 1 - (ii - 1), 4) + 1);
            end
        end  
        %字节代换
        for ii = 1: 4
            for jj = 1: 4
                emsgmat(ii, jj) = ISBox(emsgmat(ii, jj) + 1);
            end
        end
    end
    %加初始密钥
    for ii = 1: 4
        for jj = 1: 4
            msgmat(ii, jj) = bitxor(emsgmat(ii, jj), keymat(ii, jj));
        end
    end 
    %输出数据
    for jj = 1: 4
        for ii = 1: 4
            msg = [msg, msgmat(ii, jj)];
        end
    end
end
%以下内容和加密部分除左乘矩阵为IMIX外相同。
function out = IColumnMix(emsgmat)
    load StrucMat.mat IMix generator

    out = zeros(4, 4);
    for ii = 1: 4
        for jj = 1: 4
            Sum = zeros(1, 8);
            for kk = 1: 4
                vec1 = double(dec2bin(IMix(ii, kk))-'0');
                vec2 = double(dec2bin(emsgmat(kk, jj))-'0');
                [~, temp] = poly_div(poly_mul(vec1, vec2), generator);
                temp = [zeros(1, 8 - length(temp)), temp];
                Sum = xor(Sum, temp);
            end
            out(ii, jj) = sum(Sum .* [128 64 32 16 8 4 2 1]);
        end
    end
end
%以下内容和加密部分相同。
function out = updateKey(keymat, round)
    keymat(:, 1) = bitxor(keymat(:, 1), (G(keymat(:, 3), round))');
    for ii = 2: 4
        keymat(:, ii) = bitxor(keymat(:, ii), keymat(:, ii - 1));
    end
    out = keymat;
end

function out = G(emsgpatch, round)
    load StrucMat.mat SBox Rcon

    out = zeros(1, 4);
    temp = emsgpatch;
    for ii = 1: 4
        out(ii) = temp(mod(ii, 4) + 1);
        out(ii) = SBox(emsgpatch(ii) + 1);
    end
    out(1) = bitxor(out(1), Rcon(round));
end