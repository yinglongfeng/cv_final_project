

warning('off','stats:kmeans:EmptyCluster')
warning('off','stats:kmeans:FailedToConverge')
warning('off','stats:kmeans:MissingDataRemoved');

% parameters
interp = 0.2;   % interpolation factor

% read in images and disparity maps
i1 = imread('view1.png');           % left view
i2 = imread('view5.png');           % right view
% i1 = imresize(i1,[800 600/3]);
% i2 = imresize(i2,[342 1368./3]);
[m1 n1] = size(i1)
[m2 n2] = size(i2)

% d1 = imread('disp1.png');
% d2 = imread('disp5.png');
disp1 = load('disp1.mat');
disp5 = load('disp5.mat');
d1 = disp1.DbasicSubpixel;
d2 = disp5.DbasicSubpixel;
d1 = wiener2(d1,[15 15]);
d2 = wiener2(d2,[15 15]);

d1 = wiener2(d1,[5 5]);
d2 = wiener2(d2,[5 5]);

% output = meanfilter(d1, 1);  % 半径为1，即取3*3的图像块
% d1 = imresize(d1,[800 600]);
% d2 = imresize(d2,[800 600]);

% d1 = rgb2gray(d1);
% d2 = rgb2gray(d2);
[m11 n11] = size(d1)
[m22 n22] = size(d2)
% d1 = medfilt2(d1);
% d2 = medfilt2(d2);
% output=filter2(fspecial('average',5),d1)/255;  
% figure
% imshow(output)
% figure
% imshow(d1)
% figure
% imshow(d2)
% d1 = double(d1);   % left disparity map, 0-255
% d2 = double(d2);   % right disparity map, 0-255

% tag bad depth values with NaNs
d1(d1==0) = nan;
d2(d2==0) = nan;

% synthesize new image and disparity map
[out dmap rmap] = genIntView(interp,i1,i2,d1,d2);   % generate view
[outr dmapr] = refineView(rmap,out,dmap);           % refine it
dmap_final = fillDMap(dmapr);                       % fill disparity map
img = fillRegion(outr,dmap_final);                  % fill color image
img_final = refineHoleBorders(img,outr);            % refine it
% 
% plot
figure
imshow(img_final)
title('Synthesized image')
figure
imshow(dmap_final)
title('Synthesized disparity map')
