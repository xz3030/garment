function get_entry_query_image_pool(clothing_attributes, sku2im)
% given a query input, find the respective SKUs (one image for each) as the
% input of mental image retrieval
% query: a pair (category, color)
% category: 5 huge categories:  {shirts, outerwears, pants, skirts}
% color:    
config;
% load('cache/clothing_attributes.mat');
% load('cache/30w_im2sku.mat');

if exist(query_filter_file, 'file') && canSkip
    load(query_filter_file);
else
    %% define big categories and big color classes
    config;
    
    print_check_correct(clothing_attributes, 1, BIG_categories, categ_map, 'category');
    print_check_correct(clothing_attributes, 22, BIG_colors, color_map, 'color');

    %% stats
    [cat_iminds, cat_skuinds] = get_stats(clothing_attributes, ...
        1, BIG_categories, categ_map, 'category', sku2im);
    [color_iminds, color_skuinds] = get_stats(clothing_attributes, ...
        22, BIG_colors, color_map, 'color', sku2im);

    %% output
    category_filter = struct;
    category_filter.names = BIG_categories;
    category_filter.map = categ_map;
    category_filter.iminds = cat_iminds;
    category_filter.skuinds = cat_skuinds;
    category_filter.nvalues = length(BIG_categories);

    color_filter = struct;
    color_filter.names = BIG_colors;
    color_filter.map = color_map;
    color_filter.iminds = color_iminds;
    color_filter.skuinds = color_skuinds;
    color_filter.nvalues = length(BIG_colors);

    save(query_filter_file, 'category_filter', 'color_filter');
end

%% find combined query pair
% ncat(4) x ncolor(9)
% each: a struct contains sku ids, respective imids, and the randomly 
% selected imid
if exist(query_sku_ims_map_file, 'file') && canSkip
    disp('Result file already exists!');
else

    valid_skus = cell(category_filter.nvalues, color_filter.nvalues);

    for i=1:category_filter.nvalues
        % category: valid image indices, sku indices
        cat_iminds = category_filter.iminds{i};
        cat_skuinds = category_filter.skuinds{i};
        for j=1:color_filter.nvalues
            % output struct
            tmpvs = struct;
            tmpvs.category = category_filter.names{i};
            tmpvs.color = color_filter.names{j};
            tmpvs.category_id = i;
            tmpvs.color_id = j;

            % color: valid image indices, sku indices
            color_iminds = color_filter.iminds{j};
            color_skuinds = color_filter.skuinds{j};

            % an intersection of color and category
            valid_sku = intersect(cat_skuinds, color_skuinds);
            all_ims = intersect(cat_iminds, color_iminds);

            % for each valid sku, find its valid image indices
            valid_ims = cell(size(valid_sku));
            selected_ims = zeros(size(valid_sku));
            for k=1:length(valid_sku)
                vsku = valid_sku(k);
                tmpims = sku2im{vsku};
                valid_ims{k} = intersect(tmpims, all_ims);
                nvim = length(valid_ims{k});
                
                if nvim>0
                    selected_ims(k) = valid_ims{k}(ceil(rand()*nvim));
                else
                    % case: a sku has more than 1 categories, and more than 1
                    % colors, say category 1,2 and color 1,2; we want
                    % category 1 and color 1. all images in category 1 has
                    % color 2, but there are still some images in category
                    % 2 with color 1, then our filtering method may fail.
                    % so add this -1 to measure this scenario.
                    selected_ims(k) = -1;
                end
                
            end
            
            filter = selected_ims>=0;

            tmpvs.sku = valid_sku(filter);
            tmpvs.imslist = valid_ims(filter);
            tmpvs.ims = selected_ims(filter);

            valid_skus{i,j} = tmpvs;

            fprintf('# %d for category %s and color %s\n', length(tmpvs.sku), ...
                category_filter.names{i}, color_filter.names{j});
        end
    end
    
    save(query_sku_ims_map_file, 'valid_skus');
end

end


function print_check_correct(clothing_attributes, attrid, bignames, map, name)
% check if the big classes are correctly defined
fprintf('Check correctness for attribute %s:\n', name);
for i=1:length(map)
    fprintf('%d %s: %s\n', i, clothing_attributes{attrid}.names{i}, ...
        bignames{map(i)});
end
fprintf('\n\n');

end


function [iminds, skuinds] = get_stats(clothing_attributes, ...
    attrid, bignames, map, name, sku2im)
fprintf('Get statistics for attribute %s\n', name);
nvalue = length(bignames);
nim = length(clothing_attributes{attrid}.label);
nsku = length(sku2im);


iminds = cell(nvalue, 1);
skuinds = cell(nvalue, 1);

for i=1:nvalue
    small_ind = find(map==i);
    iminds{i} = zeros(nim, 1); 
    skuinds{i} = zeros(nsku, 1);
    for j=1:length(small_ind)
        % index of images with this attribute
        imind = clothing_attributes{attrid}.label==small_ind(j);  
        % in each sku, the number of images that contains this attribute
        sku_valid_im_num = arrayfun(@(i)sum(imind(sku2im{i})), ...
            1:length(sku2im)); 
        skuind = sku_valid_im_num>0;
        iminds{i} = iminds{i} + imind;
        skuinds{i} = skuinds{i} + skuind';
    end
    iminds{i} = find(iminds{i});
    skuinds{i} = find(skuinds{i});
    fprintf('%-10s: %d images, %d skus\n', bignames{i}, ...
        length(iminds{i}), length(skuinds{i}));
    
end
fprintf('\n\n');


end
