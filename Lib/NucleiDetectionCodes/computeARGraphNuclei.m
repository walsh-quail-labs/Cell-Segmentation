function [allofAllSegBoundaries,finalMask]=computeARGraphNuclei_CNN(WindowSize,occpuiedAreaThresh,double_scale,nOfRep,scales,result,tempPath)

allofAllSegBoundaries = cell(nOfRep,length(scales));
for rep = 1 : nOfRep
    for scale = scales
        resizeScale = scale*3;
        diskScale = scale*5;        
        [curAllSegBoundaries,finalMask]=nucleiSegmentationPerScale_CNN(result,WindowSize,occpuiedAreaThresh,double_scale,scale,resizeScale,diskScale,tempPath);
        fprintf('rep = %d out of %d and scale = %d is done\n',rep,nOfRep,scale);        
        allofAllSegBoundaries{rep,scale} = curAllSegBoundaries;
        
    end
end