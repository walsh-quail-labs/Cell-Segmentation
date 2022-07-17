function [finalInds,boundary_traced_ind] = fillRegionReturnInds(regInds,input_size)
[X,Y] = ind2sub(input_size,regInds);

minX = min(X);
minY = min(Y);
maxX = max(X);
maxY = max(Y);
P = [X-minX+2,Y-minY+2];

try
    [k,~] = convhull(P);

    % plot(P(k,1)+minY-2,P(k,2)+minX-2,'-')
    NP1 = [P(k,1),P(k,2)];
    NP1 = NP1(1:end-1,:);
    NP2 = [NP1(end,:);NP1(1:end-1,:)];


    regWindow = zeros(maxX-minX+4,maxY-minY+4);
    [ind, ~] = drawline(NP1,NP2,size(regWindow));
    regWindow(ind) = 1;

    %  [xb,yb]= ind2sub(size(regWindow),find(regWindow~=0));
     xb = P(k,1)+minX-2;
     yb = P(k,2)+minY-2;
     boundary_traced_ind = sub2ind(input_size,xb,yb);
    % regWindow(sub2ind(size(regWindow),X-minX+2,Y-minY+2)) = 1;

    % [NX,NY]=trace_contour_correctly_magnify(regWindow,X-minX+2,Y-minY+2,1,size(regWindow));
    % NP= [NX,NY];
    % plot(Y,X,'.');
    regWindow = imfill(regWindow,'holes');



    [newX,newY] = ind2sub(size(regWindow),find(regWindow~=0));

    newX = newX+minX-2;
    newY = newY+minY-2;

    finalInds = sub2ind(input_size,newX,newY);
catch XE
    finalInds =[];
    boundary_traced_ind = [];
end
end