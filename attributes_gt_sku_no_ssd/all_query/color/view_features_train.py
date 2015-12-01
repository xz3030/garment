import caffe
import numpy as np

model_file = 'train_no_shuffle.prototxt'
pretrained_file = 'train_pad_iter_20000.caffemodel'

caffe.set_mode_gpu()

fd = open('predict_features_train.txt','wt')
net = caffe.Net(model_file, pretrained_file, caffe.TRAIN)
for i in range(60):
    print i, '/60'
    net.forward()
    x = net.blobs['pool5/7x7_s1'].data
    for j in range(64):
        for k in range(1024):
            fd.write('%.4f '%float(x[j][k]))
        fd.write('\n')
fd.close()
    

# after this run ../../show_predict_attribute_results.m
