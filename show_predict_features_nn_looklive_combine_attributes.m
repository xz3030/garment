%function show_predict_features_nn_looklive_combine_attributes
% based on the CNN trained on each attribute, extract the 1024-d feature
% vector, and compute nearest neighbours based on the feature
%
% run after view_features.py

%{=
attrDir = '/DB/rhome/zxu/workspace/cloth/attributes_gt_sku_no_ssd/all_query';

testFile = fullfile(attrDir, 'test.txt');
[files, labels] = textread(testFile, '%s %d');
trainFile = fullfile(attrDir, 'train.txt');
[trainFiles, trainLabels] = textread(trainFile, '%s %d');

[fts, fts_train] = load_features(fullfile(attrDir, 'xiong'), files, trainFiles);
[fts_color, fts_train_color] = load_features(fullfile(attrDir, 'color'), files, trainFiles);
[fts_category, fts_train_category] = load_features(fullfile(attrDir, 'category'), files, trainFiles);

nim = size(fts,1);
ntarget = length(trainFiles);

D = pdist2(fts, fts_train, 'cosine');
Dcolor = pdist2(fts_color, fts_train_color, 'cosine');
Dcategory = pdist2(fts_category, fts_train_category, 'cosine');

queryids = zeros(1,length(files));
for i=1:length(files)
    queryname = files{i};
    [~,queryname,~] = fileparts(queryname);
    G = regexp(queryname, '-', 'split');
    queryid = str2double(G{1});
    queryids(i) = queryid;
end

targetids = cell(1,length(trainFiles));
for i=1:length(trainFiles)
    targetname = trainFiles{i};
    [~,targetname,~] = fileparts(targetname);
    G = regexp(targetname, '-', 'split');
    targetid = str2double(G{1});
    if isnan(targetid)
        G = regexp(G{1}, '_', 'split');
        targetid = arrayfun(@(i)str2double(G{i}),1:length(G));
        targetids{i} = targetid;
    else
        targetids{i} = targetid;
    end
    
end
%}



%% compute top-20 accuracy

%colorthresh = 200:100:600;
%catethresh = 800:200:2000;
%thress = zeros(length(colorthresh)*length(catethresh), 2);
colorthresh = 300;
catethresh = 1800;
accs = [];
tmpind = 1;


for tcolor = colorthresh
for tcategory = catethresh

iscorrect = zeros(1,nim);
queryindex = zeros(1,nim);
for query=1:nim
    %if mod(query,100)==0
    %    fprintf('Current accuracy at image %d is %.2f\n', query, mean(iscorrect(1:query)));
    %end
    
    queryD = D(query,:);
    queryDcolor = Dcolor(query,:);
    queryDcategory = Dcategory(query,:);
    
    [~,ordcolor] = sort(queryDcolor, 'ascend');
    [~,ordcategory] = sort(queryDcategory, 'ascend');
    
    maskcolor = false(1,ntarget);
    maskcolor(ordcolor(1:tcolor)) = 1;
    
    maskcategory = false(1,ntarget);
    maskcategory(ordcategory(1:tcategory)) = 1;
    
    maskf = find(maskcolor & maskcategory);
    
    queryD_filtered = queryD(maskf);
    [~,ord] = sort(queryD_filtered, 'ascend');
    ord = maskf(ord);
    tmptargetids = targetids(ord);
    
    index = 9999;
    queryid = queryids(query);
    for i = 1:length(tmptargetids)
        if sum(queryid == tmptargetids{i})>0
            index = i;
            break;
        end
    end
    queryindex(query)=index;
    if index<=20
        iscorrect(query)=1;
    end
end


fprintf('Thresh color %d, category %d: %.4f\n', tcolor, tcategory, mean(iscorrect));
accs = [accs mean(iscorrect)];

thress(tmpind,:) = [tcolor, tcategory];
tmpind = tmpind+1;

end
end

[maxaccs, maxind]=max(accs);
fprintf('Max accuracy is %.2f%% at rank color<%d, rate rank<%d\n', ...
    maxaccs*100, thress(maxind,1), thress(maxind,2));
%}
%% visualize
colorGreen = reshape([0 255 0], [1 1 3]);
P = randperm(nim);

for i=1:nim
    query = P(i);
    queryid = queryids(query);
    queryD = D(query,:);
    queryDcolor = Dcolor(query,:);
    queryDcategory = Dcategory(query,:);
    
    [~,ordcolor] = sort(queryDcolor, 'ascend');
    maskcolor = false(1,ntarget);
    maskcolor(ordcolor(1:tcolor)) = 1;
    
    [~,ordcategory] = sort(queryDcategory, 'ascend');
    maskcategory = false(1,ntarget);
    maskcategory(ordcategory(1:tcategory)) = 1;
    
    maskf = find(maskcolor & maskcategory);
    
    queryD_filtered = queryD(maskf);
    [~,ord] = sort(queryD_filtered, 'ascend');
    ord = maskf(ord);
    tmptargetids = targetids(ord);
    
    ord = [-1 ord];
    %ord = [-1 index ord];
    

    Ngrid = 5;
    bigI = zeros(100*Ngrid, 100*Ngrid, 3);
    for m=1:Ngrid
        for n=1:Ngrid
            testimid = ord((m-1)*Ngrid+n);
            if testimid==-1
                im = imread(files{query});
            else
                im = imread(trainFiles{testimid});
            end
            im = imresize(im,[100 100]);
            
           % if testimid>0 && sum(targetids{testimid}==queryid)>0
            if testimid>0 && sum(targetids{testimid}==queryid)>0
                im([1:10 91:100], :, :) = repmat(colorGreen, [20, 100, 1]);
                im(:, [1:10 91:100], :) = repmat(colorGreen, [100, 20, 1]);
            end
            
            bigI( (m-1)*100+1:m*100, (n-1)*100+1:n*100, : ) = im;
        end
    end
    
    figure(1), imshow(bigI/256, []);
    keyboard;
end
%end


% function [fts, fts_train] = load_features(attrDir, files, trainFiles)
% fts = load(fullfile(attrDir, 'predict_features.txt'));
% fts = fts(1:min(size(fts,1), length(files)), :);
% fts_train = load(fullfile(attrDir, 'predict_features_train.txt'));
% fts_train = fts_train(1:min(size(fts_train,1), length(trainFiles)), :);
% 
% end