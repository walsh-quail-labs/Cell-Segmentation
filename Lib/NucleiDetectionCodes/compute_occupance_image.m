function occupancy_image=compute_occupance_image(result,allofAllSegBoundaries)


occupancy_image = zeros(size(result));
allSegBoundaries = allofAllSegBoundaries;
for i = 1 : length(allSegBoundaries)
    cur_boundary = allSegBoundaries{i};
    [X,Y] = ind2sub(size(result),cur_boundary);
    X = min(max(X,1),size(result,1));
    Y = min(max(Y,1),size(result,2));
    regInds = sub2ind(size(result),X,Y);
    finalInds = fillRegionReturnInds(regInds,size(result));
    occupancy_image(finalInds) = 1;    
end


end