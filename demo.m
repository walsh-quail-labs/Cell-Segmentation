clear all;
clc;
addpath(genpath('Lib'))

fileName = '/Volumes/My Passport/OneDrive/Data/Brain Data/Data_BMR/20191121 Acquisition/20191121_BrM_8Others_2_ROI_08-716-C1_5.txt';
WindowSize = 200;
[Boundaries,nucleiImage,occupancy_image,nucleiOccupancyIndexed]=compute_nuclei_CNN_all_at_once(fileName,WindowSize);

figure;imshow(nucleiImage);
hold on;
for i = 1 : length(Boundaries)
    [x,y]=ind2sub(size(nucleiImage),Boundaries{i});
    plot(y,x,'LineWidth',2);
end