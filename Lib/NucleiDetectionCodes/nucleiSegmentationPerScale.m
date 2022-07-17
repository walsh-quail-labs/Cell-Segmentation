function [allSegBoundaries,finalMask]=nucleiSegmentationPerScale(result,WindowSize,occpuiedAreaThresh,double_scale,scale,resizeScale,diskScale,tempPath)

finalMask = zeros(size(result));
finalMask = logical(finalMask);
allSegBoundaries = [];
inputSize = size(result)*scale;


specialSituationX = 0;
specialSituationY = 0;
%
% if mod(size(result,1),WindowSize) > 10 && mod(size(result,2),WindowSize) > 10
%     % special situation
%     specialSituation = 1;
% end

if mod(size(result,1),WindowSize) > 10
    % special situation
    specialSituationX = 1;
end

if mod(size(result,2),WindowSize) > 10
    % special situation
    specialSituationY = 1;
end





endItrX = size(result,1)-WindowSize+1;
endItrY = size(result,2)-WindowSize+1;


%
% if specialSituation == 1
%     endItrX = endItrX+WindowSize;
%     endItrY = endItrY+WindowSize;
% end

if specialSituationX == 1
    endItrX = endItrX+WindowSize;
end
if specialSituationY == 1
    endItrY = endItrY+WindowSize;
end


for stX = 1:WindowSize:endItrX
    for stY = 1:WindowSize:endItrY
        
        
        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;
        
        %         if specialSituation == 1
        %             endX = min(endX,size(result,1));
        %             endY = min(endY,size(result,2));
        %         end
        if specialSituationX == 1
            endX = min(endX,size(result,1));
        end
        if specialSituationY == 1
            endY = min(endY,size(result,2));
        end
        
        
        [seg,myMask] = compute_nuclei_per_patch(stX,stY,endX,endY,result,double_scale,scale,resizeScale,diskScale,tempPath);
        
        % bayast bar hasbe scale i ke patch ro az toosh dar aavordim result
        % patch haro too ye 2 ta matrix mask zakhire konim.
        sstX = (stX-1)*scale+1;
        sstY = (stY-1)*scale+1;
        curfM = finalMask(stX:endX,stY:endY);
        B = imresize(myMask,size(curfM));
        finalMask(stX:endX,stY:endY)=or(logical(curfM),B);
        
        
        % baraye segmentation boundary haro dar miaarim be nesbate position
        % haye akse original
        [~,curSegBoundaries] = find_boundary_of_each_nuclei(seg,sstX-1,sstY-1,inputSize);
        % boundary haro be ye arayeye kolli ezafe mikonim
        allSegBoundaries = [allSegBoundaries,curSegBoundaries];
    end
end

% ye doone matrix occupancy dorost mikonim 
occupancy_image = complete_occupancy_image(allSegBoundaries,inputSize);


% serie dovvome dar aavordan e nuclei ha 50 ta oonvartar
endItrY2 = size(result,2)-WindowSize-floor(WindowSize/2)+1;
if specialSituationY == 1
    endItrY2 = endItrY2+WindowSize;
end

for stX = 1:WindowSize:endItrX
    for stY = floor(WindowSize/2)+1:WindowSize:endItrY2
        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;
        
        %         if specialSituation == 1
        %             endX = min(endX,size(result,1));
        %             endY = min(endY,size(result,2));
        %         end
        if specialSituationX == 1
            endX = min(endX,size(result,1));
        end
        if specialSituationY == 1
            endY = min(endY,size(result,2));
        end
        
        
        [seg,myMask] = compute_nuclei_per_patch(stX,stY,endX,endY,result,double_scale,scale,resizeScale,diskScale,tempPath);
        sstX = (stX-1)*scale+1;
        sstY = (stY-1)*scale+1;
        curfM = finalMask(stX:endX,stY:endY);
        B = imresize(myMask,size(curfM));
        finalMask(stX:endX,stY:endY)=or(logical(curfM),B);
        [~,curSegBoundaries] = find_boundary_of_each_nuclei(seg,sstX-1,sstY-1,inputSize);
        [occupancy_image,resSegBoundaries] = add_region_to_occupancy_image(curSegBoundaries,inputSize,occupancy_image,occpuiedAreaThresh);
        allSegBoundaries = [allSegBoundaries,resSegBoundaries];
        
    end
end



occupancy_image = complete_occupancy_image(allSegBoundaries,inputSize);



% serie 3vome dar aavordane nuclei 
% fprintf('stX = %d,stY = %d,enX = %d,enY = %d\n',stX,stY,endX,endY);
endItrX2 = size(result,1)-WindowSize-floor(WindowSize/2)+1;
if specialSituationX == 1
    endItrX2 = endItrX2+WindowSize;
end


for stX = floor(WindowSize/2)+1:WindowSize:endItrX2
    for stY = 1:WindowSize:endItrY
        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;
        
%         if specialSituation == 1
%             endX = min(endX,size(result,1));
%             endY = min(endY,size(result,2));
%         end
        
        if specialSituationX == 1
            endX = min(endX,size(result,1));
        end
        if specialSituationY == 1
            endY = min(endY,size(result,2));
        end
        
        [seg,myMask] = compute_nuclei_per_patch(stX,stY,endX,endY,result,double_scale,scale,resizeScale,diskScale,tempPath);
        sstX = (stX-1)*scale+1;
        sstY = (stY-1)*scale+1;
        curfM = finalMask(stX:endX,stY:endY);
        B = imresize(myMask,size(curfM));
        finalMask(stX:endX,stY:endY)=or(logical(curfM),B);
        [~,curSegBoundaries] = find_boundary_of_each_nuclei(seg,sstX-1,sstY-1,inputSize);
        [occupancy_image,resSegBoundaries] = add_region_to_occupancy_image(curSegBoundaries,inputSize,occupancy_image,occpuiedAreaThresh);
        allSegBoundaries = [allSegBoundaries,resSegBoundaries];
        
    end
end

end











