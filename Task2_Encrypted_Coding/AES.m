function emsg = AES(msg, key)
%AES AES加密
%   msg, key为16字节字符串

    %加载数据
    emsg = '';
    msgmat = zeros(4, 4);
    keymat = zeros(4, 4);
    emsgmat = zeros(4, 4);
    for ii = 1: 4
        for jj = 1: 4
            msgmat(ii, jj) = msg(ii + jj * 4 - 4);
            keymat(ii, jj) = key(ii + jj * 4 - 4);
            emsgmat(ii, jj) = bitxor(msgmat(ii, jj), keymat(ii, jj)); %密钥加法
            % emsgmat(ii, jj) = Smapping(emsgmat(ii, jj)); %字节代换
        end
    end

    %加密数据
    for round = 1:10
        keymat = updateKey(keymat, round); %密钥更新
        for ii = 1: 4
            for jj = 1: 4
                emsgmat(ii, jj) = Smapping(emsgmat(ii, jj)); %字节代换
            end
        end
        %行位移
        for ii = 1: 4
            temp = emsgmat(ii, :);
            for jj = 1: 4
                emsgmat(ii, jj) = temp(mod(jj - 1 + (ii - 1), 4) + 1);
            end
        end
        %列混淆
        emsgmat = ColumnMix(emsgmat);
        %密钥加法
        for ii = 1: 4
            for jj = 1: 4
                emsgmat(ii, jj) = bitxor(msgmat(ii, jj), keymat(ii, jj));
            end
        end        
    end

    %输出数据
    for jj = 1: 4
        for ii = 1: 4
            emsg = [emsg, char(emsgmat(ii, jj))];
        end
    end
end

function out = ColumnMix(emsgmat)
    load StrucMat.mat

    out = zeros(4, 4);
    for ii = 1: 4
        for jj = 1: 4
            Sum = zeros(1, 8);
            for kk = 1: 4
                vec1 = double(dec2bin(Mix(ii, kk))-'0');
                vec2 = double(dec2bin(emsgmat(kk, jj))-'0');
                [~, temp] = poly_div(poly_mul(vec1, vec2), generator);
                temp = [zeros(1, 8 - length(temp)), temp];
                Sum = xor(Sum, temp);
            end
            out(ii, jj) = sum(Sum .* [128 64 32 16 8 4 2 1]);
        end
    end
end

function out = updateKey(keymat, round)
    keymat(:, 1) = bitxor(keymat(:, 1), (G(keymat(:, 3), round))');
    for ii = 2: 4
        keymat(:, ii) = bitxor(keymat(:, ii), keymat(:, ii - 1));
    end
    out = keymat;
end

function out = G(emsgpatch, round)
    load StrucMat.mat

    out = zeros(1, 4);
    temp = emsgpatch;
    for ii = 1: 4
        out(ii) = temp(mod(ii, 4) + 1);
        out(ii) = Smapping(emsgpatch(ii));
    end
    out(1) = bitxor(out(1), Rcon(round));
end