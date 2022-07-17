function [Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei(fileName,WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales)


% read the image
[image,~] = imread(fileName);

% turn the image to double format
image= im2double(image);
image = image(1:300,1:300);

% tmp folder for processes
tempPath = fullfile('tmp',random_string(10, 1),random_string(10, 1));
mkdir(tempPath);



% step 1
[allofAllSegBoundaries,finalMask]=computeARGraphNuclei(WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales,image,tempPath);

% step 2 
[Boundaries,occupancy_image,nucleiOccupancyIndexed,BIGMASK]=compute_boundaries_occupiedArea(image,allofAllSegBoundaries,nOfRep,scales,finalMask);


% step 3 
extraBoundaries = breakToEllipseNucleiSegmentation(image,BIGMASK);

% step 4
[~,occupancy_image,nucleiOccupancyIndexed]= addTheExtraBoundaries(Boundaries,occupancy_image,nucleiOccupancyIndexed,extraBoundaries,image);


% step 5
figure;imshow(image);
hold on;
Boundaries = [];
cCount = 0;
nOfCells = length(unique(unique(nucleiOccupancyIndexed)))-1;
myCols = lines(nOfCells);
for i = 1 : nOfCells
    
    [X,Y] = ind2sub(size(nucleiOccupancyIndexed),find(nucleiOccupancyIndexed==i));
    K = boundary(X,Y);
    if size(K,1) > 10
        cCount = cCount + 1;
        Boundaries{cCount} = sub2ind(size(nucleiOccupancyIndexed),X(K),Y(K));
        plot(Y,X,'.','MarkerEdgeColor',myCols(i,:));
    end
end
nucleiImage = image;

end