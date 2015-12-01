% write attribute files, multi-label, train/test by sku level, in /DATA.
% come after read_attributes.m
%{=
%% attribute related dirs and paths and parameters
mainDir = 'attributes_gt_sku_no_ssd';    % main dir
ratioTest = 0.2;              % ratio of train/test split
ratioDiscard = 1/200;         % ratio of discarding an attribute after removing nans


%% train test split
nim = length(clothing_attributes{1}.label);
train_test_split_file = fullfile(mainDir, 'train_test_split.mat');


load('cache/train_test_split_sku.mat');

%% imglist
imDir = '/DATA/data/ycxiong/cigit_taobao_data/30w/attribute_cut/';
imPadDir = '/DATA/data/zxu/cigit_taobao_data/30w/attribute_cut_plus_padding/';
imglist = textread('/DATA/data/ycxiong/cigit_taobao_data/30w/ansi/imglist.txt','%s');
imgPadlist = arrayfun(@(i)[imPadDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
imglist = arrayfun(@(i)[imDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);

%}
%% parse attributes
clothing_attributes_after_parsing = clothing_attributes;
nattr = length(clothing_attributes);
ntrain = sum(train_test_split);
ntest = sum(~train_test_split);

train_attrs = zeros(ntrain, nattr);
test_attrs = zeros(ntest, nattr);

for i=1:length(clothing_attributes)
    fprintf('Attribute %d\n', i);
    ca = clothing_attributes{i};
    nvalue = length(ca.names);
    
    trainIdx = 1;
    testIdx = 1;
    
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
    
    for j=1:nim
        tmplabel = clothing_attributes_after_parsing{i}.label(j)+1;
        if train_test_split(j)==1
            train_attrs(trainIdx,i) = tmplabel;
            trainIdx = trainIdx+1;
        else
            test_attrs(testIdx, i) = tmplabel;
            testIdx = testIdx+1;
        end
    end
end
    % cahist = histc(ca.label, 1:nvalue);
    
% define train and test file, with dummy output label
attrDir = fullfile(mainDir, 'all');
mkdir_if_missing(attrDir);

save(fullfile(attrDir, 'all_attrs.mat'),...
    'train_attrs','test_attrs');

trainFile = fullfile(attrDir, 'train.txt');
testFile = fullfile(attrDir, 'test.txt');
trainPadFile = fullfile(attrDir, 'pad_train.txt');
testPadFile = fullfile(attrDir, 'pad_test.txt');

fd_train = fopen(trainFile, 'wt');
fd_test = fopen(testFile, 'wt');
fd_train_pad = fopen(trainPadFile, 'wt');
fd_test_pad = fopen(testPadFile, 'wt');

trainList = imglist(find(train_test_split));
testList = imglist(find(~train_test_split));
trainPadList = imgPadlist(find(train_test_split));
testPadList = imgPadlist(find(~train_test_split));

for j=1:ntrain
    fprintf(fd_train, '%s 0\n', trainList{j});
    fprintf(fd_train_pad, '%s 0\n', trainPadList{j});
end

for j=1:ntest
    fprintf(fd_test, '%s 0\n', testList{j});
    fprintf(fd_test_pad, '%s 0\n', testPadList{j});
end

fclose(fd_train);
fclose(fd_test);
fclose(fd_train_pad);
fclose(fd_test_pad);


%end