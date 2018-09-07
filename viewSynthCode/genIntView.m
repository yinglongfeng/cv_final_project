function [out_view dmap rmap] = genIntView(interp, im1, im2, d1, d2)
% GENINTVIEW
%   Synthesizes a virtual view in between a stereo pair.  Doubly occluded
%   pixels are marked by NaNs.
%   Inputs:
%       im1, im2 - L and R stereo images, respectively
%       d1, d2   - disparity maps corresponding to im1 and im2, respectively
%       interp   - fraction (between 0 and 1) of shift between images
%   Outputs:
%       out_view - synthesized intermediate view
%       dmap     - synthesized disparity map for intermediate view

% set up
[sy, sx, sz] = size(im1);
disp1 = double(d1);
disp2 = double(d2);
[tmp1 tmp2] = deal(nan(sy,sx,sz));
[d1 d2] = deal(nan(sy,sx));

% generate intermediate view
test1 = ~isnan(disp1);
x1p = min(sx, max(1,repmat((1:sx),[sy 1]) - round(disp1.*interp)));
test2 = ~isnan(disp2(:,end:-1:1));
x2p = min(sx, max(1,repmat(sx:-1:1,[sy 1]) + round(disp2(:,sx:-1:1)*(1-interp))));
for y=1:sy      % have to do in a loop for memory reasons
    ff = find(test1(y,:));
    tmp1(y,x1p(y,ff),:) = im1(y,ff,:);
    d1(y,x1p(y,ff)) = disp1(y,ff);
    
    ff = find(test2(y,:));
    ff1 = find(test2(y,end:-1:1));
    tmp2(y,x2p(y,ff),:) = im2(y,ff1(end:-1:1),:);
    d2(y,x2p(y,ff)) = disp2(y,ff1(end:-1:1));
end
clear im1 im2 x1p x2p disp1 disp2;

% fill composite image
% use multiplication instead of indexing for memory reasons
nanidx1 = isnan(d1);
nanidx2 = isnan(d2);
d1(nanidx1) = 0;
d2(nanidx2) = 0;
holes = zeros(sy,sx);
holes(nanidx1 & nanidx2) = nan;

test1 = (d1>=d2) & ~nanidx1;
test2 = ~test1 & ~nanidx2;
tmp1(repmat(~test1,[1 1 3])) = 0;
tmp2(repmat(~test2,[1 1 3])) = 0;

out_view = (tmp1 + tmp2)/255 + repmat(holes,[1 1 3]);
dmap = (test1.*d1 + test2.*d2)/255 + holes;

e1 = imdilate(test1,strel('disk',1)) - test1;   % fast pseudo-edge detection
e2 = imdilate(test2,strel('disk',1)) - test2;
rmap = e1 | e2;