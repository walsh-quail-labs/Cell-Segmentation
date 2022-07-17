function [Boundaries,occupancy_image,nucleiOccupancyIndexed]= addTheExtraBoundaries(Boundaries,occupancy_image,nucleiOccupancyIndexed,extraBoundaries,result)
counter = length(Boundaries)+1;
inputSize = size(result);
intensity_thresh = 0.03;
 
for i = 1 : length(extraBoundaries)
    
    cur_boundary = extraBoundaries{i};
    regInds = cur_boundary;
    finalInds = fillRegionReturnInds(regInds,inputSize);    
    black_ratio_area = length(find(result(finalInds) < intensity_thresh))/length(finalInds);    
    occupiedAreaSize = length(find(occupancy_image(finalInds)~=0));
    
    
    if  black_ratio_area < 0.2 && occupiedAreaSize < 20%&& length(cur_boundary) < perm_thresh
        occupancy_image(finalInds) = 1;
        nucleiOccupancyIndexed(finalInds) = counter;
        Boundaries{counter} = cur_boundary;
        counter = counter+1;
    end
end