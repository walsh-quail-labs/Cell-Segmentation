function [seg,myMask] = compute_nuclei_per_patch(stX,stY,endX,endY,result,double_scale,scale,resizeScale,diskScale,tempPath)


%fprintf('stX = %d, stY = %d\n',stX,stY);


% endX = stX+WindowSize-1;
% endY = stY+WindowSize-1;
% I morede nazar dar patch dar nazar gerefte shode khande mishavad
I = result(stX:endX,stY:endY);


% intensityPower = max(2-((4*rep)/10),0.4);
% I = real(I.^intensityPower);

% intensity patch ro bala mibarim
I = real(I.^0.5);

% ba scale morede nazar scale mikonim
scaledI = imresize(I,double_scale);
I = imresize(I,resizeScale);

% dakhele aks ro bar hasbe scale smooth mikonim
se = strel('disk',diskScale);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);




% az aks smooth shode ye threshold binarization dar miaarim
T = max(graythresh(Iobrcbr),0.2);
IBW= I;
% aks ro binarize mikonim
IBW(I<T) = 0;
IBW(I>=T) = 1;
IBW = imresize(IBW,size(scaledI));
IBW = logical(IBW);
% bar hasbe size scale noise har ro remove mikonim
IBW = bwareaopen(IBW,25*double_scale);


% 
% 
% %fIobrcbr = imdiffusefilt(Iobrcbr,'NumberOfIterations',100);
% myGr = imgradient(Iobrcbr);
IBWR = bwmorph(IBW,'remove',Inf);
se = strel('disk',3);
IBWR = imdilate(IBWR,se);
% GrBorder = imbinarize(imresize(myGr,size(IBWR)),0.1);
% %GrBorder = imdilate(GrBorder,se);
% BorderBW = or(IBWR,GrBorder);
% BorderBW = bwmorph(BorderBW,'skel',Inf);
% IBW = IBW.*~BorderBW;
% IBWM = bwareaopen(IBW,100);
% 
% 

% ye koocholoo smooth mikonim
myImage = scaledI;
myImage = imgaussfilt(myImage,double_scale/2);
myImage = uint8(real(myImage.^.5)*255);
myMask = IBW;
% myMask = IBWM;


ratio = scale/double_scale;
myImage = imresize(myImage,ratio);
myMask = imresize(myMask,ratio);

% aks ro be file format code ARGraph minivisim
myImagePath = fullfile(tempPath,'myImage');
myMaskPath = fullfile(tempPath,'myMask');

dlmwrite(myImagePath,myImage,'delimiter',' ');
dlmwrite(myMaskPath,myMask,'delimiter',' ');



[m,n] = size(myImage);


FileName = myImagePath;
S = fileread(FileName);
strIns  =strcat(num2str(m),{' '},num2str(n));
strIns = strIns{1};
S = [strIns newline S];
FID = fopen(FileName, 'w');
if FID == -1, error('Cannot open file %s', FileName); end
fwrite(FID, S, 'char');
fclose(FID);


FileName = myMaskPath;
S = fileread(FileName);
strIns  =strcat(num2str(m),{' '},num2str(n));
strIns = strIns{1};
S = [strIns newline S];
FID = fopen(FileName, 'w');
if FID == -1, error('Cannot open file %s', FileName); end
fwrite(FID, S, 'char');
fclose(FID);

% code C ke ARGraph ro run mikone seda mizanim 
out_primPath = fullfile(tempPath,'out_prim');
command = strcat('./Lib/ARGraphs/ARGraphs',{' '},'1',{' '},myImagePath,{' '},myMaskPath,{' '},out_primPath,{' '},'15',{' '},'0.3',{' '},'4',{' '},'-1',{' '},'2');
command = command{1};
[A,~] = system(command);
counter1 = 0;
% montazer mimunim ke hatman system javab bede
% age 10 baar javab nadad bikhiaal mishim
while A~=0 && counter1 < 10
    pause(1);
    [A,~] = system(command);
    counter1 = counter1+1;
end

if counter1 >= 10 && A~=0
    seg = zeros(size(myMask));
    disp('Part I NOOOT done - passing zeros');

else
    segmented_cellsPath = fullfile(tempPath,'segmented_cells');
    command = strcat('./Lib/ARGraphs/ARGraphs',{' '},'2',{' '},out_primPath,{' '},myMaskPath,{' '},'5',{' '},segmented_cellsPath,{' '},'0');
    command = command{1};
    [A,~] = system(command);
    counter2 = 0;
    while A~=0 && counter2 < 10
        pause(1);
        [A,~] = system(command);
        counter2 = counter2+1;
    end
    %disp('Part II done!');
    if counter2 >= 10 && A~=0
        seg = zeros(size(myMask));
        disp('Part II NOOOT done - passing zeros');
    else
        try
            seg = dlmread(segmented_cellsPath, '', 1, 0);
        catch XE
            seg = zeros(size(myMask));
            disp('GOT an exception on SEG - passing zeros');
        end
    end
    % khoroojie ma "seg" ro bar migardoonim
end
