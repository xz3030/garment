for i in {9,21}
do
cd $i;
#GLOG_logtostderr=1 /DB/rhome/zxu/workspace/caffe-master/build/tools/caffe train -solver ./solver_pad.prototxt -weights ../chongqing_iter_445000.caffemodel --gpu 1 2>&1 | tee log_pad.txt;
python view_results.py
python view_features.py
python view_features_train.py
cd ..;
done
