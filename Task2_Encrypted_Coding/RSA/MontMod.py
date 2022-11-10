def montMod(base, expo, divisor):
#计算base^expo(mod divisor)
    out = 1
    binexpo = bin(int(expo))[::-1] 
    temp = base #底数小于除数，即a mod n = a (a < n)
    for ii in range(0, len(binexpo) - 2):
        if(binexpo[ii] == '1'): out = (out * temp) % divisor
        temp = (temp ** 2) % divisor
    return out