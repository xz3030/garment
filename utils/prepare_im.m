function [batches, nbatch] = prepare_im(imf)
config;
nim = length(imf);
nbatch = ceil(nim/batch_size);
for i=nim+1:nbatch*batch_size
    imf{i} = imf{1};
end

batches = cell(1, nbatch);

for i=1:nbatch
    tic
    batch = zeros(IMAGE_DIM, IMAGE_DIM, 3, batch_size, 'single');
    for j=1:batch_size
        imname = imf{(i-1)*batch_size+j};
        im_data = load_image_for_caffe(imname, IMAGE_DIM);
        batch(:,:,:,j) = im_data;
    end
    batches{i} = batch;
    fprintf('Prepare batch %d/%d in %.4f seconds\n', i, nbatch, toc);
end

end