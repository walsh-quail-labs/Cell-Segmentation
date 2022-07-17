function [Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei_CNN_all_at_once(fileName,WindowSize)


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
allofAllSegBoundaries=nucleiSegmentationPerScale_CNN_all_at_once(image,WindowSize);


% step 2 find the remaining small cells
if exist(fullfile('Lib','DSB_2018-master','val','stage1_test'),'dir')
    rmdir(fullfile('Lib','DSB_2018-master','val','stage1_test'),'s')
end
if exist(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'dir')
    rmdir(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'s')
end
occupancy_image=compute_occupance_image(image,allofAllSegBoundaries);
EMNI = apply_emseg(image);
EMDiff = EMNI-occupancy_image;
Ios = imopen(EMDiff,strel('disk',4));
seg = compute_nuclei_per_patch_cnn_bigSize(1,1,size(image,1),size(image,2),Ios.*im2double(image));
[~,curSegBoundaries] = find_boundary_of_each_nuclei(seg,0,0,size(image));
aaa = allofAllSegBoundaries;
N = length(aaa);
for i = 1: length(curSegBoundaries)
    aaa{N+i} = curSegBoundaries{i};
end
allofAllSegBoundaries = aaa;


% step 3 - graph untangling process
Boundaries=compute_boundaries_occupiedArea_v4(image,allofAllSegBoundaries);
[occupancy_image,nucleiOccupancyIndexed]=compute_occupance_and_index_image(image,allofAllSegBoundaries);

nucleiImage = image;

end