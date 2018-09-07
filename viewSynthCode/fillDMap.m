function dmap_out = fillDMap(dmap)
% dmap - depth map with holes indicated by NaNs

dmap_out = dmap;
[M N] = size(dmap);
holes = isnan(dmap);
regions = bwconncomp(holes);
validMap = ~holes;
halfSz = floor([M N]/2);

Th = 15;      % neighborhood radius
inc = 6;      % increase neighborhood radius if no valid data found
B = 10;       % number of histogram bins

for ii=1:regions.NumObjects
    
    [mm nn] = ind2sub([M N],regions.PixelIdxList{ii});
    P = length(mm);

    % find a neighborhood around each region
    for jj=1:P
        Dh = Th;
        while true
            i_ind = max(1,mm(jj)-Dh) : min(M,mm(jj)+Dh);
            j_ind = max(1,nn(jj)-Dh) : min(N,nn(jj)+Dh);
            map = validMap(i_ind,j_ind);
            if any(map(:))
                break;
            elseif any(Dh >= halfSz)
                error('image is too sparse');
            else
                Dh = min([Dh+inc halfSz]);
            end
        end
        
        % MLE of the disparity
        dpatch = dmap(i_ind, j_ind);
        ddata = dpatch(map);
        mle = histMLE(ddata,B);
        dmap_out(mm(jj),nn(jj)) = mle;
    end
end


function mle = histMLE(data,B)
L = length(data);
srt = sort(data);
d1 = srt(1);
d2 = srt(L);
bin = [d1+(0:B-2)*(d2-d1)/(B-1) d2];
count = reshape(histc(data,bin),[1 B]);
dbar = sum(data)/L;
if L>1
    vr = sum((data - dbar).^2)/(L-1);
else
    vr = 0;
end
cost = 1./count + 1000*vr*bin;
[a ind] = min(cost);
mle = bin(ind);