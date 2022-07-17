function [newSeg,curSegBoundaries] = find_boundary_of_each_nuclei_v2(seg,offsetX,offsetY,originalSize,edge_sx,edge_sy,edge_ex,edge_ey)


curSegBoundaries = [];
UniqueRegInds = unique(unique(seg));
newSeg = zeros(size(seg));
counter = 1;
for itr = 1:length(UniqueRegInds)    
    regInd = UniqueRegInds(itr);
    if regInd~=0
        [bX,bY] = ind2sub(size(seg),find(seg==regInd));
        if (edge_sx || isempty(intersect(bX,1))) && (edge_sy || isempty(intersect(bY,1))) && (edge_ex || isempty(intersect(bX,size(seg,1)))) && (edge_ey || isempty(intersect(bY,size(seg,2)))) && length(bX) >= 5 
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