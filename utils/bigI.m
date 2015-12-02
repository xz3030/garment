function bigI(imlist, nw, nh, w, h)
% show bigI
% input: imlist
% nw: # of width
% nh: # of height
% w: normalization width
% h: normalization height

I = zeros(h*nh, w*nw, 3);
for m=1:nh
    for n=1:nw
        testimid = (m-1)*nw+n;
        im = imread(imlist{testimid});
        im = imresize(im,[w h]);
        
        I( (m-1)*w+1:m*w, (n-1)*h+1:n*h, : ) = im;
    end
end
I = double(I)/256;
imshow(I);

end