function idx = histCost(data,B,val)
srt = sort(data);
d1 = srt(1);
d2 = srt(end);
bin = [d1+(0:B-2)*(d2-d1)/(B-1) d2];
count = histc(val,bin);
[mx ind] = max(count);
if ind==B
    idx = data>=bin(B);
else
    idx = data<bin(ind+1) & data>=bin(ind);
end
