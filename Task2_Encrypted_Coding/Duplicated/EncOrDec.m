function emsg = EncOrDec(key, msg)
%RSAENCRYPTION encrypt or decrypt message by RSA PUBLIC key.
%   args:
%   key: PU for encrypt and PR for decrypt
%   msg: message to encrypt or decrypt
    base = msg;
    expo = key;
    n = 2^32;
    bitexpo = double(dec2bin(expo)-'0');
    pool = zeros(1,32);
    pool(1) = base;
    out = pool(1)^bitexpo(1);
    for ii = 2:32
        pool(ii) = mod(pool(ii - 1)^2, n);
        out = out * pool(ii) ^ bitexpo(ii);
    end
    emsg = out;
end

