function [allofAllSegBoundaries,finalMask]=computeARGraphNuclei_CNN_all_at_once(WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales,result,tempPath)

% allofAllSegBoundaries = cell(nOfRep,length(scales));
[allofAllSegBoundaries,finalMask]=nucleiSegmentationPerScale_CNN_all_at_once(result,WindowSize);
fprintf('rep = %d out of %d and scale = %d is done\n',rep,nOfRep,scale);        
allofAllSegBoundaries{rep,scale} = curAllSegBoundaries;
        