def exEuclid(a, b):
    if(b == 0):
        return [1, 0]
    else:
        temp = exEuclid(b, a - b * int(a / b))
        return [temp[1], temp[0] - int(a / b) * temp[1]]