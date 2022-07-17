% clear all;
% clc;
% 
% nucleiImagePath = 'nuclei_multiscale.mat';
% cancer_img_path_1 = 'Pancytokeratin_2.png';
% cancer_img_path_2 = 'TTF1_2.png';

% function fix_bad_scans(nucleiImagePath,cancer_1,cancer_2)

% cancer_1 = imread(cancer_img_path_1);
% cancer_2 = imread(cancer_img_path_2);

nucleiImagePath = '/Users/elham/OneDrive - McGill University/SegmentationGBM/Data_BMR/BrM IMC run Dec 06/Acq3/Pano 07_7_ROI_14-206-C2_23/nuclei_multiscale.mat';
cancer_1 = imread('/Users/elham/OneDrive - McGill University/AxonNuclei_Brm/Main Files and Folders/JMF_March24/IMCData/BrainProject/Data_BMR/BrM IMC run Dec 06/Acq3/Pano 07_7_ROI_14-206-C2_23/MeLanA_2.png');
cancer_2 = imread('/Users/elham/OneDrive - McGill University/AxonNuclei_Brm/Main Files and Folders/JMF_March24/IMCData/BrainProject/Data_BMR/BrM IMC run Dec 06/Acq3/Pano 07_7_ROI_14-206-C2_23/PMEL_2.png');
newNucleiImagePath = '/Users/elham/OneDrive - McGill University/SegmentationGBM/Data_BMR/BrM IMC run Dec 06/Acq3/Pano 07_7_ROI_14-206-C2_23/nuclei_multiscale_updated_may24.mat';
% newNucleiImagePath = 


input_data = importdata(nucleiImagePath);
nucleiImage = input_data.nucleiImage;
Boundaries = input_data.Boundaries;

L = zeros(size(nucleiImage));
occupancy_image = zeros(size(nucleiImage));

Boundaries2 = cell(size(Boundaries));
regIndSizes = zeros(length(Boundaries),1);
allFinalInds = cell(length(Boundaries),1);
for k = 1:length(Boundaries)
    boundaryInd = Boundaries{k};
    [bx, by] = ind2sub(size(nucleiImage),boundaryInd);
    boundary = [bx,by];
    idx = drawline(boundary(1:end-1,:),boundary(2:end,:),size(nucleiImage));
    Boundaries2{k} = idx';
    finalInds = fillRegionReturnInds(idx',size(nucleiImage));
    allFinalInds{k} = finalInds;
    regIndSizes(k) = length(finalInds);
    L(finalInds) = k;
    occupancy_image(finalInds) = 1;
end
cancer = or(cancer_1,cancer_2);
stats = regionprops(L,'Area','Centroid');
threshold_cancer = 0.87;
threshold = 0.92;
toBeRemoved = [];
for k = 1:length(Boundaries)
    
    % obtain (X,Y) boundary coordinates corresponding to label 'k'
    boundaryInd = Boundaries2{k};
    [bx, by] = ind2sub(size(nucleiImage),boundaryInd);
    boundary = [bx,by];
    
    % compute a simple estimate of the object's perimeter
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq,2)));
    
    % obtain the area calculation corresponding to label 'k'
    area = stats(k).Area;
    
    % compute the roundness metric
    metric = 4*pi*area/perimeter^2;
    
    % display the results
    metric_string = sprintf('%2.2f',metric);
    
    % mark objects above the threshold with a black circle
%     if (mean(cancer(allFinalInds{k})) < 0.1 &&  metric < threshold && regIndSizes(k)>200) || (mean(cancer(allFinalInds{k})) > 0.6 && regIndSizes(k)>350  &&  metric < threshold_cancer)
    if (mean(cancer(allFinalInds{k})) < 0.5 &&  regIndSizes(k)>200) || (mean(cancer(allFinalInds{k})) > 0.5 && regIndSizes(k)>350  &&  metric < threshold_cancer)    
        centroid = stats(k).Centroid;
        occupancy_image(allFinalInds{k}) = 0;
        toBeRemoved = [toBeRemoved;k];
    end
    
end

mask_m = apply_emseg(nucleiImage);
%mask_m = apply_emseg(real(nucleiImage.^1.3));
mask_d = mask_m - occupancy_image;
mask_d = bwareaopen(mask_d,100);
mask_d = imopen(mask_d,strel('disk',4));

I = nucleiImage.*mask_d;

A = imresize(I,4);
[L,N] = superpixels(A,10000);
BW = boundarymask(L);

LL = L.*imresize(mask_d,size(BW));
UL = unique(LL(LL~=0));

SBW = BW.*imresize(mask_d,size(BW));
SBW = or(SBW,imresize(bwmorph(mask_d,'remove',Inf),size(BW)));


[B,L] = bwboundaries(~SBW,'noholes',4);
UL = sort(unique(L));
lower_thresh_area = 200;
upper_thresh_area = 20000;
occupancy_image = zeros(size(nucleiImage));
nucleiOccupancyIndexed = zeros(size(nucleiImage));
count = 0;
% imshow(nucleiImage);
% % 
% hold on;
counter = 1;
for k = 1:length(Boundaries)
    if ~ismember(k,toBeRemoved)
        boundaryInd = Boundaries{k};
        [bx, by] = ind2sub(size(nucleiImage),boundaryInd);
%         plot(by,bx,'-');
        boundary = [bx,by];
        idx = drawline(boundary(1:end-1,:),boundary(2:end,:),size(nucleiImage));
        finalInds = fillRegionReturnInds(idx',size(nucleiImage));
        occupancy_image(finalInds) = 1;
        nucleiOccupancyIndexed(finalInds) = counter;        
        FinalBoundaries{counter} = boundaryInd;
        counter = counter + 1;
    end
end

% hold on;
for k = 2:length(UL)

    curInds = find(L == UL(k));
    if length(curInds) > lower_thresh_area && length(curInds) < upper_thresh_area
        count = count + 1;
        [rx,ry]=ind2sub(size(LL),curInds); 
        rotated_ellipse = fit_ellipse_modified(ry,rx);
%         plot( rotated_ellipse(1,:)/4,rotated_ellipse(2,:)/4,'-');
        if ~isempty(rotated_ellipse)
            bx = min(max(round(rotated_ellipse(1,:)/4),1),size(nucleiImage,1));
            by = min(max(round(rotated_ellipse(2,:)/4),1),size(nucleiImage,2));
            bx = bx';
            by = by';
            boundaryInd = sub2ind(size(nucleiImage),by,bx);
            boundary = [by,bx];
            idx = drawline(boundary(1:end-1,:),boundary(2:end,:),size(nucleiImage));
            finalInds = fillRegionReturnInds(idx',size(nucleiImage));
    %         finalInds
    %         mean(nucleiImage(finalInds))
            ratio = sum(occupancy_image(finalInds))/length(finalInds);
            if mean(nucleiImage(finalInds)) > 0.1 &&  ratio < 0.3
                occupancy_image(finalInds) = 1;
                nucleiOccupancyIndexed(finalInds) = counter;
                FinalBoundaries{counter} = boundaryInd;
                counter = counter + 1;
            end
        end
        
        
    end
end
Boundaries = FinalBoundaries;
save(newNucleiImagePath,'nucleiOccupancyIndexed', 'Boundaries', 'nucleiImage', 'occupancy_image');

% end
% imshow(label2rgb(nucleiOccupancyIndexed,@lines,[.5 .5 .5]))
% imshow(imoverlay(nucleiImage,bwmorph(occupancy_image,'remove',Inf)));


