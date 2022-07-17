function [newSeg,curSegBoundaries] = find_boundary_of_each_nuclei(seg,offsetX,offsetY,originalSize)


curSegBoundaries = [];
UniqueRegInds = unique(unique(seg));
newSeg = zeros(size(seg));
counter = 1;
for itr = 1:length(UniqueRegInds)
    
    regInd = UniqueRegInds(itr);
    if regInd~=0
        [bX,bY] = ind2sub(size(seg),find(seg==regInd));
        if isempty(intersect(bX,1)) && isempty(intersect(bY,1)) && isempty(intersect(bX,size(seg,1))) && isempty(intersect(bY,size(seg,2))) && length(bX) >= 5 
            newSeg(seg==regInd) = regInd;
            bX = bX+offsetX;
            bY = bY+offsetY;
            boundaryInds = sub2ind(originalSize,bX,bY);
            curSegBoundaries{counter} = boundaryInds;
            counter = counter+1;
        end

        
    end
    
end

end