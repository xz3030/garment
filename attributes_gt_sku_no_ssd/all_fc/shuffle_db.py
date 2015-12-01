import os
import numpy as np

fd = open('pad_train.txt','r')
l = fd.readlines()
N = len(l)
fd.close()

if not os.path.exists('seed.txt'):
    fd = open('seed.txt','wt')
    P = list(np.random.permutation(range(N)))
    P = [str(P[x]) for x in range(len(P))]
    print P[0:3]
    fd.writelines('\n'.join(P))
    fd.close()
else:
    fd = open('seed.txt','r')
    P = fd.readlines()
    fd.close()
    P = [int(P[x].strip('\n')) for x in range(len(P))]

fd = open('pad_train_shuffle.txt','wt')
for i in range(len(P)):
    fd.write(l[P[i]])
fd.close()
    
