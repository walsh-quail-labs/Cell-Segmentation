function allSegBoundaries=nucleiSegmentationPerScale_CNN_all_at_once(result,WindowSize)



result = im2double(result);
inputSize = size(result);
allSegBoundaries = [];
if exist(fullfile('Lib','MaskRCNN','val','stage1_test'),'dir')
    rmdir(fullfile('Lib','MaskRCNN','val','stage1_test'),'s')
end


% zero-pad result image first
[W,H] = size(result);
numW = ceil(W/WindowSize);
numH = ceil(H/WindowSize);
newW = numW*WindowSize;
newH = numH*WindowSize;
resultPadded = zeros(newW,newH);
resultPadded(1:W,1:H) = result(:,:);
half_window = WindowSize/2;



image_grid_counter = 1;

for i = 1 : numW
    for j = 1 : numH          
        stX = (i-1)*WindowSize+1;
        stY = (j-1)*WindowSize+1;        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;               
        I = resultPadded(stX:endX,stY:endY);
        I = cat(3,I,I,I);
        Iout = im2double(I);
        mkdir(fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images'));
        imwrite(Iout,fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images',strcat(num2str(image_grid_counter),'.png')));
        image_grid_counter = image_grid_counter + 1;
    end
end

for i = 1 : numW-1
    for j = 1 : numH          
        stX = (i-1)*WindowSize+1+half_window;
        stY = (j-1)*WindowSize+1;        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;               
        I = resultPadded(stX:endX,stY:endY);
        I = cat(3,I,I,I);
        Iout = im2double(I);
        mkdir(fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images'));
        imwrite(Iout,fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images',strcat(num2str(image_grid_counter),'.png')));
%         all_starts_ends{image_grid_counter} = [stX,stY,endX,endY];
        image_grid_counter = image_grid_counter + 1;
    end
end

for i = 1 : numW
    for j = 1 : numH-1          
        stX = (i-1)*WindowSize+1;
        stY = (j-1)*WindowSize+1+half_window;        
        endX = stX+WindowSize-1;
        endY = stY+WindowSize-1;               
        I = resultPadded(stX:endX,stY:endY);
        I = cat(3,I,I,I);
        Iout = im2double(I);
        mkdir(fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images'));
        imwrite(Iout,fullfile('Lib','MaskRCNN','val','stage1_test',num2str(image_grid_counter),'images',strcat(num2str(image_grid_counter),'.png')));
%         all_starts_ends{image_grid_counter} = [stX,stY,endX,endY];
        image_grid_counter = image_grid_counter + 1;
    end
end

numPatches = image_grid_counter-1;

 
% run the Neural Network
% remove extra folders
try
if exist(fullfile('Lib','MaskRCNN','results','nucleus','submit_folder'),'dir')
    rmdir(fullfile('Lib','MaskRCNN','results','nucleus','submit_folder'),'s')
end
catch
end
cd Lib
cd MaskRCNN
system('source startup.sh')
cd ..
cd ..



% read the submit file 
submit_file = fullfile('Lib','MaskRCNN','results','nucleus','submit_folder','submit.csv');
[C1,C2] = csvimport( submit_file, 'columns', [1, 2],'noHeader', true);
C1 = C1(2:end);
C2 = C2(2:end);
numBoundaries = length(C2);

allPatchBoundaries = cell(numPatches,1);
total_added = 0;
for i = 1 : numBoundaries
    
    patchIndex = str2double(C1{i});    
    val = C2{i};
    points = str2num(val);
    T = points(2:2:end);
    nOfPoints = length(T);
    allPoints = [];
    for j = 1 :2: 2*nOfPoints-1
        p = points(j);
        front_add = points(j+1);
        T = p:1:p+front_add-1;
        allPoints = [allPoints,T];
    end
    BWCell = zeros(WindowSize,WindowSize);
    BWCell(allPoints) = 1;
    B = bwboundaries(BWCell);    
    if ~isempty(B)
        B = B{1};
        aP = allPatchBoundaries{patchIndex};
        aP{length(aP)+1} = B;
        allPatchBoundaries{patchIndex} = aP;                               
        total_added = total_added+1;            
    end
end




image_grid_counter = 1;
for i = 1 : numW
    for j = 1 : numH 
        edge_sx = 0 ; 
        edge_sy = 0 ;
        edge_ex = 0 ;
        edge_ey = 0 ;                              
        stX = (i-1)*WindowSize+1;
        stY = (j-1)*WindowSize+1; 
        
        if i ==1
            edge_sx = 1;
        end
        if j == 1
            edge_sy = 1;
        end
        if i == numW
            edge_ex = 1;            
        end        
        if j == numH
            edge_ey = 1;            
        end
        
        curPathBoundaries = allPatchBoundaries{image_grid_counter};        
        curSegBoundaries = adjust_boundaries(curPathBoundaries,stX-1,stY-1,inputSize,edge_sx,edge_sy,edge_ex,edge_ey);
        allSegBoundaries = [allSegBoundaries,curSegBoundaries];

        image_grid_counter = image_grid_counter + 1;
        
        
    end
end

for i = 1 : numW-1
    for j = 1 : numH    
        edge_sx = 0 ; 
        edge_sy = 0 ;
        edge_ex = 0 ;
        edge_ey = 0 ; 
        stX = (i-1)*WindowSize+1+half_window;
        stY = (j-1)*WindowSize+1;        
        if j == 1
            edge_sy = 1;
        end          
        if j == numH
            edge_ey = 1;            
        end
        curPathBoundaries = allPatchBoundaries{image_grid_counter};        
        curSegBoundaries = adjust_boundaries(curPathBoundaries,stX-1,stY-1,inputSize,edge_sx,edge_sy,edge_ex,edge_ey);
        allSegBoundaries = [allSegBoundaries,curSegBoundaries];

        image_grid_counter = image_grid_counter + 1;
    end
end

for i = 1 : numW
    for j = 1 : numH-1  
        edge_sx = 0 ; 
        edge_sy = 0 ;
        edge_ex = 0 ;
        edge_ey = 0 ; 
        stX = (i-1)*WindowSize+1;
        stY = (j-1)*WindowSize+1+half_window;        
        
        if i ==1
            edge_sx = 1;
        end        
        if i == numW
            edge_ex = 1;            
        end        
        curPathBoundaries = allPatchBoundaries{image_grid_counter};        
        curSegBoundaries = adjust_boundaries(curPathBoundaries,stX-1,stY-1,inputSize,edge_sx,edge_sy,edge_ex,edge_ey);
        allSegBoundaries = [allSegBoundaries,curSegBoundaries];
        image_grid_counter = image_grid_counter + 1;
    end
end




end











