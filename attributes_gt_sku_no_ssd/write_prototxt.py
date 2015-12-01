def write_loss_layer(i, used_attrs, times, weights, bottom, attrnames, fdout):
    for k in used_attrs:
        t = times[i]
        lw = weights[i]
        btm = bottom[i]
        nameFile = '../%d/names.txt'%(k+1)
        attrname = attrnames[k][0:-2]
        fd=open(nameFile)
        ll=fd.readlines()
        fd.close()
        nval = len(ll)
        s = '''
layer {
  name: "loss%d/classifier-%s"
  type: "InnerProduct"
  bottom: "%s"
  top: "loss%d/classifier-%s"
  param {
    lr_mult: 10
    decay_mult: 1
  }
  param {
    lr_mult: 20
    decay_mult: 0
  }
  inner_product_param {
    num_output: %d
    weight_filler {
      type: "xavier"
    }
    bias_filler {
      type: "constant"
      value: 0
    }
  }
}
'''%(t, attrname, btm, t, attrname, nval)
        s = s+'''
layer {
  name: "loss%d/loss_%s"
  type: "SoftmaxWithLoss"
  bottom: "loss%d/classifier-%s"
  bottom: "%s"
  #top: "loss%d/loss_%s"
  loss_weight: %s
}
'''%(t, attrname, t, attrname, attrname, t, attrname, lw)

        s = s+'''
layer {
  name: "loss%d_%s/top-1"
  type: "Accuracy"
  bottom: "loss%d/classifier-%s"
  bottom: "%s"
  top: "loss%d_%s/top-1"
  include {
    phase: TEST
  }
}

'''%(t, attrname, t, attrname, attrname, t, attrname)
	#print s
        fdout.write(s)





def main():
    # main function
    # input and used attributes

    used_attrs = [0, 2, 5, 6, 9, 21]

    fd = open('train_pad_reference.prototxt')
    prototxt = fd.readlines()
    fd.close()

    fd = open('attr_names.txt')
    attrnames = fd.readlines()
    fd.close()

    times = [1,2,3]
    weights = ['0.3','0.3','1']
    bottom = ['loss1/fc', 'loss2/fc', 'pool5/7x7_s1']

    # output file
    fdout = open('train_pad.prototxt','wt')

    # write train file
    for i in range(23):
        fdout.write(prototxt[i])


    # write train lmdb
    s = '''
layer {
  name: "label"
  type: "Data"
  top: "classlabel"
  include {
    phase: TRAIN
  }
  data_param {
    source: "lmdb_train_pad"
    batch_size: 64
    backend: LMDB
  }
}

'''
    fdout.write(s)

    # write test file
    for i in range(23,45):
        fdout.write(prototxt[i])


    # write test lmdb
    s = '''
layer {
  name: "label"
  type: "Data"
  top: "classlabel"
  include {
    phase: TEST
  }
  data_param {
    source: "lmdb_test_pad"
    batch_size: 64
    backend: LMDB
  }
}

'''
    fdout.write(s)


    # write splice layer
    s='''
layer {
  name: "slice_attribute"
  type: "Slice"
  bottom: "classlabel"
'''
    fdout.write(s)
    for i in range(len(attrnames)):
        fdout.write('  top: "%s"\n'%attrnames[i][:-2])
    fdout.write('  slice_param {\n    slice_dim: 1\n')

    for i in range(21):
        fdout.write('    slice_point: %d\n'%(i+1))
    fdout.write('  }\n}\n')

    # silence layer
    s = '''
#layer {
#  name: "silence_data"
#  type: "Silence"
#  bottom: "data"
#}
layer {
  name: "silence"
  type: "Silence"
  bottom: "dummylabel"
}
'''
    fdout.write(s)
    
    for i in range(len(attrnames)):
        tmp = attrnames[i][:-2]
        print tmp[0:-1]
        if i not in used_attrs:
            s = '''
layer {
  name: "silence_%02d"
  type: "Silence"
  bottom: "%s"
}
'''%(i, tmp)
        else:
            s = '''
#layer {
#  name: "silence_%02d"
#  type: "Silence"
#  bottom: "%s"
#}
'''%(i, tmp)
        fdout.write(s)

    # write layers before loss1/classifier
    for i in range(45,904):
        fdout.write(prototxt[i])

    # write loss1 layers
    write_loss_layer(0, used_attrs, times, weights, bottom, attrnames, fdout)

    # write layers before loss2/classifier
    for i in range(946,1654):
        fdout.write(prototxt[i])

    # write loss2 layers
    write_loss_layer(1, used_attrs, times, weights, bottom, attrnames, fdout)

    # write layers before loss3/classifier
    for i in range(1696,2354):
        fdout.write(prototxt[i])

    # write loss3 layers
    write_loss_layer(2, used_attrs, times, weights, bottom, attrnames, fdout)


    fdout.close()




main()
