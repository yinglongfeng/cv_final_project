function out = refineBorder(img,rmap)

D = 11;
Dh = (D-1)/2;

[M N] = size(img);
edges = find(rmap);
Q = length(edges);
[mm nn] = ind2sub(size(img(:,:,1)),edges);
out = img;

for ii=1:Q
    i_ind = max(1,mm(ii)-Dh) : min(M,mm(ii)+Dh);
    j_ind = max(1,nn(ii)-Dh) : min(N,nn(ii)+Dh);
    
    patch = img(i_ind, j_ind);
    patch = patch(~isnan(patch));
    data = sort(patch(:));
    
    if size(data,1)>1
        df = diff(data);
        idx = [0; find(df); numel(data)];
        count = diff(idx);
        [a b] = max(count);
        out(mm(ii),nn(ii)) = data(idx(b)+1);
    end
end