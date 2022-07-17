function [Boundaries,occupancy_image,nucleiOccupancyIndexed,BIGMASK]=compute_boundaries_occupiedArea_v2(image,allofAllSegBoundaries,nOfRep,scales,finalMask)

%image,allofAllSegBoundaries,nOfRep,scales,finalMask

Boundaries = [];
inputSize = size(image);
occupancy_image = zeros(size(image));
segM = zeros(size(image));
intensity_thresh = 0.1;
nucleiOccupancyIndexed = zeros(size(image));
counter = 1;

for rep = 1 : nOfRep
    for scale = scales
        
        allSegBoundaries = allofAllSegBoundaries{rep,scale};
        for i = 1 : length(allSegBoundaries)
            
            cur_boundary = allSegBoundaries{i};
            [X,Y] = ind2sub(inputSize*scale,cur_boundary);
            X = min(max(floor(X/scale),1),size(image,1));
            Y = min(max(floor(Y/scale),1),size(image,2));
            cur_boundary = sub2ind(inputSize,X,Y);
            allSegBoundaries{i} = cur_boundary;
            
            regInds = cur_boundary;
            [finalInds,boundary_traced_ind] = fillRegionReturnInds(regInds,inputSize);
            
            black_ratio_area = length(find(image(finalInds) < intensity_thresh))/length(finalInds);
            
            occupiedAreaSize = length(find(occupancy_image(finalInds)~=0));
            
            
            if  black_ratio_area < scale*0.2 && occupiedAreaSize < 100%&& length(cur_boundary) < perm_thresh
                segM(boundary_traced_ind) = 1;
                occupancy_image(finalInds) = 1;
                nucleiOccupancyIndexed(finalInds) = counter;
                Boundaries{counter} = boundary_traced_ind;
                allFinalInds{counter} = finalInds;
%                 allTracedBoundaries{counter} = 
                counter = counter+1;
                
            end
        end
    end
end



N = length(Boundaries);


toBeRemoved = [];
toBeKept = [];
thresh_low = 0.4;
thresh_up = 0.5;

for i = 1 : N
    cell_1 = allFinalInds{i};
    
    for j = i+1:N
        cell_2 = allFinalInds{j};
        if ~isempty(intersect(cell_1,cell_2))
            lenIntersect = length(intersect(cell_1,cell_2));
            r1 = lenIntersect/length(cell_1);
            r2 = lenIntersect/length(cell_2);
%             if length(intersect(cell_1,cell_2))/length(cell_1) > thresh
%                 toBeRemoved = [toBeRemoved;i]; 
%                 if length(intersect(cell_1,cell_2))/length(cell_1) > thresh && length(intersect(cell_1,cell_2))/length(cell_2) > thresh2
%                 toBeKept = [toBeKept;j];
%             end
%             if length(intersect(cell_1,cell_2))/length(cell_2) > thresh
%                 toBeRemoved = [toBeRemoved;j];
%                 toBeKept = [toBeKept;i];
%             end
            if r1 > thresh_up && r2 > thresh_up
                if r1 >= r2
                    toBeRemoved = [toBeRemoved;i];
                    toBeKept = [toBeKept;j];
                else
                    toBeRemoved = [toBeRemoved;j];
                    toBeKept = [toBeKept;i];
                end
            elseif r1 > thresh_up && r2 < thresh_low
                toBeRemoved = [toBeRemoved;i];
            elseif r2 > thresh_up && r1 < thresh_low
                toBeRemoved = [toBeRemoved;j];
            end
            
        end
        
    end
end
toBeRemoved = setdiff(toBeRemoved,toBeKept);

Boundaries(toBeRemoved) = [];

% figure;
% imshow(image); hold on;
% for i = 1 : length(Boundaries)
%     [X,Y] = ind2sub(size(image),Boundaries{i});
%     plot(Y,X,'-','LineWidth',4);
% end
% 


occupied_area = occupancy_image;
occupied_area(occupied_area~=0) = 1;
remainingArea = (finalMask-occupied_area);
remainingArea(remainingArea<=0) = 0;
remainingArea(remainingArea>0) = 1;
BIGMASK = remainingArea;




end