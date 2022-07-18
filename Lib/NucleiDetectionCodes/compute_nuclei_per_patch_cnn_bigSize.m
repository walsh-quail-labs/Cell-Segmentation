function [seg,myMask] = compute_nuclei_per_patch_cnn_bigSize(stX,stY,endX,endY,result)
Iorig = result(stX:endX,stY:endY);
myMask = zeros(size(Iorig));
seg = zeros(size(Iorig));
mkdir(fullfile('Lib','MaskRCNN','val','stage1_test','1','images'));
write_path = fullfile('Lib','MaskRCNN','val','stage1_test','1','images','1.png');
Ios = Iorig;
cell_counter = 0;
num_rep = 1 ;
off_xy = [0,0];
total_added = 100;
while num_rep < 10 && total_added > 2 && mean(mean(mean(Ios))) > 0.001
    
    % create an image to write    
    if num_rep ~=1
        Iout = cat(3,I1,I2,I3);
        Ios = Iout;
        Ios = imopen(Ios,strel('disk',2));
        
        BW = apply_emseg(rgb2gray(Ios));
        Iout=im2double(I).*cat(3,BW,BW,BW);     
    else
        I = Iorig;
        I = cat(3,I,I,I);
        Iout = im2double(I);
        BW = ones(size(rgb2gray(Iout)));
    end           
    imwrite(Iout,write_path);
    
    try 
    % run the deep net code
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
    
    
    
    total_added = 0;    
    submit_file = fullfile('Lib','MaskRCNN','results','nucleus','submit_folder','submit.csv');
    [~,C2] = csvimport( submit_file, 'columns', [1, 2],'noHeader', true);
    C2 = C2(2:end);    
    numBoundaries = length(C2);
    if numBoundaries > 5
        I = Iout;
        I1 = I(:,:,1);
        I2 = I(:,:,2);
        I3 = I(:,:,3);

       
        for i = 1 : numBoundaries
            
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
            BWCell = zeros(size(Iorig));
            BWCell(allPoints) = 1;
            B = bwboundaries(BWCell);
            if size(B,1)>=1 && mean(BW(allPoints)) > 0.35 && mean(im2double(Iorig(allPoints))) > 0.1
                
                B = B{1};
                
                cell_counter = cell_counter +1;
                myMask(allPoints) = 1;
                X=B(:,1)+off_xy(1);
                Y=B(:,2)+off_xy(2);
                seg(sub2ind(size(seg),X,Y)) = cell_counter;
                B = B+off_xy;
                allBoundaries{cell_counter} = B;                               
                I1(allPoints) = 0;
                I2(allPoints) = 0;
                I3(allPoints) = 0;
                total_added = total_added+1;                                
            end
            
            
        end
    end
            
    num_rep = num_rep+1;
    
end
