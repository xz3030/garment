%function generate_image_to_sku
% for 30w dataset, generate the respective image to SKU results.

%% im2sku
if ~exist('cache/30w_im2sku.mat','file')
    imglist = textread('/DATA/data/ycxiong/cigit_taobao_data/30w/ansi/imglist.txt','%s');
    Nim = length(imglist);

    skulist1 = cell(1, Nim);
    for i = 1:Nim
        %if mod(i,10000)==0, fprintf('%d/%d\n', i, Nim); end
        G = regexp(imglist{i}(30:end), '_', 'split');
        skulist1{i} = [G{1} '_' G{2}];
    end

    [skulist, m, n] = unique(skulist1);
    im2sku = n;

    save('cache/30w_im2sku.mat', 'imglist', 'skulist', 'im2sku');
else
    load('cache/30w_im2sku.mat');
end

%% random seed
if ~exist('cache/train_test_split_sku.mat', 'file');
    ratioTest = 0.2;              % ratio of train/test split

    Nsku = length(skulist);
    Nim = length(imglist);
    P = randperm(Nsku);
    train_test_split = ones(1, Nim);
    ntest = floor(Nsku*ratioTest);     % 20% testing
    for i=1:ntest
        train_test_split(im2sku==P(i)) = 0;
    end
    save('cache/train_test_split_sku.mat', 'train_test_split');
end


%end


