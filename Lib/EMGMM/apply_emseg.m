function M=apply_emseg(I)
I = imgaussfilt(I,1);
mask=EMSeg(I,2);

if mask~=-1
    M = mask(:,:,1);
    M(M==2) = 0;
    M = ~M;
    thresh = 20;%floor((size(I,1)*size(I,2))/1000)
    M = bwareaopen(M,thresh);
    
else
    M = imbinarize(I);
end

end