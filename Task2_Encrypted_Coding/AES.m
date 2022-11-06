function emsg = AES(msg, key)
%AES AES加密
%   msg为16字节字符串

    emsg = '';
    msgmat = zeros(4, 4);
    keymat = zeros(4, 4);
    emsgmat = zeros(4, 4);
    for ii = 1: 4
        for jj = 1: 4
            msgmat(ii, jj) = msg(ii + jj * 4 - 4);
            keymat(ii, jj) = key(ii + jj * 4 - 4);
            emsgmat(ii, jj) = bitxor(msgmat(ii, jj), keymat(ii, jj)); %密钥加法
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
