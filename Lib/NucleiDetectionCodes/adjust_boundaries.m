function curSegBoundaries = adjust_boundaries(curPathBoundaries,offsetX,offsetY,originalSize,edge_sx,edge_sy,edge_ex,edge_ey)


counter = 1;
curSegBoundaries =[];
for i = 1 : length(curPathBoundaries)
    curB = curPathBoundaries{i};
    bX = curB(:,1);
    bY = curB(:,2);
    if (edge_sx || isempty(intersect(bX,1))) && (edge_sy || isempty(intersect(bY,1))) && (edge_ex || isempty(intersect(bX,originalSize(1)))) && (edge_ey || isempty(intersect(bY,originalSize(2)))) && length(bX) >= 5 
        bX = bX+offsetX;
        bY = bY+offsetY;
        bX(bX> originalSize(1)) = originalSize(1);
        bY(bY> originalSize(2)) = originalSize(2);
        boundaryInds = sub2ind(originalSize,bX,bY);
        curSegBoundaries{counter} = boundaryInds;
        counter = counter+1;
    end       
end

end