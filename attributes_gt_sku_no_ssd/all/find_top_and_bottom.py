fd = open('train_pad.prototxt')
l = fd.readlines()
print len(l)
fd.close()

toplist = []
bottomlist = []


for ii in range(len(l)):
    i = l[ii]
    if 'top' in i:
        x = i.split(':')[1][2:-2]
        if not x in toplist:
            toplist.append(x)

    if 'bottom' in i:
        x = i.split(':')[1][2:-2]
        if not x in bottomlist:
            bottomlist.append(x)

#print toplist
#print bottomlist

for t in toplist:
    if not t in bottomlist:
        print t
