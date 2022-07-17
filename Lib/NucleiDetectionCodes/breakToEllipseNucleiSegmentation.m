function extraBoundaries = breakToEllipseNucleiSegmentation(result,BIGMASK)

extraBoundaries = [];
I = result.*BIGMASK;
scale = 4;
resizeScale = scale*3;
diskScale = scale*5;
I = imresize(I,resizeScale);
se = strel('disk',diskScale);
Ie = imerode(I,se);
Iobr = imreconstruct(Ie,I);
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
fIobrcbr = imdiffusefilt(Iobrcbr,'NumberOfIterations',100);
myI = imresize(I,.25);
%T = graythresh(Iobrcbr);
myGr = imgradient(imresize(fIobrcbr,0.25));


% IBW= I;
% IBW(I<T) = 0;
% IBW(I>=T) = 1;
% IBW = imresize(IBW,0.25);
% IBW = logical(IBW);

IBW = imresize(BIGMASK,size(myGr));

IBW = bwareaopen(IBW,100);
IBWR = bwmorph(IBW,'remove',Inf);
se = strel('disk',3);
IBWR = imdilate(IBWR,se);
BorderBW = or(IBWR,imbinarize(myGr,0.05));
BorderBW = bwmorph(BorderBW,'skel',Inf);
BBW = BorderBW;
BIBW = (1-BBW).*IBW;
SE = strel('disk',3);
fgm = imregionalmax(Iobrcbr);
BIBW = or(imresize(fgm,size(BIBW)),BIBW);
BIBW = imerode(BIBW,SE);
BIBW = bwareaopen(BIBW,100);

CC = bwconncomp(BIBW,4);
stats = regionprops(CC,'Solidity');
cI = 1;
rI = 1;
cur_regional_maxima = zeros(size(IBW));
fineRegCounter = 1;
totalPixelList = [];

for regInd =1:length(CC.PixelIdxList)
    
    lenPIL = length(CC.PixelIdxList{regInd});
    if  lenPIL > 100
        cur_regional_maxima(CC.PixelIdxList{regInd}) = 1;
        
        if (stats(regInd).Solidity < 0.85 && lenPIL > 450) ||  lenPIL > 600
            
            rI= rI+1;
            pixelList = CC.PixelIdxList{regInd};
            ImageSize = size(myI);
            IClustTotal=breakToEllipses(ImageSize,pixelList);
            
            uRegInds = unique(unique(IClustTotal));
            for itr = 1 : length(uRegInds)
                if uRegInds(itr)~=0 && length(find(IClustTotal==uRegInds(itr)))> 100
                    totalPixelList{fineRegCounter} = find(IClustTotal==uRegInds(itr));
                    fineRegCounter = fineRegCounter + 1;
                end
            end
            
        else
            cI= cI+1;
            totalPixelList{fineRegCounter} = CC.PixelIdxList{regInd};
            fineRegCounter = fineRegCounter + 1;
        end
    end
    
    
    
end

retained = IBW -cur_regional_maxima;
retained = (imerode(retained,strel('disk',7)));
retained(retained<0) = 0;
retained = bwareaopen(logical(retained),40);
CC = bwconncomp(retained,4);
stats = regionprops(CC,'Solidity');

cur_regional_maxima = zeros(size(IBW));
for regInd =1:length(CC.PixelIdxList)
    lenPIL = length(CC.PixelIdxList{regInd});
    
    if  lenPIL > 100
        cur_regional_maxima(CC.PixelIdxList{regInd}) = 1;
        
        [X,Y]=ind2sub(size(myI),CC.PixelIdxList{regInd});
        %hold on;
        
        if (stats(regInd).Solidity < 0.85 && lenPIL > 450) ||  lenPIL > 600
            
            rI = rI+1;
            %plot(Y,X,'r.');
            pixelList = CC.PixelIdxList{regInd};
            ImageSize = size(myI);
            IClustTotal=breakToEllipses(ImageSize,pixelList);
            
            uRegInds = unique(unique(IClustTotal));
            for itr = 1 : length(uRegInds)
                if uRegInds(itr)~=0&& length(find(IClustTotal==uRegInds(itr)))> 100
                    totalPixelList{fineRegCounter} = find(IClustTotal==uRegInds(itr));
                    fineRegCounter = fineRegCounter + 1;
                end
            end
        else
            cI= cI+1;
            %plot(Y,X,'.','Color',colors{mod(cI,length(colors))+1});
            totalPixelList{fineRegCounter} = CC.PixelIdxList{regInd};
            fineRegCounter = fineRegCounter + 1;
        end
    end
    
    
    
