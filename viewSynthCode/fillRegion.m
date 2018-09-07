function out = fillRegion(holeyImg,dmap)

out = holeyImg;
[M N C] = size(holeyImg);
holes = isnan(holeyImg(:,:,1));
holeMap = zeros(M,N);
holeMap(holes(:)) = nan;
bw = rgb2gray(holeyImg) + holeMap;  % convert to grayscale, keep NaNs
validMap = ~holes;
regions = bwconncomp(holes);
bmap = logical(imdilate(holes,strel('disk',1)) - holes);     % border pixels
threshSz = floor([M N])/5;

Th = 15;      % neighborhood radius
inc = 6;      % increase neighborhood radius if no valid data found
B = 10;       % number of histogram bins
Nclust = 5;   % clusters for k-means

for ii=1:regions.NumObjects
    [mm nn] = ind2sub([M N],regions.PixelIdxList{ii});
    P = length(mm);

    % find a neighborhood around each region
    [min_i max_i min_j max_j] = deal(zeros(1,P));
    vIdxCell = cell(1,P);
    for jj=1:P
        Dh = Th;
        flag = 0;
        while true
            i_ind = max(1,mm(jj)-Dh) : min(M,mm(jj)+Dh);
            j_ind = max(1,nn(jj)-Dh) : min(N,nn(jj)+Dh);
            map = validMap(i_ind,j_ind);
            if any(map(:))
                if flag
                    vIdx = find(map(:));
                    break;
                end
                dpatch = dmap(i_ind, j_ind);
                idx = find(histCost(dpatch(:),B,dmap(mm(jj),nn(jj))));
                vIdx = idx(map(idx));       % indices of valid pixels at correct disparity
                if any(Dh >= threshSz)
                    if flag
                        error('image is too sparse');
                    end
                    flag = 1;
                    Dh = Th;
                elseif isempty(vIdx)
                    Dh = min([Dh+inc threshSz]);
                else
                    break;
                end
            elseif any(Dh >= threshSz)
                if flag
                    error('image is too sparse');
                end
                flag = 1;
                Dh = Th;
            else
                Dh = min([Dh+inc threshSz]);
            end
        end
        min_i(jj) = i_ind(1);
        max_i(jj) = i_ind(end);
        min_j(jj) = j_ind(1);
        max_j(jj) = j_ind(end);
        vIdxCell{jj} = vIdx;
    end
    
    super_i = min(min_i) : max(max_i);
    super_j = min(min_j) : max(max_j);
    superNbrhd = bw(super_i, super_j);
    superKMidx_orig = kmeans(superNbrhd(:),Nclust,'emptyaction','drop');
    idxBdr = bmap(super_i, super_j);        % get the border of the region
    
    [sM sN] = size(superNbrhd);
    superKMidx_smooth = refineBorder(reshape(superKMidx_orig,[sM sN]),idxBdr);
    superKMidx = superKMidx_smooth(:);
    superClrBdr = superKMidx.*idxBdr(:);
    
    superII = (1:sM)'*ones(1,sN);
    superJJ = ones(sM,1)*(1:sN);
    
    for jj=1:P          % for each hole in the region
        abs_i = min_i(jj) : max_i(jj);
        abs_j = min_j(jj) : max_j(jj);
        Mm = length(abs_i);
        Nn = length(abs_j);
        vIdx = vIdxCell{jj};
        
        % get valid data
        data = reshape(holeyImg(abs_i, abs_j, :),[Mm*Nn 3]);
        data = data(vIdx,:);
        
        % get k-means indices
        vec_i = (ones(Nn,1)*(abs_i-super_i(1)+1))';
        vec_j = ((abs_j-super_j(1)+1)'*ones(1,Mm))';
        locSeg = vec_i(vIdx) + (vec_j(vIdx)-1)*size(superNbrhd,1);
        goodKM = superKMidx(locSeg);
        
        % border pixels at the appropriate disparity tagged by color
        bdr = superClrBdr(locSeg);
        
        % form distance matrices
        i_loc = find((abs_i-mm(jj))==0);
        j_loc = find((abs_j-nn(jj))==0);
        II = superII(1:Mm,1:Nn);
        JJ = superJJ(1:Mm,1:Nn);
        dist = (II(vIdx)-i_loc).^2 + (JJ(vIdx)-j_loc).^2;
        
        % choose color region based on border pixels
        cntr = zeros(1,Nclust);     % faster than 'deal'
        bdist = zeros(1,Nclust);
        bidx = cell(1,Nclust);
        [sdist sidx] = sort(dist);
        sbdr = bdr(sidx);
        for pp=1:Nclust
            bidx{pp} = sbdr==pp;
            cntr(pp) = length(find(bidx{pp}));
        end
        cntr(cntr==0) = inf;
        minNum = min(cntr);
        for pp=1:Nclust
            if cntr(pp) ~= inf
                bdc = sdist(bidx{pp});
                mnh = floor(minNum/2);
                if 2*mnh==minNum
                    bdist(pp) = sum(bdc([mnh mnh+1]))/2;
                else
                    bdist(pp) = bdc(mnh+1);
                end
            end
        end
        bdist(bdist==0) = inf;
        [gg hh] = min(bdist);
        
        % assign value
        if gg==inf
            for pp=1:Nclust
                cntr(pp) = sum(goodKM == pp);
            end
            [gg hh] = max(cntr);
            candPix = goodKM==hh;
            val = sum(data(candPix,:),1)'/length(find(candPix));
        else
            candPix = goodKM==hh;
            val = sum(data(candPix,:),1)'/length(find(candPix));
        end
        
        out(mm(jj),nn(jj),:) = val;
    end
end
