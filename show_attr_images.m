function show_attr_images(imlist)
% test case1:  gao ling
%  dd = 'imglist.txt';
%  imlist = textread(dd,'%s');
%  load('clothing_attributes.mat');
%  ll = imlist(clothing_attributes{3}.label==3);
%  show_attr_images(ll);
%
% test case2: baizhe qun
%  ll = imlist(clothing_attributes{15}.label==4);
%  show_attr_images(ll);
 

%dd = 'imglist.txt';
%imlist = textread(dd,'%s');
Nim = length(imlist);
Nrow = 5;
batch_size = Nrow*Nrow;
nbatch = ceil(Nim/batch_size);
P = randperm(Nim);

for i=1:nbatch
    ims = imlist(P((i-1)*batch_size+1:i*batch_size));
    figure(1),
    for p=1:Nrow
        for q=1:Nrow
            ind = (p-1)*Nrow+q;
            subplot(Nrow, Nrow, ind),
            imname = ims{ind};
            G = regexp(imname, '\', 'split');
            imname = ['/DATA/data/ycxiong/cigit_taobao_data/30w/attribute_cut/' G{end}];
            imshow(imread(imname));
        end
    end
    keyboard;
end
end