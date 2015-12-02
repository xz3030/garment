%function show_and_write_entry_image_pool
% run after get_entry_query_image_pool.m
config;

isshow = 0;
iswrite = 1;

if ~exist('valid_skus', 'var')
    %% init, only need to run once
    load(query_sku_ims_map_file);
    load(im_sku_map_file);
    nim = length(imglist);
    imgPadlist = arrayfun(@(i)[imPadDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
end

if isshow
    %% show queries
    ncateg = size(valid_skus,1);
    ncolor = size(valid_skus,2);
    categid = ceil(rand()*ncateg);
    colorid = ceil(rand()*ncolor);
    
    % query struct
    query = valid_skus{categid, colorid};
    nim = length(query.ims);
    
    fprintf('Show images for %s and %s, together %d images\n', ...
        query.category, query.color, nim);
    
    ngrid = 8;
    batch_size = ngrid*ngrid;
    nbatch = nim/batch_size;
    
    % show images
    for i=1:nbatch
        I = bigI(imgPadlist(query.ims((i-1)*batch_size+1:i*batch_size)), ...
            ngrid, ngrid, 100, 100);
        imshow(I);
        keyboard;
    end
end

%% write files
if iswrite
    % write a file containing image names for each query
    ncateg = size(valid_skus,1);
    ncolor = size(valid_skus,2);
    
    for i=2:ncateg
        % for each category, find several attributes for computing
        % similarity
        valid_attrs = attr_cat_map(i,:);
        
        for j=1:ncolor
            % save query txt containing image names
            query = valid_skus{i, j};
            outDir = sprintf('%s/%s_%s', mentalQueryDir, query.category, query.color);
            mkdir_if_missing(outDir);
            
            imfilenames = imgPadlist(query.ims);
            nim = length(imfilenames);
            
            %% write file
            outFile = fullfile(outDir, 'query.txt');
            fd = fopen(outFile, 'wt');
            for k=1:length(imfilenames)
                fprintf(fd, '%s 0\n', imfilenames{k});
            end
            fclose(fd);
            
            %% get feature
            % prepare image batch
            [batches, nbatch] = prepare_im(imfilenames);
            
            %% compute CNN features
            query_features = cell(1,length(valid_attrs));
            for att = 1:length(valid_attrs)
                tmpattr = valid_attrs(att);
                fprintf('Compute similarity using attribute %d\n', tmpattr);
                
                % define dirs
                net_weights = sprintf('%s/%d/train_pad_iter_30000.caffemodel', ...
                    mainDir, tmpattr);
                if ~exist(net_weights, 'file')
                    net_weights = sprintf('%s/%d/train_pad_iter_10000.caffemodel', ...
                        mainDir, tmpattr);
                    %assert(exist(net_weights, 'file'));
                end

                net_model = fullfile(mentalQueryDir, 'query_deploy.prototxt');
                phase = 'test'; % run with phase test (so that dropout isn't applied)

                % define caffenet
                caffe.set_mode_gpu();
                gpu_id = 2;  % we will use the first gpu in this demo
                caffe.set_device(gpu_id);

                % load net
                net = caffe.Net(net_model, net_weights, phase);

                % get feature
                features = zeros(nim, 1024);
                for k=1:nbatch
                    f = net.forward(batches(k));
                    f = reshape(f{3}, 1024, batch_size);
                    f = f';
                    st = (k-1)*batch_size+1;
                    ed = min(k*batch_size, nim);
                    features(st:ed, :) = f(1:ed-st+1, :);
                end

                caffe.reset_all();

                % compute similarity
                D = pdist(features, distance_function);
                D = squareform(D);


                %% show if valid
                if isshow
                    while 1
                        P = ceil(rand()*nim);
                        [~,ord] = sort(D1(P,:));
                        bigI(imfilenames(ord), 5, 5, 100, 100);
                        keyboard;
                    end
                end
                
                % output structure
                qf = struct;
                qf.attrid = tmpattr;
                qf.categoryid = i;
                qf.colorid = j;
                qf.features = features;
                qf.similarity = ones(size(D))-D;
                query_features{att} = qf;
            end
            
            save(fullfile(outDir, 'CNNfeatures.mat'), 'query_features');
        end
    end
    
end

%end


