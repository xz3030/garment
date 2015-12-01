##Garment related analysis  
*-- written by zhe xu --*  
*-- re-organized in 15/01/12 --*  
  
##Goal  
Prepare data for running mental image retrieval on the 30w taobao 
garment dataset.  
  
##Process  
1.  Generate attribute list and image-SKU-attribute maps  
         read_attributes.m  
         generate_image_to_sku.m  
2.  Train GoogleNet for each attribute  
         write_attribute_files_no_ssd_sku_split.m  
     then go to directory "attributes_gt_sku_no_ssd/{1..22}" and run the training scripts  
3.  Prepare detailed data for mental image algorithm  
    *To do list:*
    Split the 30w dataset according to roughly 4 categories and 5 or 6?? colors.  
    Given a category and a color, find related SKUs and find a representive image for each SKU  
    Prepare the similarity matrix for each of the category-color-indepent scenarios.  
    Run the mental image retrieval process on this dataset.  
  
  
##file description  
    cache/30w_im2sku.mat:  
        imglist: a list of image names (need to rename to current folder)  
        skulist: a list of SKU names  
        im2sku:  a map of imid to skuid  
---
  
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
