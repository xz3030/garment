% write attribute files, in /DATA/, split by sku level
% come after read_attributes.m
%{=
%% attribute related dirs and paths and parameters
mainDir = 'attributes_gt_sku_no_ssd';    % main dir
ratioTest = 0.2;              % ratio of train/test split
ratioDiscard = 1/200;         % ratio of discarding an attribute after removing nans


%% train test split
nim = length(clothing_attributes{1}.label);

load('cache/train_test_split_sku.mat');

%% imglist
%imDir = '/win_D/cigit_taobao_data/30w/attribute_cut/';
imDir = '/DATA/data/ycxiong/cigit_taobao_data/30w/attribute_cut/';
%imPadDir = '/win_D/cigit_taobao_data/30w/attribute_cut_plus_padding/';
imPadDir = '/DATA/data/zxu/cigit_taobao_data/30w/attribute_cut_plus_padding/';
imglist = textread('/DATA/data/ycxiong/cigit_taobao_data/30w/ansi/imglist.txt','%s');
imgPadlist = arrayfun(@(i)[imPadDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
imglist = arrayfun(@(i)[imDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);

%}
%% parse attributes
clothing_attributes_after_parsing = clothing_attributes;

for i=1:length(clothing_attributes)
    fprintf('Attribute %d\n', i);
    ca = clothing_attributes{i};
    nvalue = length(ca.names);
    
    label_tmp = ca.label;
    
    % find nan and other
    indexother = -1;
    nNan = 0;
    for j=1:nvalue
        if strcmp(ca.names{j},'NAN')
            nNan = sum(label_tmp==j);
            label_tmp(label_tmp==j)=-1;   % -1: nan 
        end
        if strcmp(ca.names{j}, '其他')
            indexother = j;
            % set all images belong to other to label 0
            label_tmp(label_tmp==indexother)=0;  
        end
    end
    
    % we discard nans, after that if an attribute has a small number of 
    % images in the dataset (<nImRemain*ratioDiscard), we remove this
    % attribute and send it into class 'other'
    nImRemain = nim - nNan;
    thresh = nImRemain * ratioDiscard;
    
    for j=1:nvalue
        if strcmp(ca.names{j},'NAN') || strcmp(ca.names{j}, '其他')
            continue
        end
        nattr = sum(label_tmp==j);
        if nattr<thresh
            % not enough images, set this category's images to label 0
            label_tmp(label_tmp==j)=0;  
        end
    end
        
    % post processing
    % find unique labels, if has nan, has -1, if has other, has 0.
    [label_set, mm, nn] = unique(label_tmp);
    
    n_nanorother = sum(label_set<=0);  % 0 for other, -1 for nan
    clothing_attributes_after_parsing{i}.label = ...
        nn-n_nanorother;   % new label, start from 0.
    clothing_attributes_after_parsing{i}.label(label_tmp==-1)=-1; % nan
    
    % add other again at the beginning
    has_other = sum(clothing_attributes_after_parsing{i}.label==0)>0;
    if has_other
        clothing_attributes_after_parsing{i}.names = ...
            cat(2, '其他', clothing_attributes{i}.names(label_set(label_set>0)));
    else
        clothing_attributes_after_parsing{i}.names = ...
            clothing_attributes{i}.names(label_set(label_set>0));
        clothing_attributes_after_parsing{i}.label = clothing_attributes_after_parsing{i}.label-1;
    end
    
    % write train and test file
    attrDir = fullfile(mainDir, int2str(i));
    mkdir_if_missing(attrDir);
    trainFile = fullfile(attrDir, 'train.txt');
    testFile = fullfile(attrDir, 'test.txt');
    trainPadFile = fullfile(attrDir, 'pad_train.txt');
    testPadFile = fullfile(attrDir, 'pad_test.txt');
    
    nameFile = fullfile(attrDir, 'names.txt');
    fd_train = fopen(trainFile, 'wt');
    fd_test = fopen(testFile, 'wt');
    fd_train_pad = fopen(trainPadFile, 'wt');
    fd_test_pad = fopen(testPadFile, 'wt');
    fd_name = fopen(nameFile, 'wt');
   
    
    for j=1:nim
        if clothing_attributes_after_parsing{i}.label(j)<0
            continue
        end
        
        if train_test_split(j)==1
            fprintf(fd_train, '%s %d\n', imglist{j}, clothing_attributes_after_parsing{i}.label(j));
            fprintf(fd_train_pad, '%s %d\n', imgPadlist{j}, clothing_attributes_after_parsing{i}.label(j));
        else
            fprintf(fd_test, '%s %d\n', imglist{j}, clothing_attributes_after_parsing{i}.label(j));
            fprintf(fd_test_pad, '%s %d\n', imgPadlist{j}, clothing_attributes_after_parsing{i}.label(j));
        end
    end
    
    for j=1:length(clothing_attributes_after_parsing{i}.names)
        fprintf(fd_name, '%s %d\n', ...
            clothing_attributes_after_parsing{i}.names{j}, ...
            sum(clothing_attributes_after_parsing{i}.label==j-1));
    end
    fclose(fd_train);
    fclose(fd_test);
    fclose(fd_train_pad);
    fclose(fd_test_pad);
    fclose(fd_name);
    % cahist = histc(ca.label, 1:nvalue);
    
end
