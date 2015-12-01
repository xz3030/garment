function generateImgList(img_dir_path)
%generate img_list.txt in the current directory path and img_list.txt in 
%   current directory/add_padding path
%   this function only check images of .jpg type
if ~exist(img_dir_path, 'dir')
    error('%s does not exist', img_dir_path);
end

if img_dir_path(1) ~= '/'
    img_dir_path = fullfile(pwd, img_dir_path);
end

img_list_name = 'img_list.txt';
img_list_path = fullfile(img_dir_path, img_list_name);

imgs = dir_img(img_dir_path);

img_num = length(imgs);
img_id = -1*ones(1,img_num);

for ii=1:img_num
   [~, tmp_img_id, ~] = fileparts(imgs(ii).name);
   img_id(ii) = str2double(tmp_img_id);
end

[~, img_id_index] = sort(img_id);

f_img_list = fopen(img_list_path, 'w');

for ii=1:img_num
   fprintf(f_img_list, '%s\n', fullfile(img_dir_path, imgs(img_id_index(ii)).name)); 
end

fclose(f_img_list);

end