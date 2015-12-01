function savepath = addPadding(img_dir)
%ADDPADDING add padding to images
%   addPadding(img_dir)
%
%   Copyright 2015.09.26 Yichao Xiong

dstsize=224;%256;% size for resize
generateImgList(img_dir);
img_list_path = fullfile(img_dir, 'img_list.txt');%'/home/xiongyichao/test/query2/query.txt';%image list for padding
savepath = fullfile(img_dir, 'add_padding') ;%'/home/xiongyichao/test/query2/add_padding/';% saving path

safe_mkdir(savepath);

if exist(img_list_path, 'file') ~= 2
    error('There is no img_list.txt file under the %s\n', img_dir);
end

fid = fopen(img_list_path, 'r');
imagelist = textscan(fid,'%s');
fclose(fid);
imagelist = imagelist{1};

for i=1:length(imagelist) 
    img = imread(imagelist{i});
    black = zeros(dstsize,dstsize,3);
    if size(img,1)>=size(img,2)
        h=dstsize;
        w=floor(size(img,2)*h/size(img,1));
        img_resize = imresize(img,[h w]);
        %img_resize = imresize(img,[h w], 'bilinear', 'antialiasing', false);
        bpt = (dstsize-w)/2+1;
        black(:,bpt:bpt+w-1,:) = img_resize;
    else
        w=dstsize;
        h=floor(size(img,1)*w/size(img,2));
        img_resize = imresize(img,[h w]);
        bpt = (dstsize-h)/2+1;
        black(bpt:bpt+h-1,:,:) = img_resize;
    end
    black = uint8(black);
    imgname = regexp(imagelist{i},'/','split');
    name = fullfile(savepath, imgname{end});
    imwrite(black,name,'JPG');
    
    imwrite(img_resize, 'resize2.jpg');
    imwrite(black, 'crop2.jpg');
    %fprintf('%d/%d\n',i,length(imagelist));
end

end