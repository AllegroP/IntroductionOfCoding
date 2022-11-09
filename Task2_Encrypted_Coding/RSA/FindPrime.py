from random import randint
from MontMod import montMod

def findPrime(bitnum, n):# 返回n个1024位素数
    out = []
    for num in range(n):
        trialTime = 5 
        PrimeTable = [2]
        for ii in range(3, 10000, 2):
            flag = 1
            for jj in range(3, int(pow(ii, 0.5)), 2):
                if(ii % jj == 0): flag = 0; break
            if(flag): PrimeTable.append(ii)

        flag = 0
        rand = randint(pow(2, bitnum - 1),pow(2, bitnum) - 1)
        if(rand % 2 == 0): rand = rand + 1
        while(flag == 0):
            ### 将包含<10000素数因子的随机数排除
            flag = 1
            rand = rand + 2
            for ii in PrimeTable:
                if(rand % ii == 0): flag = 0; break
            if(flag): #通过<10000素数因子测试
            ### Miller-Rabin素性测试,测试trialTime轮
                s = 0
                temp = rand - 1
                while(temp % 2 == 0):
                    temp = temp / 2
                    s = s + 1
                d = temp    
                for ii in range(trialTime):
                    a = PrimeTable[randint(0, 200)]
                    temp = montMod(a, d, rand)
                    if((temp != 1) and (temp != (rand - 1))):
                        flag = 0
                        for r in range(s - 1):
                            temp = (temp ** 2) % rand
                            if(temp == rand - 1): flag = 1; break
                    if(flag == 0): break #只要有一次检验不通过则无需继续检验，直接判定为合数
        out.append(rand)
    return out