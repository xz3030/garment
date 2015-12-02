function im_data = load_image_for_caffe(imname, IMAGE_DIM)
config;

im = imread(imname);
im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
im_data = permute(im_data, [2, 1, 3]);  % flip width and height
im_data = single(im_data);  % convert from uint8 to single
im_data = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
image_mean = image_mean([3,2,1]);
mean_data = repmat(reshape(image_mean, [1,1,3]), [IMAGE_DIM IMAGE_DIM 1]);
im_data = im_data - mean_data;  % subtract mean_data (already in W x H x C, BGR)

end