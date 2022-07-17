

function [occupancy_image,resSegBoundaries] = add_region_to_occupancy_image(curSegBoundaries,input_size,occupancy_image,occpuiedAreaThresh)

resSegBoundaries = [];
counter = 1;
for i = 1 : length(curSegBoundaries)    
    regInds = curSegBoundaries{i};
    finalInds = fillRegionReturnInds(regInds,input_size);       
    occupiedAreaSize = length(find(occupancy_image(finalInds)~=0));
    if occupiedAreaSize < occpuiedAreaThresh        
        uniqueID = length(unique(unique(occupancy_image)));        
        occupancy_image(finalInds) = uniqueID;
        resSegBoundaries{counter} = regInds;
        counter = counter+1;
    end
end

end