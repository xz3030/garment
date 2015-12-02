% configuration file
%% dirs
imDir = '/DATA/data/ycxiong/cigit_taobao_data/30w/attribute_cut/';
%imPadDir = '/win_D/cigit_taobao_data/30w/attribute_cut_plus_padding/';
imPadDir = '/DATA/data/zxu/cigit_taobao_data/30w/attribute_cut_plus_padding/';

attrDir = '/DATA/data/ycxiong/cigit_taobao_data/30w/ansi';
%mainDir = 'attributes_gt_sku_no_ssd';    % main dir
mainDir = 'backup/attributes_gt_sku_no_ssd';    % backup main dir
mentalQueryDir = 'mental_query';

%% files
imglistFile = '/DATA/data/ycxiong/cigit_taobao_data/30w/ansi/imglist.txt';
ttsplitFile = 'cache/train_test_split_sku.mat';
clothing_attributes_file = 'cache/clothing_attributes.mat';
clothing_attributes_after_parsing_file = 'cache/clothing_attributes_after_parsing.mat';
im_sku_map_file = 'cache/30w_im2sku.mat';
query_filter_file = 'cache/query_filter.mat';
query_sku_ims_map_file = 'cache/query_sku_ims_map.mat';

%% parameters
canSkip = 1;
IMAGE_DIM = 224;
image_mean = single([104, 117, 123]);
batch_size = 64;
distance_function = 'cosine';

%% 4 big categories
BIG_categories = {'shirts', 'outerwears', 'pants', 'skirts'};
% map between small categories to big categories
categ_map = [3, 1, 1, 4, 3, 3, 4, 3, 4, 2, 1, 2, 4, ...
    2, 2, 1, 2, 2, 2, 1, 3, 2, 2, 1, 3, 4];
% for each big category, find a set of attributes to compute similarity on
% shirts: 00.category, 21.color, 02.collar_shape, 03.sleeve_shape, 05.pattern
% outerwears: 00.category, 21.color, 01.style, 06.button_shape, 10.season
% pants: 00.category, 21.color, 19.pants_length, 20.pants_shape, 11.shape
% skirts: 00.category, 21.color, 13.skirt_length, 14.skirt_shape, 15.waist_shape
attr_cat_map = ...
    [[1, 3, 4, 6, 22]; ...
    [1, 2, 7, 11, 22];...
    [1, 12, 20, 21, 22];...
    [1, 14, 15, 16, 22]];

%% 9 big color classes
BIG_colors = {'light', 'dark', 'red', 'yellow', 'green', ...
    'blue', 'purple', 'brown', 'other'};
% map between small color classes to big classes
color_map = [2, 1, 9, 3, 4, 7, 8, 2, 1, 3, 6, 6, 4, 5, ...
    5, 3, 9, 8, 4, 7, 7, 6, 8, 5, 9];
