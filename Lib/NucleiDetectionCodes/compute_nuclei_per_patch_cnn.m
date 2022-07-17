function [seg,myMask] = compute_nuclei_per_patch_cnn(stX,stY,endX,endY,result,double_scale,scale,resizeScale,diskScale,tempPath)

% addpath(genpath(fullfile('Lib','EMGMM')))

% Iorig = imread('DNA1_1.png');
Iorig = result(stX:endX,stY:endY);
myMask = zeros(size(Iorig));
seg = zeros(size(Iorig));

IShow = Iorig;

write_path = fullfile('Lib','DSB_2018-master','val','stage1_test','1','images','1.png');
% figure;
% imshow(IShow);
% hold on;
% final_cell_map = zeros(size(Iorig,1),size(Iorig,2));
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
    
    
    % run the deep net code
    if exist(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'dir')
        rmdir(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'s')
    end
    cd Lib
    cd DSB_2018-master
    
    system('source startup.sh')
    cd ..
    cd ..
    
    
    
    total_added = 0;
    
    submit_file = fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder','submit.csv');
    S = importdata(submit_file);
    numBoundaries = length(S);
    if numBoundaries > 5
        I = Iout;
        I1 = I(:,:,1);
        I2 = I(:,:,2);
        I3 = I(:,:,3);
%         imsize = size(I);
        
        
        numBoundaries
       
        for i = 1 : numBoundaries
            points = str2num(S{i});
            points = points(2:end);
            
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
            mean(im2double(Iorig(allPoints)))
            mean(BW(allPoints))
            size(B,1)
            disp('-----')
            if size(B,1)>=1 && mean(BW(allPoints)) > 0.5 && mean(im2double(Iorig(allPoints))) > 0.1
                
                B = B{1};
                
                cell_counter = cell_counter +1;
                myMask(allPoints) = 1;
                X=B(:,1)+off_xy(1);
                Y=B(:,2)+off_xy(2);
%                 plot(Y,X,'.','MarkerSize',10);
                seg(sub2ind(size(seg),X,Y)) = cell_counter;
                B = B+off_xy;
                allBoundaries{cell_counter} = B;                               
                I1(allPoints) = 0;
                I2(allPoints) = 0;
                I3(allPoints) = 0;
                total_added = total_added+1;                                
            end
            
            
        end
        total_added
    end
            
    num_rep = num_rep+1;
    
end



























% 
% 
% should_the_loop_continue = 1; % true
% first_time = 1;
% 
% 
% 
% 
% final_cell_map = zeros(size(Iorig,1),size(Iorig,2));
% cell_counter = 1;
% numRep = 1;
% figure;
% imshow(Iorig);
% hold on;
% while should_the_loop_continue && (numRep <= 2 || (length(find(BW~=0))/(imsize(1)*imsize(2)) < 0.005 || numRep < 3))
%     
% 
%     
%     
%     if first_time
%    
%         I = Iorig;
%         % gray scale to RGB
%         RGB = cat(3,I,I,I);
%         write_path = fullfile('Lib','DSB_2018-master','val','stage1_test','1','images','1.png');
%         imwrite(RGB,write_path);
%         
%         first_time = 0;
%         BW = ones(size(I));
%     else
% %         close all;
% %         image_name = fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder','1.png');
%         submit_file = fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder','submit.csv');
%         S = importdata(submit_file);
%         numBoundaries = length(S);
%         if numBoundaries > 5
%             I = imread(write_path);
%             I1 = I(:,:,1);
%             I2 = I(:,:,2);
%             I3 = I(:,:,3);
%             imsize = size(I);
%             
%             
%             numBoundaries
%             for i = 1 : numBoundaries
%                 points = str2num(S{i});
%                 points = points(2:end);    
% 
%                 T = points(2:2:end);
%                 nOfPoints = length(T);
%                 allPoints = [];    
%                 for j = 1 :2: 2*nOfPoints-1
%                     p = points(j);
%                     front_add = points(j+1);
%                     T = p:1:p+front_add-1;
%                     allPoints = [allPoints,T];
%                 end
%                 total_added = 0;
%                 mean(BW(allPoints))
%                 if mean(BW(allPoints)) > 0.5
%                     final_cell_map(allPoints) = cell_counter;
%                     cell_counter = cell_counter +1;
%                     [X,Y]=ind2sub(imsize,allPoints);
%                     plot(Y,X,'.');
%                     I1(allPoints) = 0;
%                     I2(allPoints) = 0;
%                     I3(allPoints) = 0;
%                     total_added = total_added+1;
%                 end
%             end
%             total_added
%             Iout = cat(3,I1,I2,I3);
% 
%             
%             Ios = Iout;
%             Ios = imopen(Ios,strel('disk',2));
% 
%             BW = apply_emseg(rgb2gray(Ios));
%     %         figure;
%     %         imshow(BW);
%     %       
%             Iout=im2double(I).*cat(3,BW,BW,BW);
%             
%             imwrite(Iout,write_path);
% %             imwrite(cat(3,Iorig,Iorig,Iorig),write_path);
%             should_the_loop_continue = 1;
%             pause(5);
%         else
%             should_the_loop_continue = 0;
%         end
%         
%     end
%     if should_the_loop_continue
%         if exist(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'dir')
%             rmdir(fullfile('Lib','DSB_2018-master','results','nucleus','submit_folder'),'s')
%         end
%         cd Lib
%         cd DSB_2018-master
% 
%         system('source startup.sh')
%         cd ..
%         cd ..
%         numRep = numRep+1;
%     end
% end
