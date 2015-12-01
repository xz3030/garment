function [batches, batch_padding] = extract_regions(imlist, batch_size, crop_mode)
% [batches, batch_padding] = rcnn_extract_regions(im, boxes, rcnn_model)
%   Extract image regions and preprocess them for use in Caffe.
%   Output is a cell array of batches.
%   Each batch is a 4-D tensor formatted for input into Caffe:
%     - BGR channel order
%     - single precision
%     - mean subtracted
%     - dimensions from fastest to slowest: width, height, channel, batch_index
%
%   im is an image in RGB order as returned by imread
%   boxes are in [x1 y1 x2 y2] format with one box per row

% constants definition

crop_size = 224;
image_mean = [104, 117, 123];  % bgr
crop_padding = 0;

nim = length(imlist);
num_batches = ceil(nim / batch_size);
batches = cell(num_batches, 1);

batch_padding = batch_size - mod(nim, batch_size);
if batch_padding == batch_size
    batch_padding = 0;
end

for batch = 1:num_batches
    tic
    batch_start = (batch-1)*batch_size+1;
    batch_end = min(nim, batch_start+batch_size-1);
    ims = zeros(crop_size, crop_size, 3, batch_size, 'single');
    
    for j = batch_start:batch_end
        % load image
        im = imread(imlist{j});
        bbox = [1 1 size(im,2) size(im,1)];
        % convert image to BGR and single
        if size(im,3)==1
            im = gray2rgb(im);
            im = im*256;
        end
%         im = single(im(:,:,[3 2 1]));
        %im = im(:,:,[3 2 1]);
        [crop] = im_crop(im, bbox, crop_mode, crop_size, ...
            crop_padding, image_mean);
        %crop = crop(:,:,[3 2 1]);
        crop = single(crop);
        
        % swap dims 1 and 2 to make width the fastest dimension (for caffe)
        ims(:,:,:,j-batch_start+1) = permute(crop, [2 1 3]);
        imwrite(uint8(ims(:,:,:,j-batch_start+1)), ['batch1-', num2str(j), '.jpg']);
    end
    
    batches{batch} = ims;
    fprintf('Batch %d/%d in %.4f seconds\n', batch, num_batches, toc);
    
end
