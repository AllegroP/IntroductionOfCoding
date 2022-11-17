from random import randint


def encrypt(msg, Pu, n):
    msg = [int(a) for a in (list(msg))]
    intmsg = 0
    for ii in range(16):  # 需要约定明文长度(bytes)
        intmsg = (intmsg << 8) + msg[ii]
    intemsg = montMod(intmsg, Pu, n)
    emsg = []
    while intemsg > 0:
        patch = intemsg % 256
        emsg.append(patch)
        intemsg = intemsg >> 8
    return emsg


def decrypt(emsg, Pr, n):
    emsg = list(emsg)
    intemsg = 0
    while emsg != []:
        intemsg = intemsg << 8
        intemsg = intemsg + emsg[-1]
        emsg.pop()
    intmsg = montMod(intemsg, Pr, n)
    msg = []
    for ii in range(16):
        patch = intmsg % 256
        msg.append(patch)
        intmsg = intmsg >> 8
    return msg[::-1]


def generateRSA():
    flag = 0
    while flag == 0:
        prime = findPrime(512, 3)
        n = prime[0] * prime[1]
        phi = (prime[0] - 1) * (prime[1] - 1)
        Pu = prime[2]
        temp = exEuclid(phi, Pu)
        Pr = temp[1]
        while Pr < 0:
            Pr = Pr + phi
        while Pr > phi:
            Pr = Pr - phi
        if Pu * Pr % phi == 1:
            flag = 1
    return [Pu, Pr, n]


def findPrime(bitnum, n):  # 返回n个bitnum位素数
    out = []
    for num in range(n):
        trialTime = 20
        PrimeTable = [2]
        for ii in range(3, 10000, 2):
            flag = 1
            for jj in range(3, int(pow(ii, 0.5)) + 2, 2):
                if ii % jj == 0:
                    flag = 0
                    break
            if flag:
                PrimeTable.append(ii)

        flag = 0
        rand = randint(pow(2, bitnum - 1), pow(2, bitnum) - 1)
        if rand % 2 == 0:
            rand = rand + 1
        while flag == 0:
            ### 将包含<10000素数因子的随机数排除
            flag = 1
            rand = rand + 2
            for ii in PrimeTable:
                if rand % ii == 0:
                    flag = 0
                    break
            if flag:  # 通过<10000素数因子测试
                ### Miller-Rabin素性测试,测试trialTime轮
                s = 0
                temp = rand - 1
                while temp % 2 == 0:
                    temp = temp >> 1
                    s = s + 1
                d = temp
                for ii in range(trialTime):
                    a = PrimeTable[randint(0, len(PrimeTable) - 1)]
                    temp = montMod(a, d, rand)
                    if (temp != 1) and (temp != (rand - 1)):
                        flag = 0
                        for r in range(s - 1):
                            temp = (temp ** 2) % rand
                            if temp == rand - 1:
                                flag = 1
                                break
                    if flag == 0:
                        break  # 只要有一次检验不通过则无需继续检验，直接判定为合数
        out.append(rand)
    return out


def montMod(base: int, expo: int, divisor: int):
    # 计算base^expo(mod divisor)
    out = 1
    binexpo = bin(int(expo))[::-1]
    temp = base  # 底数小于除数，即a mod n = a (a < n)
    for ii in range(0, len(binexpo) - 2):
        if binexpo[ii] == '1': out = (out * temp) % divisor
        temp = (temp ** 2) % divisor
    return out


def exEuclid(a: int, b: int):
    if b == 0:
        return [1, 0]
    else:
        temp = exEuclid(b, a - b * int(a / b))
        return [temp[1], temp[0] - int(a / b) * temp[1]]


if __name__ == '__main__':
    [Pu, Pr, n] = generateRSA()
    key = [ord(ch) for ch in "Life_will_Change"]
    emsg = encrypt(key, Pu, n)
    demsg = decrypt(emsg, Pr, n)
    demsg = [chr(asc) for asc in demsg]
    print(demsg)
