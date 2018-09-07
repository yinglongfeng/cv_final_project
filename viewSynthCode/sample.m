

warning('off','stats:kmeans:EmptyCluster')
warning('off','stats:kmeans:FailedToConverge')
warning('off','stats:kmeans:MissingDataRemoved');

% parameters
interp = 0.5;   % interpolation factor

% read in images and disparity maps
i1 = imread('view1.png');           % left view
i2 = imread('view5.png');           % right view
d1 = double(imread('disp1.png'));   % left disparity map, 0-255
d2 = double(imread('disp5.png'));   % right disparity map, 0-255

% tag bad depth values with NaNs
d1(d1==0) = nan;
d2(d2==0) = nan;

% synthesize new image and disparity map
[out dmap rmap] = genIntView(interp,i1,i2,d1,d2);   % generate view
[outr dmapr] = refineView(rmap,out,dmap);           % refine it
dmap_final = fillDMap(dmapr);                       % fill disparity map
img = fillRegion(outr,dmap_final);                  % fill color image
img_final = refineHoleBorders(img,outr);            % refine it

% plot
figure
imshow(img_final)
title('Synthesized image')
figure
imshow(dmap_final)
title('Synthesized disparity map')
