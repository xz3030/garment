for i in {5,11,13,15,16,17,18,19}
do
 cp train_no_shuffle.prototxt $i      
 cp train_pad.prototxt $i 
 cp solver_pad.prototxt $i
 cp view_features.py $i
 cp view_features_train.py $i
 cp view_results.py $i
done;
