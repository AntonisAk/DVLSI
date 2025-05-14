h = [1,2,3,4,5,6,7,8]
x = [213, 107, 172, 58, 147, 225, 92, 39, 205, 26, 180, 99, 248, 15, 134, 73]


y = [0 for _ in x]
for i in range(len(x)):
    temp = i - 8
    if temp < 0: temp = -1
    for j in range(i,temp,-1):
        #print("---------------")
        #print(i,j)
        y[i] += x[j] * h[(i - j) % 8]
        #print(y[i],x[j],h[(i - j) % 8])
    print(y[i])