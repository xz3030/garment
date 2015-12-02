%function generate_image_to_sku
% for 30w dataset, generate the respective image to SKU results.

config;

%% im2sku
if exist(im_sku_map_file,'file') && canSkip
    load(im_sku_map_file);
else
    imglist = textread(imglistFile,'%s');
    Nim = length(imglist);

    skulist1 = cell(1, Nim);
    for i = 1:Nim
        %if mod(i,10000)==0, fprintf('%d/%d\n', i, Nim); end
        G = regexp(imglist{i}(30:end), '_', 'split');
        skulist1{i} = [G{1} '_' G{2}];
    end

    [skulist, m, n] = unique(skulist1);
    im2sku = n;
    sku2im = cell(size(skulist));
    for j=1:length(sku2im)
        sku2im{j} = find(n==j);
    end

    save(im_sku_map_file, 'imglist', 'skulist', 'im2sku', 'sku2im');
end

%% random seed
if exist(ttsplitFile, 'file') && canSkip
    disp('Train test split already exists!');
else
    ratioTest = 0.2;              % ratio of train/test split

    Nsku = length(skulist);
    Nim = length(imglist);
    P = randperm(Nsku);
    train_test_split = ones(1, Nim);
    ntest = floor(Nsku*ratioTest);     % 20% testing
    for i=1:ntest
        train_test_split(im2sku==P(i)) = 0;
    end
    save(ttsplitFile, 'train_test_split');
end


%end


