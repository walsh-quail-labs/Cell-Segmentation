function [Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei_MaskRCNNalone(fileName,WindowSize)


% read the image
[~,~,ext]=fileparts(fileName);
if strcmp(ext,'.txt') ==1
    [image,~] = imreadText(fileName);
else    
    [image,~] = imread(fileName);
end

% turn the image to double format
image= im2double(image);
% image = image(16:215,172:371);

% tmp folder for processes
% tempPath = fullfile('tmp',random_string(10, 1),random_string(10, 1));
% mkdir(tempPath);



% step 1 find all possibe cells 
allofAllSegBoundaries=nucleiSegmentationMaskRCNNAlone(image,WindowSize);

Boundaries=compute_boundaries_occupiedArea_v4(image,allofAllSegBoundaries);
[occupancy_image,nucleiOccupancyIndexed]=compute_occupance_and_index_image(image,allofAllSegBoundaries);

nucleiImage = image;

end