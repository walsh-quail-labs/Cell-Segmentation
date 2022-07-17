function [result,Pano] = imreadTextZScore(fileName)


Pano = importdata(fileName);
allData = Pano.data;

sizeI2 = max(allData(:,4))+1;
sizeI1 = max(allData(:,5))+1;

V = allData(:,48);
I191 = reshape(zscore(V),[sizeI2,sizeI1])';
result = I191;

end


%Orig_I = I191/bisection(I191);
