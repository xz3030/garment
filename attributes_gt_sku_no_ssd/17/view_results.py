import caffe
import numpy as np

model_file = 'train_pad.prototxt'
pretrained_file = 'train_pad_iter_10000.caffemodel'

caffe.set_mode_gpu()

labels = []
net = caffe.Net(model_file, pretrained_file, caffe.TEST)
for i in range(800):
    if i%10==0: print i,'/800'
    net.forward()
    x = net.blobs['loss3/classifier-attribute'].data
    l = np.argmax(x, axis=1)
    labels.extend(l)

#print labels

l = [str(x) for x in labels]

fd = open('predict_results.txt','wt')
fd.writelines('\n'.join(l))
fd.close()


# after this run ../../show_predict_attribute_results.m
