##Garment related analysis  
*-- written by zhe xu --*  
*-- re-organized in 15/01/12 --*  
  
##Goal  
Garment analysis: clothes matching.
To match a garment from a source domain to a target domain. Include an example of the looklive dataset.
  
##Process  
1.  Generate attribute list and image-SKU-attribute maps  
        read_attributes.m  
        generate_image_to_sku.m  
2.  Train GoogleNet in 80w dataset (Yichao Xiong), let's name it model "xiong" 
3.  Train GoogleNet for each attribute  
        write_attribute_files_no_ssd_sku_split.m  
     then go to directory "attributes_gt_sku_no_ssd/{1..22}" and run the training scripts  
4.  Do the matching stuffs
  
  
##file description  
    cache/train_test_split_sku.mat:  
        train_test_split: Train/Test split on SKU level, 1 for training.  
---
    attr_names.txt: attribute names for altogether 22 attributes  
---
    clothing_attributes.mat:  
        22 structs, each with a "names" and a "label"  
        names: attribute value names  
        label: image-attributevalue maps  
  
  
##Script description:  
    add_padding_to_30w_data.m: generate images with padding for 30w dataset.  

    generate_imge_to_sku.m   : generate image-SKU maps and train_test_splits  

    init.m                   : initialization, set enviroments  

    read_attributes.m        : from original chongqing 30w dataset, read attributes into memory, and save the results to "cloting_attributes.mat"  

    show_attributes.m        : randomly show images labeled by an attribute  

    show_predict_attribute_results.m:  After doing CNN training, show results for predicting an attribute  

    show_predict_features_nn.m:  After doing CNN training, show nearest neighbors according to the CNN feature  

    view_features.py         : use caffe to extract features, save to txt file  

    write_attribute_files_no_ssd_sku_split:   Filter attribute values (Discard values with few examples and add it to a category named "other") and write training/testing files for training attribute-CNNs  

## Special scripts for this branch
     add_padding_to_looklive  : add padding to images in the looklive dataset  
     
     show_predict_features_nn_looklive.m: nearest neighbor using only one attribute (or "xiong")  
     
     show_predict_features_nn_looklive_combine_attributes.m: filter the images by multiple attributes, then compute nearest neigbor using "xiong"
