function [Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei_CNN(fileName,WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales)


% read the image
[~,~,ext]=fileparts(fileName);
if strcmp(ext,'.txt') ==1
    [image,~] = imreadText(fileName);
else    
    [image,~] = imread(fileName);
end

% turn the image to double format
image= im2double(image);
% image = image(1:200,401:600);
% image = image(601:800,1:200);

% tmp folder for processes
tempPath = fullfile('tmp',random_string(10, 1),random_string(10, 1));
mkdir(tempPath);



% step 1
[allofAllSegBoundaries,finalMask]=computeARGraphNuclei_CNN(WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales,image,tempPath);


% step 2 
[~,occupancy_image,~,~]=compute_boundaries_occupiedArea(image,allofAllSegBoundaries,nOfRep,scales,finalMask);
EMNI = apply_emseg(image);
EMDiff = EMNI-occupancy_image;
Ios = imopen(EMDiff,strel('disk',2));
[seg,myMask] = compute_nuclei_per_patch_cnn_bigSize(1,1,size(image,1),size(image,2),Ios.*image);
[~,curSegBoundaries] = find_boundary_of_each_nuclei(seg,0,0,size(image));
aaa = allofAllSegBoundaries{1};
N = length(aaa);
for i = 1: length(curSegBoundaries)
    aaa{N+i} = curSegBoundaries{i};
end
finalMask = or(finalMask,myMask);

allofAllSegBoundaries{1} = aaa;
[Boundaries,occupancy_image,nucleiOccupancyIndexed,~]=compute_boundaries_occupiedArea_v3(image,allofAllSegBoundaries,nOfRep,scales,finalMask);

% 
% % step 3 
% extraBoundaries = breakToEllipseNucleiSegmentation(image,BIGMASK);
% 
% % step 4
% [~,occupancy_image,nucleiOccupancyIndexed]= addTheExtraBoundaries(Boundaries,occupancy_image,nucleiOccupancyIndexed,extraBoundaries,image);


% step 5
% figure;imshow(image);
% hold on;
% Boundaries = [];
% cCount = 0;
% nOfCells = length(unique(unique(nucleiOccupancyIndexed)))-1;
% myCols = lines(nOfCells);
% for i = 1 : nOfCells
%     
%     [X,Y] = ind2sub(size(nucleiOccupancyIndexed),find(nucleiOccupancyIndexed==i));
%     K = boundary(X,Y);
%     if size(K,1) > 10
%         cCount = cCount + 1;
%         Boundaries{cCount} = sub2ind(size(nucleiOccupancyIndexed),X(K),Y(K));
%         plot(Y,X,'-','MarkerEdgeColor',myCols(i,:));
%     end
% end

nucleiImage = image;

end