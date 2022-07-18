function Boundaries=compute_boundaries_occupiedArea_v4(image,allofAllSegBoundaries)

%image,allofAllSegBoundaries,nOfRep,scales,finalMask
Boundaries = [];
inputSize = size(image);
intensity_thresh = 0.1;
counter = 1;
thresh_dist = 200;

disp('1')

allSegBoundaries = allofAllSegBoundaries;

for i = 1 : length(allSegBoundaries)
    cur_boundary = allSegBoundaries{i};
    [X,Y] = ind2sub(inputSize,cur_boundary);
    X = min(max((X),1),size(image,1));
    Y = min(max((Y),1),size(image,2));
    cur_boundary = sub2ind(inputSize,X,Y);
    allSegBoundaries{i} = cur_boundary;
    regInds = cur_boundary;
    [finalInds,boundary_traced_ind] = fillRegionReturnInds(regInds,inputSize);
    black_ratio_area = length(find(image(finalInds) < intensity_thresh))/length(finalInds);
    if  black_ratio_area < 0.2
        Boundaries{counter} = boundary_traced_ind;
        allFinalInds{counter} = finalInds;
        allCenters{counter} = [mean(X),mean(Y)];
        counter = counter+1;

    end
end



N = length(Boundaries);

affinity_matrix = zeros(N,N);
thresh_low = 0.4;
disp('2')
for i = 1 : N
    cell_1 = allFinalInds{i};
    center_1 = allCenters{i}; 
    for j = i+1:N
        
        cell_2 = allFinalInds{j};
        center_2 = allCenters{j};
        
        if norm(center_1-center_2) < thresh_dist
        
            if ~isempty(intersect(cell_1,cell_2))
                lenIntersect = length(intersect(cell_1,cell_2));
                r1 = lenIntersect/length(cell_1);
                r2 = lenIntersect/length(cell_2);
                if r1 > thresh_low || r2 > thresh_low
                    affinity_matrix(i,j) = 1;
                    affinity_matrix(j,i) = 1;
                end

            end
        
        end
        
    end
end

r = fliplr(symrcm(affinity_matrix));

% Get the clusters
C = {r(1)};
for i = 2:numel(r)
    if any(affinity_matrix(C{end}, r(i)))
        C{end}(end+1) = r(i);
    else
        C{end+1} = r(i);
    end
end
toBeRemoved = [];

disp('4')
for i = 1 : length(C)
    
    clustInds = C{i};
    if length(clustInds)>1
        M = length(clustInds);
        ASizes = zeros(M,1);
        for j = 1 : M
            cJ = clustInds(j);            
            ASizes(j) = length(allFinalInds{cJ});
        end
        [~,maxInd]=max(ASizes);
        
        for j = 1 : M
            if j~=maxInd
                toBeRemoved = [toBeRemoved;clustInds(j)];
            end
        end        
    end        
end
Boundaries(toBeRemoved) = [];

end