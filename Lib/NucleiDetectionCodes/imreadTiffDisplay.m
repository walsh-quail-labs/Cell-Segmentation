function [result,score] = imreadTiffDisplay(fileName)

I = imread(fileName);
score = bisection(I);
result = I*score;

end