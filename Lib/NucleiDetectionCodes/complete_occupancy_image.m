

function occupancy_image = complete_occupancy_image(allSegBoundaries,input_size)

occupancy_image = zeros(input_size);

for i = 1 : length(allSegBoundaries)    
    regInds = allSegBoundaries{i};
    finalInds = fillRegionReturnInds(regInds,input_size);       
    if ~isempty(finalInds)
        occupancy_image(finalInds) = i;
    end
end

end