from FindPrime import findPrime
from ExEuclid import exEuclid

def generateRSA():
    prime = findPrime(65, 3)
    n = prime[0] * prime[1]
    phi = (prime[0] - 1) * (prime[1] - 1)
    Pu = prime[2] #PrPu + kphi = 1
    temp = exEuclid(phi, Pu)
    Pr = temp[1]
    while(Pr < 0):
        Pr = Pr + phi
    while(Pr > phi):
        Pr = Pr - phi
    return [Pu, Pr, n]