function show_predict_features_nn(attrID, phase)
% based on the CNN trained on each attribute, extract the 1024-d feature
% vector, and compute nearest neighbours based on the feature
%
% run after view_features.py

if nargin<1
    attrID = 1;
end

if nargin<2
    phase = 'train';
end

config;

%attDir = '/DB/rhome/zxu/workspace/cloth/attributes_gt_sku_no_ssd';
attDir = mainDir;
tmp = dir(attDir);
tmp = tmp(3:end);

tmpname = {};
for j=1:length(tmp)
    tmpname{j} = tmp(j).name;
end
[tmpname,ndx] = natsortfiles(tmpname);
tmp = tmp(ndx);

attr = tmp(attrID).name;
attrDir = fullfile(attDir, attr);

fts = load(fullfile(attrDir, 'predict_features.txt'));

testFile = fullfile(attrDir, 'pad_test.txt');
[files, labels] = textread(testFile, '%s %d');

fts = fts(1:min(size(fts,1), length(files)), :);

nim = size(fts,1);

if strcmp(phase,'train')
    if strcmp(attr,'all')
        trainFile = fullfile(attrDir, 'pad_train_shuffle.txt');
    else
        trainFile = fullfile(attrDir, 'pad_train.txt');
    end
    [trainFiles, trainLabels] = textread(trainFile, '%s %d');
    fts_train = load(fullfile(attrDir, 'predict_features_train.txt'));
    fts_train = fts_train(1:min(size(fts_train,1), length(trainFiles)), :);
end

P = randperm(nim);

for i=1:nim
    query = P(i);
    if strcmp(phase, 'train');
        D = pdist2(fts(query,:), fts_train, 'cosine');
        [~,ord] = sort(D, 'ascend');
        ord = [-1 ord];
    else
        D = pdist2(fts(query,:), fts, 'cosine');
        [~,ord] = sort(D, 'ascend');
    end
    

    Ngrid = 5;
    bigI = zeros(100*Ngrid, 100*Ngrid, 3);
    for m=1:Ngrid
        for n=1:Ngrid
            testimid = ord((m-1)*Ngrid+n);
            if strcmp(phase, 'train')
                if testimid==-1
                    im = imread(files{query});
                else
                    im = imread(trainFiles{testimid});
                end
            else
                im = imread(files{testimid});
            end
            im = imresize(im,[100 100]);
            
            bigI( (m-1)*100+1:m*100, (n-1)*100+1:n*100, : ) = im;
        end
    end
    figure(1), imshow(bigI/256, []);
    keyboard;
end
end