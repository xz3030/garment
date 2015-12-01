for i in {1..21}
do
 cd $i
 n=$(sed -n '$=' nattr.txt)
 sed -i "s/9999/$n/g" train_pad.prototxt
 sed -i "s/9999/$n/g" train_no_shuffle.prototxt
 cd ..
done
