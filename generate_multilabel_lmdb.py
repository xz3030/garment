import caffe
import lmdb
from PIL import Image
import numpy as np
import scipy.io

inputs = scipy.io.loadmat('attributes_gt_sku_no_ssd/all/all_attrs.mat')


train_pad_db = lmdb.open('attributes_gt_sku_no_ssd/all/lmdb_train_pad', map_size=int(1e12))
test_pad_db = lmdb.open('attributes_gt_sku_no_ssd/all/lmdb_test_pad', map_size=int(1e12))

trainattr = inputs['train_attrs']
testattr = inputs['test_attrs']

fd = open('attributes_gt_sku_no_ssd/all/seed.txt','r')
P = fd.readlines()
fd.close()
P = [int(P[x].strip('\n')) for x in range(len(P))]

trainattr = trainattr[P,:]
print trainattr[0:10,:]

with train_pad_db.begin(write=True) as in_txn:
    for in_idx in range(len(trainattr)):
        im = np.array(trainattr[in_idx]) # or load whatever ndarray you need
        im = im.reshape((im.shape[0],1,1))
        im_dat = caffe.io.array_to_datum(im)
        in_txn.put('{:0>10d}'.format(in_idx), im_dat.SerializeToString())
train_pad_db.close()


with test_pad_db.begin(write=True) as in_txn:
    for in_idx in range(len(testattr)):
        im = np.array(testattr[in_idx]) # or load whatever ndarray you need
        im = im.reshape((im.shape[0],1,1))
        im_dat = caffe.io.array_to_datum(im)
        in_txn.put('{:0>10d}'.format(in_idx), im_dat.SerializeToString())
test_pad_db.close()
