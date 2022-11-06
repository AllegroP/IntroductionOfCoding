function emsg = AES(msg, key)
%AES AES加密
%   msg为16字节字符串
    load StrucMat.mat
    
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

end

