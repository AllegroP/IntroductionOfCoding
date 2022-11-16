python version：3.9.12

## Ref

[密码学基础：AES加密算法 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/78913397)

[RSA周边——大素数是怎样生成的？ (bindog.github.io)](http://bindog.github.io/blog/2014/07/19/how-to-generate-big-primes/)

## log

修复findPrime: 

- 寻找10000以下素数时，设置除数不大于被除数的平方根取整->不大于被除数的平方根取整+2，这样一定会取到被除数平方根+1和被除数平方根其中的一个数；
- 随后在Miller-Rabin检测中，用左移1位而非除2提取2的整数次幂，以免数据被转换为浮点数；
- 修复后素数可足够长。

修复generateRSA：

exEuclid算法在a和b都特别大时有几率生成x,y使得ax+by = -1，推测可能是由于舍入误差所致。只需将这部分结果滤除即可。