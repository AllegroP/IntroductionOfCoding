function [PU, PR] = GenerateRSA()
% Generate PUBLIC and PRIVATE key pair by RSA. n = 32, meanwhile p and q in
% the algorithm are fixed.
    load PandQ.mat p q
    phi = (p-1)*(q-1);
    PU = floor(rand(1)*phi);
    flag = 0;
    while flag~=1
        PU = floor(rand(1)*phi);
        [flag, PR, ~] = gcd(PU, phi);
    end
end

