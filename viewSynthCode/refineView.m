function [outRef dmapRef] = refineView(rmap, img, dmap)

rmap = imdilate(rmap, strel('disk',1));
D = 5;
Dh = (D-1)/2;

[M N C] = size(img);
edges = find(rmap);
Q = length(edges);
[mm nn] = ind2sub(size(img(:,:,1)),edges);
outRef = img;
dmapRef = dmap;

for ii=1:Q
    i_ind = max(1,mm(ii)-Dh) : min(M,mm(ii)+Dh);
    j_ind = max(1,nn(ii)-Dh) : min(N,nn(ii)+Dh);
    
    cpatch = img(i_ind, j_ind, :);
    dpatch = dmap(i_ind, j_ind);
    
    R = numel(dpatch);
    data = sort(reshape(cpatch,[R 3]),1);
    dpatch = sort(dpatch(:),1);
    
    med = floor(R/2);
    if 2*med == R
        idx = [med med+1];
        outRef(mm(ii),nn(ii),:) = (sum(data(idx,:),1)/2)';
        dmapRef(mm(ii),nn(ii)) = sum(dpatch(idx))/2;
    else
        outRef(mm(ii),nn(ii),:) = data(med+1,:)';
        dmapRef(mm(ii),nn(ii)) = dpatch(med+1);
    end
end