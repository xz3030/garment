function img_struct = dir_img(img_dir_path)
%DIR_IMG List images in img_dir_path, such as .jpg, .png
%   
%   Copyright Yichao Xiong 2015.09.27

jpgs = dir(fullfile(img_dir_path, '*.jpg'));
pngs = dir(fullfile(img_dir_path, '*.png'));
img_struct = [jpgs; pngs];

end

