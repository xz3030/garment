function add_padding_to_30w_data
% add padding to 30w data, resize image to w x 256, and add padding to
% left/right or crop out
% the resulting files are in size 256x256, stored in local ssd disks.
% currently run in db14

srcDir = '/DATA/data/ycxiong/cigit_taobao_data/30w';
imlistFile = fullfile(srcDir, 'ansi/imglist.txt');
imglist = textread(imlistFile,'%s');

srcImDir = '/DATA/data/ycxiong/cigit_taobao_data/30w/attribute_cut/';
tgtImDir = '/win_D/cigit_taobao_data/30w/attribute_cut/';
%tgt_pad_ImDir = '/win_D/cigit_taobao_data/30w/attribute_cut_plus_padding/';
tgt_pad_ImDir = '/DATA/data/zxu/cigit_taobao_data/30w/attribute_cut_plus_padding/';

mkdir_if_missing(tgtImDir);
mkdir_if_missing(tgt_pad_ImDir);

nim = length(imglist);

srcImglist = arrayfun(@(i)[srcImDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
tgtImglist = arrayfun(@(i)[tgtImDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
tgtPadImglist = arrayfun(@(i)[tgt_pad_ImDir imglist{i}(30:end)], 1:nim, 'UniformOutput', false);
tic;

for i=1:nim
    if mod(i,1000)==0
        fprintf('%d/%d in %.4f seconds\n', i, nim, toc);
        tic;
    end
    imname = srcImglist{i};
    [im, pad_im] = crop_pad_image(imname);
    % imwrite(im, tgtImglist{i});
    imwrite(pad_im, tgtPadImglist{i});
end

end



function [im, pad_im] = crop_pad_image(imname)
    im = imread(imname);
    [pad_im, l_pad, r_pad] = crop_and_resize_for_30w(im);
    
    image_mean = [119.6200, 120.8229, 104.2657];
    image_mean = image_mean([3 2 1]);
    
    if l_pad > 0
        l_im = zeros(256, l_pad+size(pad_im,2),3);
        l_im(:,:,1) = [image_mean(1)*ones(256,l_pad) pad_im(:,:,1)];
        l_im(:,:,2) = [image_mean(2)*ones(256,l_pad) pad_im(:,:,2)];
        l_im(:,:,3) = [image_mean(3)*ones(256,l_pad) pad_im(:,:,3)];
        pad_im = l_im;
    end
    
    if r_pad > 0
        r_im = zeros(256, r_pad+size(pad_im,2),3);
        r_im(:,:,1) = [pad_im(:,:,1) image_mean(1)*ones(256,r_pad)];
        r_im(:,:,2) = [pad_im(:,:,2) image_mean(2)*ones(256,r_pad)];
        r_im(:,:,3) = [pad_im(:,:,3) image_mean(3)*ones(256,r_pad)];
        pad_im = r_im;
    end
    
    pad_im = double(pad_im)/255;
end



function [re_im, l_pad, r_pad] = crop_and_resize_for_30w(im)
    l_pad = 0;
    r_pad = 0;

    im_height = size(im, 1);
    im_width = size(im, 2);
    ratio = im_width / im_height;
   
    re_height = 256;                                 
    re_width = round(re_height * ratio);
            
    im = imresize(im, [re_height re_width]);
    
    if re_width > 256
        left = round((re_width - 256) / 2);
        right = re_width - 256 - left;
        re_im = im(:,left+1:re_width-right,:);
    elseif re_width < 256
        l_pad = round((256 - re_width) / 2);
        r_pad = 256 - re_width - l_pad;
        
        re_im = im;
    else
        re_im = im;
    end
end
