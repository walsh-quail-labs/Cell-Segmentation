function [Boundaries,occupancy_image,nucleiOccupancyIndexed,BIGMASK]=compute_boundaries_occupiedArea(result,allofAllSegBoundaries,nOfRep,scales,finalMask)


Boundaries = [];
inputSize = size(result);
occupancy_image = zeros(size(result));
segM = zeros(size(result));
intensity_thresh = 0.1;
nucleiOccupancyIndexed = zeros(size(result));
counter = 1;
for rep = 1 : nOfRep
    for scale = scales
        
        allSegBoundaries = allofAllSegBoundaries{rep,scale};
        for i = 1 : length(allSegBoundaries)
            
            cur_boundary = allSegBoundaries{i};
            [X,Y] = ind2sub(inputSize*scale,cur_boundary);
            X = min(max(floor(X/scale),1),size(result,1));
            Y = min(max(floor(Y/scale),1),size(result,2));
            cur_boundary = sub2ind(inputSize,X,Y);
            allSegBoundaries{i} = cur_boundary;
            
            regInds = cur_boundary;
            [finalInds,boundary_traced_ind] = fillRegionReturnInds(regInds,inputSize);
            
            black_ratio_area = length(find(result(finalInds) < intensity_thresh))/length(finalInds);
            
            occupiedAreaSize = length(find(occupancy_image(finalInds)~=0));
            
            
            if  black_ratio_area < scale*0.2 && occupiedAreaSize < 100%&& length(cur_boundary) < perm_thresh
                segM(boundary_traced_ind) = 1;
                occupancy_image(finalInds) = 1;
                nucleiOccupancyIndexed(finalInds) = counter;
                Boundaries{counter} = boundary_traced_ind;
                counter = counter+1;
            end
        end
    end
end

occupied_area = occupancy_image;
occupied_area(occupied_area~=0) = 1;
remainingArea = (finalMask-occupied_area);
remainingArea(remainingArea<=0) = 0;
remainingArea(remainingArea>0) = 1;
BIGMASK = remainingArea;


end