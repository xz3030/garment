function show_predict_attribute_results(attrID, phase, debug_mode)
% show results predicted by CNN, run this file after running view_results.py
% in each subdirectory
% attrid: ID of attribute category, start from 1 to 28.
% phase: 'test' or 'train'
% debug_mode: true or false

if nargin<1
    attrID = 1;
end

if nargin<2
    phase = 'test';
end

if nargin<3
    debug_mode = false;
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
%{
[~, attributes] = textread('/DB/rhome/zxu/Datasets/CUB_200_2011/attributes/attributes.txt','%d %s');
nvaluePerAttr = [9, 15, 15, 15, 4, 15, 6, 15, 11, 15, 15, 14, ...
    3, 15, 15, 15, 15, 5, 5, 14, 4, 4, 4, 15, 15, 15, 15, 4];
csVal = cumsum([1 nvaluePerAttr]);
attrCatList = attributes(csVal(attrID):csVal(attrID+1));
%}
attrDir = fullfile(attDir, attr);
fd = fopen(fullfile(attrDir, 'names.txt'), 'r', 'n', 'UTF8');
attrCatList = {};
while ~feof(fd)
    l = fgetl(fd);
    attrCatList = cat(2, attrCatList, l);
end
fclose(fd);


%% load results
if ~exist(fullfile(attrDir, 'predict_results.txt'), 'file')
    cmd = sprintf('cp %s %s', fullfile('attribute_gts','view_results.py'),...
        fullfile(attrDir, 'view_results.py'));
    system(cmd);
    oridir = pwd;
    cd(attrDir)
    cmd = 'python view_results.py';
    system(cmd);
    cd(oridir);
end

if strcmp(phase, 'train')
    %pds = load(fullfile(attrDir, 'predict_results_train.txt'));
    pds = load(fullfile(attrDir, 'predict_results_train.txt'));
    testFile = fullfile(attrDir, 'pad_train.txt');
else
    pds = load(fullfile(attrDir, 'predict_results.txt'));
    testFile = fullfile(attrDir, 'pad_test.txt');
end
[files, labels] = textread(testFile, '%s %d');

ntest = length(labels);
pds = pds(1:ntest);

cfmat = confusionmat(pds, labels);
%cfmat = cfmat./repmat(sum(cfmat),size(cfmat,1),1);
cfmat = cfmat./repmat(sum(cfmat,2),1,size(cfmat,2));
show_cfmat(cfmat, attrCatList);

acc = sum(pds == labels)/ntest

%% show results
colorRed = reshape([255 0 0], [1 1 3]);
ll = unique(labels);
for k=1:length(ll)
    fprintf('Predict label: %s: %s\n', attr, attrCatList{ll(k)+1});
    ind = find(pds==ll(k));
    N = length(ind);
    P = randperm(N);
    %P = 1:N;
    
    Ngrid = min(10, floor(sqrt(N)));
    bigI = zeros(100*Ngrid, 100*Ngrid, 3);
    for m=1:Ngrid
        for n=1:Ngrid
            index = P((m-1)*Ngrid+n);
            testimid = ind(index);
            im = imread(files{testimid});
            im = imresize(im,[100 100]);
            
            if labels(testimid)~=ll(k)
                % incorrect prediction
                im([1:10 91:100], :, :) = repmat(colorRed, [20, 100, 1]);
                im(:, [1:10 91:100], :) = repmat(colorRed, [100, 20, 1]);
                
                if debug_mode
                    fprintf('Actual label: %s\n', attrCatList{labels(testimid)+1});
                    %testimattr = res(res(:,1)==3531, 2);
                    %for j=1:length(testimattr) 
                    %    if testimattr(j)>9 && testimattr(j)<24
                    %        fprintf('%s\n', attributes{testimattr(j)});
                    %    end
                    %end
                    figure(2), imshow(im,[]);
                    keyboard;
                end
            end
            
            
            bigI( (m-1)*100+1:m*100, (n-1)*100+1:n*100, : ) = im;
        end
    end
    figure(1), imshow(bigI/256, []);
    keyboard;
end

end


function show_cfmat(mat, names)
figure(2),imagesc(mat);            %# Create a colored plot of the matrix values

%{

colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

textStrings = num2str(mat(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding

%% ## New code: ###

idx = find(strcmp(textStrings(:), '0.00'));
textStrings(idx) = {'   '};
%% ################


[x,y] = meshgrid(1:5);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(mat(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors


set(gca,'XTick',1:length(names),...                         %# Change the axes tick marks
        'XTickLabel',{names},...  %#   and tick labels
        'YTick',1:length(names),...
        'YTickLabel',{names},...
        'TickLength',[0 0]);

%}

for j=1:length(names)
    fprintf('%d: %s\n', j, names{j});
end
end