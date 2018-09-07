function out = refineHoleBorders(img,holeyImg)

rmap = isnan(holeyImg(:,:,1));
rmap = imdilate(rmap,strel('disk',2)) - rmap;
D = 5;
Dh = (D-1)/2;

[M N C] = size(img);
edges = find(rmap);
Q = length(edges);
[mm nn] = ind2sub(size(img(:,:,1)),edges);
out = img;

for ii=1:Q
    i_ind = max(1,mm(ii)-Dh) : min(M,mm(ii)+Dh);
    j_ind = max(1,nn(ii)-Dh) : min(N,nn(ii)+Dh);
    
    cpatch = img(i_ind, j_ind, :);
    R = numel(cpatch(:,:,1));
    data = sort(reshape(cpatch,[R 3]),1);
    
    med = floor(R/2);
    if 2*med == R
        idx = [med med+1];
        out(mm(ii),nn(ii),:) = (sum(data(idx,:),1)/2)';
    else
        out(mm(ii),nn(ii),:) = data(med,:)';
    end
end