end
fgm4 = zeros(size(myI));
for regInd =1:length(totalPixelList)
    fgm4(totalPixelList{regInd}) = 1;
end


A =(1-myGr.^0.9).*real(myI.^0.8);



Io = imopen(fgm4,strel('disk',5));
Id = imdilate(Io,strel('disk',1));
%imshow(and(IBW,1-Id))
D = bwdist(~and(IBW,1-Id));
DL = watershed(D);
bgm = DL == 0;



fineRegCounter = 1;
totalPixelList = [];
CC = bwconncomp(~bgm,4);
bgmPlus = zeros(size(bgm));
for regInd =1:length(CC.PixelIdxList)
    lenPIL = length(CC.PixelIdxList{regInd});
    mVal = mean(IBW(CC.PixelIdxList{regInd}));
    if  lenPIL > 100 && lenPIL < 2000 && mVal > 0.9
        bgmPlus(CC.PixelIdxList{regInd}) = 1;
        totalPixelList{fineRegCounter} = CC.PixelIdxList{regInd};
        fineRegCounter = fineRegCounter + 1;
    end
end

bgmR = ~imdilate(bgmPlus,strel('disk',7)).*IBW;
bgmRPlus = imopen(bgmR,strel('disk',5));
bwC = activecontour(real(A.^1.6),IBW,10);
bgmRPlus = bgmRPlus.*bwC;

CC = bwconncomp(bgmRPlus);
stats = regionprops(CC,'Solidity');

for regInd =1:length(CC.PixelIdxList)
    lenPIL = length(CC.PixelIdxList{regInd});
    %    mVal = mean(myGr(CC.PixelIdxList{regInd}));
    
    if  lenPIL > 100
        [X,Y]=ind2sub(size(myI),CC.PixelIdxList{regInd});
        if (stats(regInd).Solidity < 0.85 && lenPIL > 450) ||  lenPIL > 600
            rI= rI+1;
            pixelList = CC.PixelIdxList{regInd};
            ImageSize = size(myI);
            IClustTotal=breakToEllipses(ImageSize,pixelList);
            
            uRegInds = unique(unique(IClustTotal));
            for itr = 1 : length(uRegInds)
                if uRegInds(itr)~=0 && length(find(IClustTotal==uRegInds(itr)))> 100
                    totalPixelList{fineRegCounter} = find(IClustTotal==uRegInds(itr));
                    fineRegCounter = fineRegCounter + 1;
                    
                end
            end
            
        else
            cI= cI+1;
            totalPixelList{fineRegCounter} = CC.PixelIdxList{regInd};
            fineRegCounter = fineRegCounter + 1;
        end
    end
    
    
end
semiFinalOutput = zeros(size(myI));
for regInd =1:length(totalPixelList)
    
    semiFinalOutput(totalPixelList{regInd}) = 1;
end

CC = bwconncomp(semiFinalOutput,4);
ratio = size(result)/size(semiFinalOutput);
% colors = lines(length(CC.PixelIdxList));
% figure;
% imshow(result);
% %imshow(imresize(result,size(semiFinalOutput)));
%
% hold on;
inputSize = size(result);
for regInd = 1: length(CC.PixelIdxList)
    pixelList = CC.PixelIdxList{regInd};
    cur_boundary = pixelList;
    [X,Y] = ind2sub(size(semiFinalOutput),cur_boundary);
    X = min(max(floor(X*ratio),1),size(result,1));
    Y = min(max(floor(Y*ratio),1),size(result,2));
    cur_boundary = sub2ind(inputSize,X,Y);
    extraBoundaries{regInd} = cur_boundary;
    %    [X,Y] = ind2sub(size(result),cur_boundary);
    %    plot(Y,X,'.','Color',colors(regInd,:));
end


end















