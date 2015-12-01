import caffe
import numpy as np

model_file = 'train_pad.prototxt'
pretrained_file = 'train_pad_iter_1.caffemodel'

caffe.set_mode_gpu()

labels = []
net = caffe.Net(model_file, pretrained_file, caffe.TRAIN)
for i in range(1):
    net.forward()
    # x = net.blobs['21.color'].data
    x = net.blobs['00.category'].data
    x = x.reshape(64,1)
    l = [int(y[0]) for y in x]
    print l
# after this run ../../show_predict_attribute_results.m
